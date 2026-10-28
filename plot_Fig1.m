% plot_Fig1.m
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%
% Generates Figure 1:
%   a) SLA std and MDT map for DUACS
%   b) SLA std and MDT map for CanESM5-1 (ensemble mean)
%   c) Observed GSI and GSPI time series (DUACS, 1993-2025)
%   d) GSI and GSPI for CanESM5-1 (historical + SSP5-8.5, 1850-2100)

clear all
close all

outpath  = '../pdf/';
fGS_all  = '../mat/GSI_all.mat';

%% Load SLA std, MDT and GS16 points from GSI_all.mat
load(fGS_all)

% DUACS (r1i1p1f1)
lon      = GSI_data.DUACS.r1i1p1f1.lon;
lat      = GSI_data.DUACS.r1i1p1f1.lat;
std_sla  = GSI_data.DUACS.r1i1p1f1.SLA_std;
MDT      = GSI_data.DUACS.r1i1p1f1.MDT;
lon16    = GSI_data.DUACS.r1i1p1f1.lon_GSI;
lat16    = GSI_data.DUACS.r1i1p1f1.lat_GSI;

% CanESM5-1 ensemble mean
for r_ens = 1:5
    ens = sprintf('r%di1p1f1', r_ens);
    if isfield(GSI_data.CanESM5_1, ens)
        std_all(:,:,r_ens) = GSI_data.CanESM5_1.(ens).SLA_std;
        MDT_all(:,:,r_ens) = GSI_data.CanESM5_1.(ens).MDT;
        lon16_all(:,r_ens) = GSI_data.CanESM5_1.(ens).lon_GSI;
        lat16_all(:,r_ens) = GSI_data.CanESM5_1.(ens).lat_GSI;
    end
end
std_mean   = tsnanmean(std_all, 3);
MDT_mean   = tsnanmean(MDT_all, 3);
lon16_mean = tsnanmean(lon16_all,2);
lat16_mean = tsnanmean(lat16_all, 2);
lon_can    = GSI_data.CanESM5_1.r1i1p1f1.lon;
lat_can    = GSI_data.CanESM5_1.r1i1p1f1.lat;

%% Figure layout: 3x2 grid, panels 3-4 and 5-6 merged
ha = tight_subplot(3, 2, [0.03 0.04], [0.03 0.03], [0.15 0.15]);

% Merge panels 3-4
pos3 = get(ha(3), 'Position'); pos4 = get(ha(4), 'Position');
set(ha(3), 'Position', [min(pos3(1),pos4(1)), min(pos3(2),pos4(2))+.02, ...
    max(pos3(1)+pos3(3),pos4(1)+pos4(3))-min(pos3(1),pos4(1)), ...
    max(pos3(2)+pos3(4),pos4(2)+pos4(4))-min(pos3(2),pos4(2))]);
set(ha(4), 'Visible', 'off');

% Merge panels 5-6
pos5 = get(ha(5), 'Position'); pos6 = get(ha(6), 'Position');
set(ha(5), 'Position', [min(pos5(1),pos6(1)), min(pos5(2),pos6(2))-.01, ...
    max(pos5(1)+pos5(3),pos6(1)+pos6(3))-min(pos5(1),pos6(1)), ...
    max(pos5(2)+pos5(4),pos6(2)+pos6(4))-min(pos5(2),pos6(2))]);
set(ha(6), 'Visible', 'off');

