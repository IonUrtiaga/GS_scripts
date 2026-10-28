function GSI_vel = GSPI(lon, lat, time, adt)
% GSPI: Computes the Gulf Stream Path Index as the
%                       mean latitude of the Gulf Stream path between 72°W and 52°W.
%
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%
% Inputs:
%   lon  - Longitude vector (nx1)
%   lat  - Latitude vector (mx1)
%   time - Time vector (tx1, in datenum format)
%   adt  - Absolute Dynamic Topography [lon x lat x time]
%
% Output:
%   GSI_vel - Gulf Stream Path Index, mean latitude between 72°W-52°W (tx1)

fprintf('GSIv processing: %3.0f%%', 0);

GSI_vel = nan(length(time), 1);

for tt = 1:length(time)
    lat_GS = GS_path(adt(:,:,tt), lat, lon);
    [~, indL] = min(abs(lon + 72));
    [~, indR] = min(abs(lon + 52));
    GSI_vel(tt) = tsnanmean(lat_GS(indL:indR));
    fprintf('\b\b\b\b%3.0f%%', 100*tt/length(time));
end

fprintf('\n');

end
