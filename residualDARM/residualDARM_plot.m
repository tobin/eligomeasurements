%% Plot residual DARM displacement spectrum
%
% Tobin Fricke
% 2011-07-10

%% Compute
ifo = 'L1';
rslt = residualDARM(ifo);
%% Plot
close all
doOverZealousCropping = true;
doRebinSpectrum = false;

fontsize = 8;

colors.H1 = [1,0,0];
colors.L1 = [0,1,0]/2;

% no need to have so many points
if doRebinSpectrum
    f = logspace(log10(rslt.f(2)), log10(rslt.f(end)), 300);
    calibrated = spec_rebin(rslt.f, rslt.calibrated.^2, f).^(1/2);
    residual   = spec_rebin(rslt.f, rslt.residual.^2,   f).^(1/2);
    resRMS     = spec_rebin(rslt.f, rslt.residualRMS.^2,f).^(1/2);
else
    f = rslt.f;
    calibrated = rslt.calibrated;
    residual = rslt.residual;
    resRMS = rslt.residualRMS;
    calRMS = rslt.calibratedRMS;
end


% Plot

colors_res = colors.(ifo);
colors_cal = (colors.(ifo) + [1,1,1])/2;
loglog(f, resRMS, ...
       '--', 'color', colors_res, 'linewidth', 1);
hold all
loglog(f, calRMS, ...
       '--', 'color', colors_cal, 'linewidth', 1);
loglog(f, calibrated, ...
       '-',  'color', colors_cal, 'linewidth', 2);
loglog(f, residual, ...
       '-',  'color', colors_res, 'linewidth', 2);

hold off

axis tight

doLegend = false;
if doLegend
L = legend('loop-corrected displacement', ...
       'residual displacement', ...
       'integrated RMS','Interpreter', 'none');
set(L, 'box', 'off');
end

%title('DARM spectrum');
%xlabel('frequency [Hz]');
ylabel('log10 meters per sqrt Hz');

set([gca; findall(gca, 'Type','text')], 'FontSize', fontsize);

if doOverZealousCropping
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
        get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
end

ylim([1e-20 1e-6]);
xlim([f(2) f(end)]);
set(gca, 'YTick', 10.^(-20:2:-6));
%orient landscape
%
%   set(gca, 'XTickLabel', ...
%         cellfun(@(x) sprintf('%f Hz', x), num2cell(get(gca, 'XTick')), ...
%                 'UniformOutput', false));
set(gca, 'XTick', [0.01 0.1 1 10 100 1000 f(end)])
set(gca, 'XTickLabel', {'0.01 Hz', '0.1 Hz', '1 Hz', '10 Hz', '100 Hz', '1 kHz', ''});
set(gca, 'YTickLabel', ...
    cellfun(@(y) sprintf('%d', fix(log10(y))), num2cell(get(gca, 'YTick')), ...
    'UniformOutput', false));

columnwidth =  0.5 * 446.39996 / 72.26999;

c = cgrid();

set(gcf, 'PaperUnits', 'inches', ...
    'PaperSize',         [2 0.77]*columnwidth, ...
    'PaperPositionMode', 'manual', ...
    'PaperPosition', [0 0 2 0.77]*columnwidth);

margin_lft = (45/72.3);
margin_bot = (20/72.3);
margin_top = ( 5/72.3);

newpos =  [margin_lft margin_bot (get(gcf, 'PaperSize') - [margin_lft (margin_top + margin_bot)])];
set([c gca], 'Units', 'inches', ...
             'Position', newpos);

lgrid(c);

% Make PDF

print -dpdf residualDARM.pdf

%% Make TikZ

if exist('matlab2tikz', 'file')
    matlab2tikz('residualDARM.tikz');
else
    fprintf('Skipped TikZ generation\n');
end

    