%% Panel b: CanESM5-1 SLA std and MDT
axes(ha(2))
m_proj('mercator', 'lon', [lon_can(1) lon_can(end)], 'lat', [lat_can(1) lat_can(end)]);
m_pcolor(lon_can, lat_can, std_mean'.*100); colormap(brewermap([], 'YlOrRd')); shading interp; caxis([6 12]); hold on
levels = -80:20:100;
[cs,h] = m_contour(lon_can, lat_can, MDT_mean'.*100, levels, 'color', 'k');
clabel(cs, h, 'fontsize', 11, 'labelspacing', 200, 'color', 'k')
[cs,h] = m_contour(lon_can, lat_can, MDT_mean'.*100, [-200 -200], 'color', 'r');
clabel(cs, h, 'fontsize', 11, 'labelspacing', 200, 'color', 'r')
for ii = 1:length(lat16_mean)
    m_line(lon16_mean(ii), lat16_mean(ii), 'marker', '.', 'markersize', 8, 'color', 'k');
end
m_gshhs_i('color', 'k');
m_grid('linestyle', 'none', 'box', 'fancy', 'tickdir', 'out', 'fontsize', 12);

% Colorbar
ax = ha(2); c = colorbar(ax, 'Eastoutside');
axpos = ax.Position;
c.Position = [axpos(1)+axpos(3)+0.01, axpos(2)+.01, 0.01, axpos(4)-.02];
c.Label.FontWeight = 'bold';
c.Ticks = 6:2:12;
c.TickLabels = arrayfun(@(x) sprintf('%.0f', x), c.Ticks, 'UniformOutput', false);
m_text(-77, 45, 'b', 'Fontweight', 'bold')
m_text(-75, 45, 'CanESM5-1')

%% Panel a: DUACS SLA std and MDT
% Overlay CanESM5-1 GS16 points in blue for comparison
for ii = 1:length(lat16_mean)
    m_line(lon16_mean(ii), lat16_mean(ii), 'marker', '.', 'markersize', 8, 'color', 'b');
end

axes(ha(1))
m_proj('mercator', 'lon', [lon(1) lon(end)], 'lat', [lat(1) lat(end)]);
m_pcolor(lon, lat, std_sla'.*100); colormap(brewermap([], 'YlOrRd')); shading interp; caxis([0 40]); hold on
[cs,h] = m_contour(lon, lat, MDT'.*100, -80:20:100, 'color', 'k');
clabel(cs, h, 'fontsize', 11, 'labelspacing', 200, 'color', 'k')
[cs,h] = m_contour(lon, lat, MDT'.*100, [-200 -200], 'color', 'r');
clabel(cs, h, 'fontsize', 11, 'labelspacing', 200, 'color', 'r')
for ii = 1:length(lon16)
    m_line(lon16(ii), lat16(ii), 'marker', '.', 'markersize', 8, 'color', 'b');
end
m_gshhs_i('color', 'k');
m_grid('linestyle', 'none', 'box', 'fancy', 'tickdir', 'out', 'fontsize', 12, 'yticklabels', ['','','','']);

% Colorbar
ax = ha(1); c = colorbar(ax, 'Westoutside');
axpos = ax.Position;
c.Position = [axpos(1)-0.015-0.01, axpos(2)+.01, 0.01, axpos(4)-.02];
c.AxisLocation = 'out';
c.Label.FontWeight = 'bold';
c.Ticks = 0:10:40;
c.TickLabels = arrayfun(@(x) sprintf('%.0f', x), c.Ticks, 'UniformOutput', false);
m_text(-77, 45, 'a', 'Fontweight', 'bold')
m_text(-75, 45, 'DUACS')

% RMSE between DUACS and CanESM5-1 ensemble-mean GS16 latitudes
latdiff    = lat16_mean - lat16';
latdiff    = latdiff(~isnan(latdiff));
rmse_lat16 = sqrt(mean(latdiff.^2));

%% Panel c: Observed GSI and GSPI (DUACS, 1993-2025)
file_adt = '/media/disk/smbdata/Ion/GS_Scripts/Round1/Updated_Figs/cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.125deg_P1D_adt_75.94W-45.06W_33.06N-45.94N_1993-01-01-2025-10-18.nc';
lon  = double(ncread(file_adt, 'longitude'));
lat  = double(ncread(file_adt, 'latitude'));
adt  = ncread(file_adt, 'adt');
time = double(timenc2datenum(file_adt, 'time'));

% Pass to monthly
adt_mo = []; time_mo = []; n = 1;
for yy = year(time(1)):year(time(end))
    for mm = 1:12
        indt = find(month(time)==mm & year(time)==yy);
        adt_mo(:,:,n) = tsnanmean(adt(:,:,indt), 3);
        time_mo(n)    = datenum(yy, mm, 15);
        n = n + 1;
    end
end
time = time_mo; adt = adt_mo;

% Compute GSI (Pérez-Hernández & Joyce, 2013) and GSPI
[GSI,    time_GSI, lon_GSI, lat_GSI] = GS_Index(lon, lat, time, adt);
[GSI_km, time_GSI, lon_GSI, lat_GSI] = GS_Index_km(lon, lat, time, adt, 3E-3);
[GSI_vel] = GSPI(lon, lat, time, adt);

% Convert GSPI from degrees to km anomaly
GSI_vel = (GSI_vel - tsnanmean(GSI_vel)) .* 60 .* 1.852;

% Decadal mean and std
ind(1) = 1;
[~,ind(2)] = min(abs(time - datenum(2003,1,1)));
[~,ind(3)] = min(abs(time - datenum(2013,1,1)));
ind(4) = length(time) + 1;
for ii = 1:3
    mn(ii)     = tsnanmean(GSI_km(ind(ii):ind(ii+1)-1));
    std_d(ii)  = tsnanstd(GSI_km(ind(ii):ind(ii+1)-1));
    mn_vel(ii) = tsnanmean(GSI_vel(ind(ii):ind(ii+1)-1));
    std_vel(ii)= tsnanstd(GSI_vel(ind(ii):ind(ii+1)-1));
end

GSIv_color = [0.8500 0.3250 0.0980];
GSI_color  = [0 0.4470 0.7410];

axes(ha(3)); hold on

% Decadal statistics
for ii = 1:3
    plot([time(ind(ii)) time(ind(ii+1)-1)], [mn(ii) mn(ii)],                 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5)
    plot([time(ind(ii)) time(ind(ii+1)-1)], [mn(ii)+std_d(ii) mn(ii)+std_d(ii)], 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5, 'LineStyle', '--')
    plot([time(ind(ii)) time(ind(ii+1)-1)], [mn(ii)-std_d(ii) mn(ii)-std_d(ii)], 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5, 'LineStyle', '--')
    if ii > 1, xline(time(ind(ii)), 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2, 'LineStyle', '--'); end
end
clor = [0.9250 0.6625 0.5490];
for ii = 1:3
    plot([time(ind(ii)) time(ind(ii+1)-1)], [mn_vel(ii) mn_vel(ii)],                     'Color', clor, 'LineWidth', 1.5)
    plot([time(ind(ii)) time(ind(ii+1)-1)], [mn_vel(ii)+std_vel(ii) mn_vel(ii)+std_vel(ii)], 'Color', clor, 'LineWidth', 1.5, 'LineStyle', '--')
    plot([time(ind(ii)) time(ind(ii+1)-1)], [mn_vel(ii)-std_vel(ii) mn_vel(ii)-std_vel(ii)], 'Color', clor, 'LineWidth', 1.5, 'LineStyle', '--')
end

% GSI and GSPI time series
plot(time, GSI_km,  'Color', 'k',        'LineWidth', 2)
plot(time, GSI_vel, 'Color', GSIv_color, 'LineWidth', 2)

% Pearson correlation
idx = find(~isnan(GSI_km));
[r, ~] = corr(GSI_km(idx), GSI_vel(idx), 'Type', 'Pearson');
text(datenum(2015,1,1), -70, sprintf('r = %.2f (95%% sig., lag = 0)', r))

% Green box (DUACS observation period)
xShaded = [datenum(1993,1,3), datenum(2025,12,31), datenum(2025,12,31), datenum(1993,1,3), datenum(1993,1,3)];
yShaded = [min([GSI_vel' GSI_km'])-.01, min([GSI_vel' GSI_km'])-.01, max([GSI_vel' GSI_km'])+.01, max([GSI_vel' GSI_km'])+.01, min([GSI_vel' GSI_km'])-.01];
plot(xShaded, yShaded, '-', 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2)
datetick('x')

ylabel('GSI (km)', 'FontWeight', 'bold')
axis([datenum(1993,1,1) datenum(2026,1,1) min([GSI_vel' GSI_km'])-.02 max([GSI_vel' GSI_km'])+.02])
ax = gca; ax.Box = 'on';
yr = 1993:5:2025; ax.XTick = datenum(yr,1,1); ax.XTickLabel = yr;
ax.YAxis.Exponent = 0; ytickformat('%.0f'); ax.YAxis.TickLabelInterpreter = 'tex';

% Reorder children so green box is behind data
children = ax.Children;
ax.Children = [children(2:end); children(1)];

% Custom legend
axPos = get(gca, 'Position');
x0 = axPos(1) + 0.76*axPos(3)+.1; y0 = axPos(2) + 0.07*axPos(4)-.035;
dy = 0.060*axPos(4); iconW = 0.030*axPos(3); iconH = 0.050*axPos(4);
txtW = 0.28*axPos(3); lineYofs = 0.5*iconH;
annotation('line', [x0 x0+iconW], [y0+3*dy+lineYofs y0+3*dy+lineYofs], 'Color', [0 0 0], 'LineWidth', 2);
annotation('textbox', [x0+1.35*iconW y0+3*dy-0.006 txtW iconH+0.01], 'String', 'GSI',  'EdgeColor', 'none', 'VerticalAlignment', 'middle');
annotation('line', [x0 x0+iconW], [y0+2*dy+lineYofs y0+2*dy+lineYofs], 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2);
annotation('textbox', [x0+1.35*iconW y0+2*dy-0.006 txtW iconH+0.01], 'String', 'GSPI', 'EdgeColor', 'none', 'VerticalAlignment', 'middle');
text(datenum(1993,6,1), 71, 'c', 'Fontweight', 'bold')

%% Panel d: CanESM5-1 GSI and GSPI (historical + SSP5-8.5)
fGS_all = '../mat/GSI_all.mat';
load(fGS_all)

% 3-year Butterworth low-pass filter
n = 3; fc = 1/(3*12); fs = 1; [B,A] = butter(n, fc/(fs/2));

for r_ens = 1:5
    ens = sprintf('r%di1p1f1', r_ens);
    GSI    = GSI_data.CanESM5_1.(ens).GSI_km;
    GSIvel = GSI_data.CanESM5_1.(ens).GSI_vel_mo;
    time   = GSI_data.CanESM5_1.(ens).time_GSI;
    GSI_f    = filtfilt(B, A, GSI);
    GSIvel_f = filtfilt(B, A, GSIvel);
    GSIvel_f = (GSIvel_f - tsnanmean(GSIvel_f)) .* 60 * 1.852;
    GSI_all_f(:,r_ens)    = GSI_f;
    GSIvel_all_f(:,r_ens) = GSIvel_f;
end

GSI_mean    = tsnanmean(GSI_all_f, 2);    GSI_std    = tsnanstd(GSI_all_f, 0, 2);
GSIvel_mean = tsnanmean(GSIvel_all_f, 2); GSIvel_std = tsnanstd(GSIvel_all_f, 0, 2);
time = time';

axes(ha(5)); hold on

% Historical/SSP585 separator
xSep = datenum(2014,1,1);
plot([xSep xSep], [-100 150], '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);

% CanESM5-1 ensemble mean ± std
fill([time, fliplr(time)], [GSI_mean-GSI_std; flipud(GSI_mean+GSI_std)]', [0.4 0.4 0.4], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
plot(time, GSI_mean, 'color', [0 0 0], 'LineWidth', 2)
fill([time, fliplr(time)], [GSIvel_mean-GSIvel_std; flipud(GSIvel_mean+GSIvel_std)]', [0.8500 0.3250 0.0980], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
plot(time, GSIvel_mean, 'color', [0.8500 0.3250 0.0980], 'LineWidth', 2)

% DUACS filtered series
GSI_km  = GSI_data.DUACS.r1i1p1f1.GSI_km;
GSI_vel = GSI_data.DUACS.r1i1p1f1.GSI_vel_mo;
time    = GSI_data.DUACS.r1i1p1f1.time_GSI;
indnan  = min(find(isnan(GSI_km)));
time    = time(1:indnan-1); GSI_km = GSI_km(1:indnan-1); GSI_vel = GSI_vel(1:indnan-1);
GSI_f    = filtfilt(B, A, GSI_km);
GSIvel_f = filtfilt(B, A, GSI_vel);
GSIvel_f = (GSIvel_f - tsnanmean(GSIvel_f)) .* 60 * 1.852;
plot(time, GSI_f,    ':', 'Color', [0 0 0],              'LineWidth', 2)
plot(time, GSIvel_f, ':', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2)

% Green box (DUACS observation period)
xShaded = [datenum(1993,1,1), datenum(2025,12,31), datenum(2025,12,31), datenum(1993,1,1), datenum(1993,1,1)];
yShaded = [-95, -95, 110, 110, -950];
plot(xShaded, yShaded, 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2)

text(datenum(1935,1,1), 100, 'Historical', 'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.4 0.4 0.4]);
text(datenum(2055,1,1), 100, 'ssp-585',    'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.4 0.4 0.4]);

% Custom legend
axPos = get(gca, 'Position');
x0 = axPos(1) + 0.76*axPos(3); y0 = axPos(2) + 0.07*axPos(4)-.01;
dy = 0.060*axPos(4); iconW = 0.030*axPos(3); iconH = 0.050*axPos(4);
txtW = 0.28*axPos(3); lineYofs = 0.5*iconH;
annotation('rectangle', [x0 y0+3.6*dy iconW iconH], 'FaceColor', [0.4 0.4 0.4], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
annotation('line', [x0 x0+iconW], [y0+3.6*dy+lineYofs y0+3.6*dy+lineYofs], 'Color', [0 0 0], 'LineWidth', 2);
annotation('textbox', [x0+1.35*iconW y0+3.6*dy-0.006 txtW iconH+0.01], 'String', 'GSI (CanESM5-1)',  'EdgeColor', 'none', 'VerticalAlignment', 'middle');
annotation('rectangle', [x0 y0+2.4*dy iconW iconH], 'FaceColor', [0.8500 0.3250 0.0980], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
annotation('line', [x0 x0+iconW], [y0+2.4*dy+lineYofs y0+2.4*dy+lineYofs], 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2);
annotation('textbox', [x0+1.35*iconW y0+2.4*dy-0.006 txtW iconH+0.01], 'String', 'GSPI (CanESM5-1)', 'EdgeColor', 'none', 'VerticalAlignment', 'middle');
annotation('line', [x0 x0+iconW], [y0+1.2*dy+lineYofs y0+1.2*dy+lineYofs], 'Color', [0 0 0], 'LineWidth', 2, 'LineStyle', ':');
annotation('textbox', [x0+1.35*iconW y0+1.2*dy-0.006 txtW iconH+0.01], 'String', 'GSI (DUACS)',  'EdgeColor', 'none', 'VerticalAlignment', 'middle');
annotation('line', [x0 x0+iconW], [y0+0*dy+lineYofs y0+0*dy+lineYofs], 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2, 'LineStyle', ':');
annotation('textbox', [x0+1.35*iconW y0+0*dy-0.006 txtW iconH+0.01], 'String', 'GSPI (DUACS)', 'EdgeColor', 'none', 'VerticalAlignment', 'middle');

yticks(-100:50:150)
ylabel('GSI (km)', 'FontSize', 12, 'FontWeight', 'bold')
ax = gca; ax.YTickLabel = ax.YTick; ax.YAxis.TickLabelInterpreter = 'tex';
axis([datenum(1850,1,1) datenum(2100,1,1) -95 110])
datetick('x', 'keeplimits')
box(ax, 'on'); ax.Layer = 'bottom';
text(datenum(1852,6,1), 95, 'd', 'Fontweight', 'bold')

%% Export
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 12)
set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman')
set(gcf, 'Units', 'pixels', 'Position', [500, -150, 1300, 750]);
exportgraphics(gcf, [outpath, 'Fig1.pdf'], 'ContentType', 'vector')