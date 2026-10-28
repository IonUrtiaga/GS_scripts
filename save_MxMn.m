% save_MxMn.m
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%
% Computes composite means of atmospheric/oceanic variables for northward (N)
% and southward (S) GS states in two periods: historical (1900-1940) and
% future (2050-2090), for CanESM5-1 ensemble members.
% Output structure per variable and ensemble: var_MxMn(:,:,1-4)
%   1: N-pre, 2: S-pre, 3: N-post, 4: S-post
% Saves {varname}_MxMn_Composite_notanom_{ens}.mat per ensemble.

clear all
close all

vars = {'tas', 'zos', 'hus', 'wsc', 'pr_ev'};

for v = 1:length(vars)
    varname = vars{v};
    disp(varname)

    for r_ens = 1:5
        disp(sprintf('Ensemble: r%di1p1f1', r_ens))

        ftime  = sprintf('../mat/time_MxMn_%d.mat', r_ens);
        fstore = sprintf('../mat/%s_MxMn_%d.mat', varname, r_ens);

        if exist(fstore, 'file') == 2
            disp('    Already computed, skipping.'); continue
        end

        load(ftime)

        % Load variable
        if ismember(varname, {'tos','tas'})
            fvar = sprintf('/var/qnas/Ion/CMIP6/ALL-r%di1p1f1/CanESM5-1/%s/%s.nc', r_ens, varname, varname);
        elseif ismember(varname, {'zos','psl'})
            fvar = sprintf('/var/qnas/Ion/CMIP6/ALL-r%di1p1f1/CanESM5-1/%s/%s2.nc', r_ens, varname, varname);
        elseif ismember(varname, {'wsc'})
            file_u = sprintf('/var/qnas/Ion/CMIP6/ALL-r%di1p1f1/CanESM5-1/newvars/ua/ua.nc', r_ens);
            file_v = sprintf('/var/qnas/Ion/CMIP6/ALL-r%di1p1f1/CanESM5-1/newvars/va/va.nc', r_ens);
            fvar   = file_u;
        elseif ismember(varname, {'pr_ev'})
            fvar = sprintf('/var/qnas/Ion/CMIP6/ALL-r%di1p1f1/CanESM5-1/newvars/pr/pr.nc', r_ens);
            fev  = sprintf('/var/qnas/Ion/CMIP6/ALL-r%di1p1f1/CanESM5-1/newvars/evspsbl/evspsbl.nc', r_ens);
        else
            fvar = sprintf('/var/qnas/Ion/CMIP6/ALL-r%di1p1f1/CanESM5-1/newvars/%s/%s.nc', r_ens, varname, varname);
        end

        % Read variable
        if ismember(varname, {'wsc'})
            u   = squeeze(ncread(file_u, 'ua')); u = squeeze(u(:,:,1,:));
            v   = squeeze(ncread(file_v, 'va')); v = squeeze(v(:,:,1,:));
            lon = ncread(file_u, 'longitude');
            lat = ncread(file_u, 'latitude');
            for tt = 1:size(u,3)
                var(:,:,tt) = ra_windstrcurl(lat, lon, u(:,:,tt)', v(:,:,tt)')';
            end
        elseif ismember(varname, {'pr_ev'})
            var = ncread(fvar,'pr') - ncread(fev,'evspsbl');
            lon = ncread(fvar,'longitude');
            lat = ncread(fvar,'latitude');
        else
            var = ncread(fvar, varname);
            lon = ncread(fvar, 'longitude');
            lat = ncread(fvar, 'latitude');
        end

        % Squeeze 4D variables
        if ndims(var) == 4, var = squeeze(var(:,:,1,:)); end

        % Read and convert time
        time = timenc2datenum(fvar, 'time');

        % Verify time consistency with GS periods
        kk = tsnansum(time_pos - time(indpos));
        if kk ~= 0, error('Time mismatch for %s r%d', varname, r_ens); end

        % Separate pre (1900-1940)/post (2050-2090) periods
        [~,ind1950] = min(abs(time - datenum(1950,1,1)));
        [~,ind2050] = min(abs(time - datenum(2050,1,1)));
        indpos_pre  = indpos(indpos <= ind1950);
        indpos_post = indpos(indpos >  ind1950);
        indneg_pre  = indneg(indneg <= ind2050);
        indneg_post = indneg(indneg >  ind2050);

        % Composite means: (1) N-pre, (2) S-pre, (3) N-post, (4) S-post
        var_MxMn = nan(length(lon), length(lat), 4);
        var_MxMn(:,:,1) = tsnanmean(var(:,:,indpos_pre),  3);
        var_MxMn(:,:,2) = tsnanmean(var(:,:,indneg_pre),  3);
        var_MxMn(:,:,3) = tsnanmean(var(:,:,indpos_post), 3);
        var_MxMn(:,:,4) = tsnanmean(var(:,:,indneg_post), 3);

        save(fstore, 'lon', 'lat', 'var_MxMn')
        disp('    Saved.')
    end
end
