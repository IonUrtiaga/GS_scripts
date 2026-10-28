function [lon1,lat1,u,v]=adt2velgeos(lon,lat,adt)
% [lon1,lat1,u,v]=adt2velgeos(lon,lat,adt)
% Converts adt to geostrophic velocity
%INPUTS 
% lon(degrees East): longitude (mx1) arrays
% lat(degrees North): latitude (nx1) arrays
% adt(m): Sea surface height above geoid 2D Matrix(m x n).
%OUTPUTS
% lon1/lat1 (degrees): mid lon/lat-s arrays (m-1 and n-1 dims)
% u/v (m/s): Zonal/meridional component of surface geostrophic velocity 

% from Doglioni et al. (2022) -->https://essd.copernicus.org/preprints/essd-2022-111/essd-2022-111.pdf

% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es

% dn/dlat
dn_dlat=nan(size(adt)-1);

for ln=1:length(lon)-1
    nlat(ln,:)=(adt(ln+1,:)+adt(ln,:))./2;
end

for lt=1:length(lat)-1
    dn_dlat(:,lt)=(nlat(:,lt+1)-nlat(:,lt))./((lat(lt+1)-lat(lt))*2*pi/360);%lat passed to radians
    lat1(lt)=(lat(lt)+lat(lt+1))./2;
end


% dn/dlon
dn_dlon=nan(size(adt)-1);

for lt=1:length(lat)-1
    nlon(:,lt)=(adt(:,lt+1)+adt(:,lt))./2;
end

for ln=1:length(lon)-1
    dn_dlon(ln,:)=(nlon(ln+1,:)-nlon(ln,:))./((lon(ln+1)-lon(ln))*2*pi/360);%lon passed to radians
    lon1(ln)=(lon(ln)+lon(ln+1))./2;
end

%
g=9.81;%m s-2
R=6371E3;%m
rot=7.2921E-5;%rad s-1
f=2*rot*sind(lat1);


u=-g./R./f.*dn_dlat;

v=g./f./R./cosd(lat1).*dn_dlon;

end