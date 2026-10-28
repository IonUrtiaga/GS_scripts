% save_GS_periods.m
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%
% Identifies northward (positive) and southward (negative) GS states for
% CanESM5-1 ensemble members based on a 5-year low-pass filtered GSPI.
% Two periods are considered: historical (1900-1940) and future (2050-2090).
% Saves time_MxMn_X.mat per ensemble.

clear all
close all

Nstd = 1;  % number of std deviations defining northward/southward states

fGS_all = '../mat/GSI_all.mat';
load(fGS_all)

for r_ens = 1:5
    disp(sprintf('Ensemble: r%di1p1f1', r_ens))

    ens    = sprintf('r%di1p1f1', r_ens);
    GS16_m = GSI_data.CanESM5_1.(ens).GSI_km;
    time   = GSI_data.CanESM5_1.(ens).time_GSI;
    GS16   = (GS16_m - tsnanmean(GS16_m)) ./ tsnanstd(GS16_m); % normalize

    % 5-year Butterworth low-pass filter
    n = 3; ff = 60; fq = 1;
    wn = fq / (ff/2);
    [B,A] = butter(n, wn);
    GS16_f = filtfilt(B, A, GS16);

    % Period boundaries
    [~,ind]  = min(abs(time - datenum('19000101','yyyymmdd')));
    [~,ind1] = min(abs(time - datenum('19400101','yyyymmdd')));
    [~,ind2] = min(abs(time - datenum('20500101','yyyymmdd')));
    [~,ind3] = min(abs(time - datenum('20900101','yyyymmdd')));
    ind = [ind, ind1-1, ind2, ind3];

    GS16_mm = GS16;
    GS16    = GS16_f; % work on filtered series

    time_pos = []; time_neg = [];
    mn = zeros(1,2); std_p = zeros(1,2);

    for p = 1:2
        time_p  = time(ind(1+2*(p-1)):ind(2+2*(p-1)));
        GS16_p  = GS16(ind(1+2*(p-1)):ind(2+2*(p-1)));
        mn_p    = tsnanmean(GS16_p);
        std_pp  = tsnanstd(GS16_p);
        mn(p)   = mn_p;
        std_p(p)= std_pp;

        % Northward and southward states
        indp = find(GS16_p >= (mn_p + std_pp * Nstd));
        indn = find(GS16_p <= (mn_p - std_pp * Nstd));
        time_pos = [time_pos; time_p(indp)];
        time_neg = [time_neg; time_p(indn)];
    end

    [isMember, ~] = ismember(time, time_pos);
    indpos = find(isMember);
    [isMember, ~] = ismember(time, time_neg);
    indneg = find(isMember);

    GS16_f = GS16;
    GS16   = GS16_mm;
    std    = std_p;

    save(sprintf('../mat/time_MxMn_%d.mat', r_ens), 'time_pos', 'time_neg', 'indpos', 'indneg', 'time', 'GS16', 'GS16_f', 'mn', 'std')
end
