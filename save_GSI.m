% save_GSI.m
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%
% Computes GSI, GSI_km and GSPI for all CMIP6/HighResMIP models and DUACS. Saves GSI_all.mat.

clear all
close all

% path containing CMIP models
CMIP_path='/var/qnas/Ion/CMIP6/';

% iterate though each model
model_list=[
    "0DUACS"
    "0DUACS-twosat"
    "ACCESS-CM2"
    "ACCESS-ESM1-5"
    "AWI-CM-1-1-MR"
    "BCC-CSM2-MR"
    "CAMS-CSM1-0"
    "CAS-ESM2-0"
    "CESM2"
    "CESM2-FV2"
    "CESM2-WACCM"
    "CIESM"
    "CMCC-CM2-SR5"
    "CMCC-ESM2"
    "CNRM-ESM2-1"
    "CanESM5"
    "CanESM5-1"
    "E3SM-1-0"
    "E3SM-1-1"
    "E3SM-1-1-ECA"
    "EC-EARTH3"
    "FGOALS-g3"
    "FIO-ESM-2-0"
    "GFDL-CM4"
    "GISS-E2-1-G"
    "GISS-E2-1-H"
    "INM-CM4-8"
    "INM-CM5-0"
    "IPSL-CM6A-LR"
    "KIOST-ESM"
    "MIROC6"
    "MPI-ESM-1-2-HAM"
    "MPI-ESM1-2-HR"
    "MPI-ESM1-2-LR"
    "MRI-ESM2-0"
    "NorCPM1"
    "NorESM2-LM"
    "NorESM2-MM"
    "SAM0-UNICON"
    "TaiESM1"
    "UKESM1-0-LL"
    "z-CESM1-CAM5-HR"
    "z-CMCC-CM2-HR4"
    "z-CMCC-CM2-VHR4"
    "z-CNRM-CM6-1"
    "z-EC-EARTH-3P-HR"
    "z-FGOALS-f3-H"
    "z-HADGEM3-GC3-HH"
    "z-MPI-ESM1-2-HR"   
];
for m=1:length(model_list)
    model_name=model_list{m};
    if strcmp(model_name,'.') || strcmp(model_name,'..')
        continue
    end
   disp(sprintf('#=======================# \n        %s\n#=======================#', model_name));
    %iterate though each ensemble member from each model
    for r=1:6
        ens_name=sprintf('r%di1p1f1',r);
        ens_path=sprintf('ALL-%s',ens_name);
        disp(ens_name);
        % Now process each ensemble GSI, etc.
        file_adt=fullfile(CMIP_path,ens_path,model_name,'/zos/zos.nc');
        if strcmp(model_name,'0DUACS')&r==1;%updated data
            file_adt='/media/disk/smbdata/Ion/GS_Scripts/Round1/Updated_Figs/cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.125deg_P1D_adt_75.94W-45.06W_33.06N-45.94N_1993-01-01-2025-10-18.nc';
        end
        % check if file exists
        if ~isfile(file_adt)
             disp('    No data');
             continue
         end
         %load data
         lon=double(ncread(file_adt,'longitude'));
         lat=double(ncread(file_adt,'latitude'));
         time=double(timenc2datenum(file_adt,'time'));
         if contains(model_name,'DUACS')
             adt=ncread(file_adt,'adt');
         else
             adt=ncread(file_adt,'zos');
         end

         %pass to monthly
         if tsnanmean(diff(time))<27
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
             clearvars adt_mo time_mo
         end
         
         MDT=tsnanmean(adt,3);
         SLA_std=tsnanstd((adt-MDT),0,3); 

         % GSI following Pérez-Hernández & Joyce (2013)
         [GSI,time_GSI,lon_GSI,lat_GSI]=GS_Index(lon,lat,time,adt);% GSI is estimated monthly by default

         % GSI in km, using the thresholds for MDT gradient indicated in the study.
         if contains(model_name,'DUACS')
             thr=3E-3;
         else
             thr=.8E-3;
         end
         %%
         % figure
         % pcolor(lon,lat,SLA_std');shading flat
         % hold on
         % plot(lon_GSI,lat_GSI,'.')

         %% continue only if any GSI value ~nan
         if any(~isnan(GSI))
         [GSI_km,time_GSI,lon_GSI,lat_GSI]=GS_Index_km(lon,lat,time,adt,thr);% GSI is estimated monthly by default.
          [GSI_vel]=GSPI(lon,lat,time,adt);

         % pass GSI_vel to monthly if time is not monthly
         if max(diff(time))>31
             mo=1;
             for yy=year(time(1)):year(time(end))
                for mm=1:12
                     ind=find(year(time)==yy & month(time)==mm);
                     GSI_vel_mo(mo)=tsnanmean(GSI_vel(ind));
                     %max_vel_mo(mo)=tsnanmean(max_vel(ind));
                     time_vel_mo(mo)=datenum(yy,mm,15);
                     mo=mo+1;
                end
             end
         else
             GSI_vel_mo=GSI_vel;
           % max_vel_mo=max_vel;
             time_vel_mo=time;
         end

         % store following structure: model/ensemble/GSI, GSI_km, GSI_vel_mo, max_vel_mo, time_GSI, time_vel_mo, lon, lat, lon_GSI, lat_GSI, MDT, SLA_std
         % be aware that fields cant start by numbers so remove 0 from DUACS models
         if startsWith(model_name,'0')
             model_name_clean=model_name(2:end);
         else
             model_name_clean=model_name;
         end
         model_name_clean=matlab.lang.makeValidName(model_name_clean);
         GSI_data.(model_name_clean).(ens_name).GSI=GSI;
         GSI_data.(model_name_clean).(ens_name).GSI_km=GSI_km;
         GSI_data.(model_name_clean).(ens_name).GSI_vel_mo=GSI_vel_mo;
         GSI_data.(model_name_clean).(ens_name).time_GSI=time_GSI;
         GSI_data.(model_name_clean).(ens_name).time_vel_mo=time_vel_mo;
         GSI_data.(model_name_clean).(ens_name).lon=lon;
         GSI_data.(model_name_clean).(ens_name).lat=lat;
         GSI_data.(model_name_clean).(ens_name).lon_GSI=lon_GSI;
         GSI_data.(model_name_clean).(ens_name).lat_GSI=lat_GSI;
         GSI_data.(model_name_clean).(ens_name).MDT=MDT;
         GSI_data.(model_name_clean).(ens_name).SLA_std=SLA_std;
          end
     end
end
% store GSI_data structure to a .mat file
save('../mat/GSI_all.mat','GSI_data','model_name_clean','-v7.3');