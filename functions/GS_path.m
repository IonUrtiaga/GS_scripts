function lat_GS = GS_path(adt, lat, lon)
% GS_path: Extracts the Gulf Stream path from Absolute Dynamic Topography (ADT)
%          using maximum ADT gradient, continuity constraint, and eddy filtering.
%
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%
% Inputs:
%   adt - Absolute Dynamic Topography field [lat x lon] or [lon x lat]
%   lat - Latitude vector (mx1)
%   lon - Longitude vector (nx1)
%
% Output:
%   lat_GS - Latitude of the Gulf Stream path at each longitude (1 x lon)

%% -----------------------------
% Ensure correct orientation: adt = [lat x lon]
%% -----------------------------
if size(adt,1) == length(lon) && size(adt,2) == length(lat)
    adt = adt';  % convert to [lat x lon]
end

if size(adt,1) ~= length(lat) || size(adt,2) ~= length(lon)
    error('ADT dimensions do not match lat/lon vectors after correction.');
end

%% -----------------------------
% Parameters
%% -----------------------------
window = 5;          % continuity constraint (deg lat)
slope_thresh = 10;   % deg lat per grid step (eddy detection threshold)
min_eddy_lon = 20;   % minimum segment length in grid points (eddy removal)

%% -----------------------------
% Smooth ADT (disabled — smoothing applied after gradient step)
%% -----------------------------
adt_smooth = adt;

%% -----------------------------
% Compute ADT gradient [lat x lon]
%% -----------------------------
[dadt_dy, dadt_dx] = gradient(adt_smooth, ...
    mean(diff(lat)), mean(diff(lon)));

grad_mag = sqrt(dadt_dx.^2 + dadt_dy.^2);

% Mask eastward gradients (keep only westward jet)
grad_mag(dadt_dx > 0) = NaN;

%% -----------------------------
% Initialize output
%% -----------------------------
lat_GS = NaN(1, length(lon));

%% -----------------------------
% Step 1: Maximum gradient per longitude
%% -----------------------------
for i = 1:length(lon)
    col = grad_mag(:, i);
    if all(isnan(col)), continue; end
    [~, idx] = max(col);
    lat_GS(i) = lat(idx);
end

%% -----------------------------
% Step 2: Continuity constraint
%% -----------------------------
for i = 2:length(lon)
    if isnan(lat_GS(i-1)), continue; end
    col = grad_mag(:, i);
    mask = abs(lat - lat_GS(i-1)) <= window;
    col(~mask) = NaN;
    if all(isnan(col)), continue; end
    [~, idx] = max(col);
    lat_GS(i) = lat(idx);
end

%% -----------------------------
% Protect initial segment (west of -72 lon)
%% -----------------------------
init_lon_limit = find(lon <= -72, 1, 'last');

%% -----------------------------
% Step 3: Eddy filter
%% -----------------------------

% Compute slope along longitude
dlat = diff(lat_GS);
dlon = mean(diff(lon));
slope = dlat / dlon;

% Detect sharp changes (eddy-like)
eddy_mask = false(size(lat_GS));
eddy_mask(2:end) = abs(slope) > slope_thresh;

% Protect western boundary region
eddy_mask(1:init_lon_limit) = false;

lat_GS(eddy_mask) = NaN;

%% -----------------------------
% Step 4: Remove short segments (eddies)
%% -----------------------------
valid = ~isnan(lat_GS);
d = diff([0 valid 0]);
starts = find(d == 1);
ends   = find(d == -1) - 1;

for i = 1:length(starts)
    seg_len = ends(i) - starts(i) + 1;
    if seg_len < min_eddy_lon
        lat_GS(starts(i):ends(i)) = NaN;
    end
end

%% -----------------------------
% Step 5: Interpolation and smoothing
%% -----------------------------
% Fill internal gaps only (no edge extrapolation)
lat_GS = fillmissing(lat_GS, 'pchip', 'EndValues', 'none');
lat_GS = smoothdata(lat_GS, 'gaussian', 7, 'omitnan');

%% -----------------------------
% Step 5b: Extend last valid value to trailing NaNs
%% -----------------------------
last_valid = find(~isnan(lat_GS), 1, 'last');
if ~isempty(last_valid) && last_valid < length(lat_GS)
    lat_GS(last_valid+1:end) = lat_GS(last_valid);
end

end
