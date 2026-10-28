% plot_Fig2.m
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%
% Figure 2: GS destabilization point (GSDI) time series for CanESM5-1 (historical + SSP5-8.5).

clear all
close all

save_path = '../pdf/';

% Load GSDI
load('../mat/GSDI_all.mat');

%% Multi-model ensemble mean
model_list = fieldnames(GSDI_data);
model_list = model_list(3:end);
num_models = numel(model_list);
ensemble_lists = cell(num_models, 1);

max_ensembles = 0;
for i = 1:num_models
    model_name     = model_list{i};
    ensemble_list  = fieldnames(GSDI_data.(model_name));
    ensemble_lists{i} = ensemble_list;
    max_ensembles  = max(max_ensembles, numel(ensemble_list));
end

for yy = 1850:2100
    time_i(yy-1849) = datenum(yy,1,1);
end

% Interpolate each ensemble to common time axis and average
for i = 1:num_models
    model_name    = model_list{i};
    ensemble_list = ensemble_lists{i};
    nn = 1;
    for j = 1:numel(ensemble_list)
        ensemble_name = ensemble_list{j};
        if isfield(GSDI_data.(model_name), ensemble_name)
            GSDI   = GSDI_data.(model_name).(ensemble_name).GSDI;
            time   = GSDI_data.(model_name).(ensemble_name).time;
            GSDI_i = interp1(time, GSDI, time_i);
            GSDI_ens(:,nn) = GSDI_i;
            nn = nn + 1;
        end
    end
    GSDI_all(:,i) = tsnanmean(GSDI_ens, 2);
end

GSDI_mean = tsnanmean(GSDI_all, 2);
GSDI_std  = tsnanstd(GSDI_all');
GSDI_min  = GSDI_mean - GSDI_std';
GSDI_max  = GSDI_mean + GSDI_std';

%% CanESM5-1 ensemble mean ± std
for r_ens = 1:5
    ens = sprintf('r%di1p1f1', r_ens);
    GSDI_allCan(:,r_ens) = GSDI_data.CanESM5_1.(ens).GSDI;
    time = GSDI_data.CanESM5_1.(ens).time;
end

CANmean = tsnanmean(GSDI_allCan, 2);
CANstd  = tsnanstd(GSDI_allCan, 0, 2);
CANmin  = CANmean - CANstd;
CANmax  = CANmean + CANstd;
CANtime = time;

%% Plot
figure; hold on

% Historical/SSP5-8.5 separator
ySep = datenum(2014,1,1);
plot([-85 -30], [ySep ySep], '--', 'Color', [0 0 0], 'LineWidth', 1.5);

% CanESM5-1 ensemble mean ± std
fill([CANmin', fliplr(CANmax')], [CANtime, fliplr(CANtime)], [0.4 0.4 0.4], ...
    'FaceAlpha', 0.5, 'EdgeColor', 'none');
plot(CANmean, time_i, 'color', [0 0 0], LineWidth=2)

datetick('y')
xlabel('GS Destabilization point', 'FontSize', 12, FontWeight='bold')
xticks(-75:5:-40)
xticklabels({'75ºW','70ºW','65ºW','60ºW','55ºW','50ºW','45ºW','40ºW'})

% Custom legend
axPos  = get(gca,'Position');
x0     = axPos(1) + 0.03*axPos(3) + .5;
y0     = axPos(2) + 0.035*axPos(4) + .68;
dy     = 0.035*axPos(4);
iconW  = 0.040*axPos(3);
iconH  = 0.020*axPos(4);
txtW   = 0.28*axPos(3);
lineYofs = 0.5*iconH;

annotation('rectangle', [x0 y0+2*dy iconW iconH], ...
    'FaceColor', [0.4 0.4 0.4], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
annotation('line', [x0 x0+iconW], [y0+2*dy+lineYofs y0+2*dy+lineYofs], ...
    'Color', [0 0 0], 'LineWidth', 2);
annotation('textbox', [x0+1.35*iconW y0+2*dy-0.006 txtW iconH+0.01], ...
    'String', 'CanESM5-1', 'EdgeColor', 'none', 'VerticalAlignment', 'middle');

plot([-85 -30], [ySep ySep], '--', 'Color', [0 0 0], 'LineWidth', 1.5);
axis([-65 -38 datenum(1850,1,1) datenum(2100,1,1)])
xl = xlim;

text(xl(2)-.8, datenum(1975,1,1), 'Historical', 'HorizontalAlignment', 'center', ...
    'FontSize', 11, 'FontWeight', 'bold', 'Color', [0 0 0], 'Rotation', 90);
text(xl(2)-.8, datenum(2045,1,1), 'ssp-585', 'HorizontalAlignment', 'center', ...
    'FontSize', 11, 'FontWeight', 'bold', 'Color', [0 0 0], 'Rotation', 90);

fs = 12; fn = 'Times New Roman';
set(findall(gcf, '-property', 'FontSize'), 'FontSize', fs);
set(findall(gcf, '-property', 'FontName'), 'FontName', fn);
set(gcf, 'Units', 'pixels', 'Position', [500, -350, 500, 900]);

ax = gca; box(ax,'on'); ax.Layer = 'bottom';
exportgraphics(gcf, [save_path 'Fig2.pdf'], 'ContentType', 'vector');

%% Summary statistics
idx0  = find(time_i >= datenum(2000,1,1) & time_i < datenum(2030,1,1));
can0  = tsnanmean(CANmean(idx0));
mm0   = tsnanmean(GSDI_mean(idx0));

idx0  = find(time_i >= datenum(2070,1,1) & time_i < datenum(2100,1,1));
can70 = tsnanmean(CANmean(idx0));
mm70  = tsnanmean(GSDI_mean(idx0));

disp(sprintf('###  2000-2030 GSDI  ### \nCanESM5-1: %.2fºW\nMulti-Model: %.2fºW', can0, mm0))
disp(sprintf('###  2070-2100 GSDI  ### \nCanESM5-1: %.2fºW\nMulti-Model: %.2fºW', can70, mm70))
