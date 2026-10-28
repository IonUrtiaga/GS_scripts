% plot_Fig3.m
% Author: Ion Urtiaga-Chasco (2026), ion.urtiaga@ulpgc.es
%
% Figure 3: Composite differences (northward minus southward GS state) of
%   atmospheric variables for CanESM5-1 (ensemble mean).
%   Left column: historical period (1900-1940). Right column: future (2050-2090).
%   Rows: (a-b) tas, (c-d) hus, (e-f) P-E, (g-h) WSC.

clear all
close all

outpath = '../pdf/';

vars     = {'tas', 'hus', 'pr_ev', 'wsc'};
unts     = {'\circ C (atm)', 'g/kg', '10^-^5 kg m^-^2 S^-^1', '10^-^8 N m^-^3'};
lims_min = [-2, -1, -0.4, -1];
lims_max = [ 2,  1,  0.4,  1];
clor     = {'balance', 'diff', 'tarn', 'RdGy'};
lab      = {'a','b','c','d','e','f','g','h'};

% Load GSI 16-point locations from GSI_all.mat
load('../mat/GSI_all.mat', 'GSI_data')
lon16 = GSI_data.DUACS.r1i1p1f1.lon_GSI;
lat16 = GSI_data.DUACS.r1i1p1f1.lat_GSI;

figure
ha = tight_subplot(4, 2, [0.015 0.05], [0.03 0.03], [0.15 0.15]);

for v = 1:length(vars)
    varname = vars{v};
    disp(varname)

    % Load and average across ensembles
    var_plot = [];
    for r_ens = 1:5
        file = sprintf('../mat/%s_MxMn_%d.mat', varname,r_ens);
        if exist(file, 'file') == 2
            load(file)
            var_plot(:,:,1,r_ens) = var_MxMn(:,:,1) - var_MxMn(:,:,2); % N_pre  - S_pre
            var_plot(:,:,2,r_ens) = var_MxMn(:,:,3) - var_MxMn(:,:,4); % N_post - S_post
        end
    end
    var_plot = tsnanmean(var_plot, 4);

    % Unit conversion
    if strcmp(varname, 'hus'),   var_plot = var_plot * 1000;  end
    if strcmp(varname, 'pr_ev'), var_plot = var_plot * 1E5;   end
    if strcmp(varname, 'wsc'),   var_plot = var_plot * 1E8;   end

    for mm = 1:2
        ax = ha(2*v + mm - 2);
        axes(ax)
        m_proj('mercator', 'lon', [lon(1) lon(end)], 'lat', [lat(1) lat(end)]);
        m_pcolor(lon, lat, var_plot(:,:,mm)'); shading interp; hold on

        % Colormap
        if v == 4
            cl = brewermap([], clor{v});
        else
            cl = cmocean(clor{v});
        end
        if v == 2, cl = flipud(cl); end
        ax.Colormap = cl;
        caxis(ax, [lims_min(v), lims_max(v)])

        % GS 16 points
        for ii = 1:length(lat16)
            m_line(lon16(ii), lat16(ii), 'marker', '.', 'markersize', 8, 'color', 'k');
        end
        m_gshhs_i('color', 'k');

        % Grid (suppress tick labels except bottom-left panel)
        if v ~= 4
            switch mm
                case 1; m_grid('linestyle','none','box','fancy','tickdir','out','fontsize',12,'xticklabels',['','','',''],'yticklabels',['','','','']);
                case 2; m_grid('linestyle','none','box','fancy','tickdir','out','fontsize',12,'xticklabels',['','','','']);
            end
        else
            switch mm
                case 1; m_grid('linestyle','none','box','fancy','tickdir','out','fontsize',12,'yticklabels',['','','','']);
                case 2; m_grid('linestyle','none','box','fancy','tickdir','out','fontsize',12);
            end
        end

        m_text(-75.5, 60, lab(2*v+mm-2), 'Fontweight', 'bold')

        % Period labels
        if v==1 && mm==1, m_text(-50, 67, '1900-1940', 'fontweight', 'bold'); end
        if v==1 && mm==2, m_text(-50, 67, '2050-2090', 'fontweight', 'bold'); end

        % Colorbar (right column only)
        if mm == 2
            c = colorbar(ax, 'Eastoutside');
            axpos = ax.Position;
            c.Position    = [axpos(1)+axpos(3)+0.01, axpos(2), 0.015, axpos(4)];
            c.FontSize    = 12;
            c.Label.String    = unts(v);
            c.Label.FontSize  = 14;
            c.Label.FontWeight = 'bold';
            c.Ticks       = linspace(lims_min(v), lims_max(v), 5);
            c.TickLabels  = arrayfun(@(x) sprintf('%.1f', x), c.Ticks, 'UniformOutput', false);
        end
    end
end

set(gcf, 'Units', 'pixels', 'Position', [500, 150, 790, 1000]);
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 12)
set(findall(gcf, '-property', 'FontName'), 'FontName', 'Times New Roman')
exportgraphics(gcf, [outpath, 'Fig3.pdf'], 'ContentType', 'vector')
