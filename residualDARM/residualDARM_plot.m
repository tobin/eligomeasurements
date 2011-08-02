%% Plot residual DARM displacement spectrum
%
% Tobin Fricke
% 2011-07-10

%% Compute
ifo = 'L1';
rslt = residualDARM(ifo);
%% Plot

doOverZealousCropping = 0;
fontsize = 12;

colors.H1 = [1,0,0];
colors.L1 = [0,1,0]/2;

cla

% no need to have so many points
doRebinSpectrum = false;
if doRebinSpectrum
    f = logspace(log10(rslt.f(2)), log10(rslt.f(end)), 300);
    calibrated = spec_rebin(rslt.f, rslt.calibrated.^2, f).^(1/2);
    residual   = spec_rebin(rslt.f, rslt.residual.^2,   f).^(1/2);
    rms        = spec_rebin(rslt.f, rslt.rms.^2,        f).^(1/2);
else
    f = rslt.f;
    calibrated = rslt.calibrated;
    residual = rslt.residual;
    rms = rslt.rms;
end


% Plot
loglog(f, calibrated, ...
       '-', 'color', (colors.(ifo) + [1,1,1])/2, 'linewidth', 2);
hold all
loglog(f, residual, ...
       '-',  'color', colors.(ifo),   'linewidth', 2);
loglog(f, rms, ...
       '-',  'color', 'k', 'linewidth', 1);
hold off
%%
axis tight
L = legend('loop-corrected displacement', ...
       'residual displacement', ...
       'integrated RMS','Interpreter', 'none');
set(L, 'box', 'off');

%title('DARM spectrum');
xlabel('frequency [Hz]');
ylabel('m/\sqrt{Hz}');

set([gca; findall(gca, 'Type','text')], 'FontSize', fontsize);

if doOverZealousCropping
    set(gca, 'Position', get(gca, 'OuterPosition') - ...
        get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);
end

ylim([1e-20 1e-6]);
set(gca, 'YTick', 10.^(-20:-6));  % For Kissel comparison
orient landscape

% 
% set(gcf, 'PaperUnits', 'inches', ...);
%          'PaperSize',         [3.5 2], ...
%          'PaperPositionMode', 'manual', ...
%          'PaperPosition', [0 0 3.5 2]);

%% Make PDF

print -dpdf residualDARM.pdf

%% Make TikZ

if exist('matlab2tikz', 'file')
    matlab2tikz('residualDARM.tikz');
else
    fprintf('Skipped TikZ generation\n');
end

    

