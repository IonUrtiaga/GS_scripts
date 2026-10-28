function [dp,time_yr,time_mo,lat_GS,var_vel] = GSDI(lon, lat, time, adt, thr)
% Function to calculate the destabilization point index (dp) adapted from Andres (2016)
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es

% Inputs:
%   lon  - Longitude (nx1)
%   lat  - Latitude (mx1)
%   time - Time (tx1)
%   adt  - Absolute Dynamic Topography (nxmxt)
%   thr  - Variance threshold (scalar)

% Outputs:
%   dp   - Destabilization point index (t_yrx1)
%   time_yr - Yearly time vector corresponding to dp (t_yrx1)

lat_GS=nan(length(time),length(lon));
% for tt=1:length(time)
%     for ln=1:length(lon)
%         vel_s=vel(ln,:,tt);
%         if ln==1
%             [~,indlat]=max(vel_s); 
%         else
%             indprev=find(lat==lat_GS(tt,ln-1));
%             indrng=(max(indprev-wdw,1):min(indprev+wdw,length(lat)));
%             [~,indlat_rng]=max(vel_s(indrng));
%             indlat=indrng(indlat_rng);  
%         end
%         lat_GS(tt,ln)=lat(indlat);
%     end
% end

%if time is daily pass to monthly
time_mo=[];
if mean(diff(time))<27 %daily data
    disp('Passing to monthly data')
    %pass to monthly
    adt_mo=[];
    time_mo=[];
    n=1;
    for yy=year(time(1)):year(time(end))
        for mm=1:12
            indt=find(month(time)==mm & year(time)==yy);
            adt_mo(:,:,n)=tsnanmean(adt(:,:,indt),3);
            time_mo(n)=datenum(yy,mm,15);
            n=n+1;
        end
    end

    %rename
    time=time_mo;
    adt=adt_mo;
end

for tt=1:length(time)
    lat_GS(tt,:)=GS_path(adt(:,:,tt), lat, lon);%filtered eddies
end

%% Remove outliers
%lat_GS(lat_GS<30)=nan;

%% annual st desv
ny=1;
for yy=year(time(1)):year(time(end))
    ind=find(year(time)==yy);
    for ll=1:length(lon)
        st_lat(ll,ny)=tsnanstd(lat_GS(ind,ll));
    end
    time_yr(ny)=datenum(yy,01,01);
    ny=ny+1;
end

var_vel=st_lat.^2;%variance


%% First thr variance exceedance
dp=nan(1,size(var_vel,2));
for ii=1:size(var_vel,2)
    indd=min(find(var_vel(:,ii)>thr));
    if isempty(indd)
        dp(ii)=NaN;
    else
        dp(ii)=lon(indd);
    end
end

end