% save_GSDI.m
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%
% Computes the GS Destabilization Index (GSDI) for all CMIP6/HighResMIP
% models and DUACS observations. Saves GSDI_all.mat.


% path containing CMIP models
CMIP_path='/var/qnas/Ion/CMIP6/';

thr=0.5;
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
model_list=[
    "0DUACS"
    "CanESM5-1"

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

        [gsdi,timeD,~,~,~]=GSDI(lon,lat,time,adt,thr);
        
        % if nan, GSDI=42ºW
        gsdi(isnan(gsdi))=-42;

        % trend
        cutoff = datenum('15-Jan-2014');
        idx = timeD >= cutoff;  % only times after cutoff

        time_cut=timeD(idx);
        time_cut=(time_cut-time_cut(1))./365;%pass to years
        GSDI_cut=gsdi(idx);

        %Fit linear trend to mean series
        lm = fitlm(time_cut, GSDI_cut);

        %trend and p_value
        trend   = lm.Coefficients.Estimate(2)*10;   % from units/yr pass to units/decade
        pval = lm.Coefficients.pValue(2);

        % store following structure: model/ensemble/GSI, GSI_km, GSI_vel_mo, max_vel_mo, time_GSI, time_vel_mo, lon, lat, lon_GSI, lat_GSI, MDT, SLA_std
        % be aware that fields cant start by numbers so remove 0 from DUACS models
        if startsWith(model_name,'0')
            model_name_clean=model_name(2:end);
        else
            model_name_clean=model_name;
        end
        model_name_clean=matlab.lang.makeValidName(model_name_clean);

        GSDI_data.(model_name_clean).(ens_name).time=timeD;
        GSDI_data.(model_name_clean).(ens_name).GSDI=gsdi;
        GSDI_data.(model_name_clean).(ens_name).trend=trend;
        GSDI_data.(model_name_clean).(ens_name).pval=pval;
    end
end
% store GSI_data structure to a .mat file
save('../mat/GSDI_all.mat','GSDI_data','model_name_clean','-v7.3');
