function [GSI_km,time_GSI,lon_GSI,lat_GSI]=GS_Index_km(lon,lat,time,adt,thr)

% GS_Index_km: Function to calculate the Gulf Stream Index (GSI) in km, following Pérez-Hernández and Joyce (2013) 
% https://doi.org/10.1175/JPO-D-13-0136.1
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%
% Inputs:
%   lon  - Longitude (nx1)
%   lat  - Latitude (mx1)
%   time - Time (tx1)
%   adt  - Absolute Dynamic Topography (nxmxt)
%   thr  - Threshold for MDT gradient (m/km). In observations we set to 3E-3 m/km.
%
% Outputs:
%   GSI_km   - Monthly Gulf Stream Index (in km Northward) (t_mox1)
%   time_GSI - Monthly time vector corresponding to GS_Index (t_mox1)
%   lon_GSI  - Longitudes used for GSI (16x1)
%   lat_GSI  - Latitudes used for GSI (16x1)

lon_GSI=[ -72.0000, -70.6667, -69.3333, -68.0000, -66.6667, -65.3333, -64.0000, -62.6667, -61.3333, -60.0000, -58.6667, -57.3333, -56.0000, -54.6667, -53.3333, -52.0000] ;

% Check that lon is within the range of lonGSI
if min(lon) > min(lon_GSI) || max(lon) < max(lon_GSI)
    error('Longitude range of input data does not cover the required lonGSI range.');
end

adt_RAW = adt;

% If time is daily, pass to monthly
if mean(diff(time)) < 27
    disp('Passing to monthly data')
    adt_mo  = nan(length(lon),length(lat),length(year(time(1)):length(year(time(end)))*12));
    time_mo = nan(length(year(time(1)):year(time(end)))*12,1);
    mo = 1;
    for yy = year(time(1)):year(time(end))
        for mm = 1:12
            ind = find(year(time)==yy & month(time)==mm);
            adt_mo(:,:,mo)  = tsnanmean(adt(:,:,ind),3);
            time_mo(mo)     = datenum(yy,mm,15);
            mo = mo + 1;
        end
    end
    time = time_mo;
    adt  = adt_mo;
else
    time_mo = time;
end

% Interpolate ADT to lon_GSI
adt_interp = nan(length(lon_GSI),length(lat),length(time));
for t = 1:length(time)
    for la = 1:length(lat)
        adt_interp(:,la,t) = interp1(lon,adt(:,la,t),lon_GSI,'linear');
    end
end

MDT     = tsnanmean(adt_interp,3);
MDT_RAW = tsnanmean(adt_RAW,3);
sla     = adt_interp - MDT;
std_sla = tsnanstd(sla,0,3);

for ii = 1:16
    [~,indLat(ii)] = max(std_sla(ii,:));
    lat_GSI(ii)    = lat(indLat(ii));
    for jj = 1:length(time)
        if std_sla(ii,indLat(ii)) > 0.1
            slap(jj,ii) = sla(ii,indLat(ii),jj);
        else
            slap(jj,ii) = nan;
            lat_GSI(ii) = nan;
            lon_GSI(ii) = nan;
        end
    end
end

% Remove seasonality
for ii = 1:16
    for mm = 1:12
        ind = find(month(time)==mm);
        seas(mm,ii)          = tsnanmean(slap(ind,ii));
        slap_deseas(ind,ii)  = slap(ind,ii) - seas(mm,ii);
    end
end
GSI      = tsnanmean(slap_deseas,2);
time_GSI = time_mo;

%% Convert GSI from m of SLA to km shifts using MDT gradient

% dn/dlat
dn_dlat = nan(size(MDT_RAW)-1);
for ln = 1:length(lon)-1
    nlat(ln,:) = (MDT_RAW(ln+1,:) + MDT_RAW(ln,:)) ./ 2;
end
for lt = 1:length(lat)-1
    dn_dlat(:,lt) = (nlat(:,lt+1) - nlat(:,lt)) ./ ((lat(lt+1)-lat(lt)) * 111.2); % lat to km
    lat1(lt) = (lat(lt) + lat(lt+1)) ./ 2;
end

% dn/dlon
dn_dlon = nan(size(MDT_RAW)-1);
for lt = 1:length(lat)-1
    nlon(:,lt) = (MDT_RAW(:,lt+1) + MDT_RAW(:,lt)) ./ 2;
end
d_lon = 2*pi*6371*cosd(lat1)/360; % lon to km conversion factor
for ln = 1:length(lon)-1
    dn_dlon(ln,:) = (nlon(ln+1,:) - nlon(ln,:)) ./ ((lon(ln+1)-lon(ln)) .* d_lon);
    lon1(ln) = (lon(ln) + lon(ln+1)) ./ 2;
end

MDT_grad = sqrt(dn_dlon.^2 + dn_dlat.^2);

% Remove values below threshold
MDT_grad(MDT_grad < thr) = nan;

% Restrict to lon_GSI region
ind = find(~isnan(lon_GSI));
[~,thr_lon(1)] = min(abs(lon1 - lon_GSI(min(ind))));
[~,thr_lon(2)] = min(abs(lon1 - lon_GSI(max(ind))));
MDT_grad(1:thr_lon(1)-2,:)    = nan;
MDT_grad(thr_lon(2)+2:end,:)  = nan;

% Average gradient and convert GSI to km
MDT_grad_mean = tsnanmean(MDT_grad(:));
GSI_km        = GSI / MDT_grad_mean;

end
