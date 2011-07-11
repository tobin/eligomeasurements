%% Plot residual DARM displacement spectrum
%
% Tobin Fricke
% 2011-07-10

%% Compute
ifo = 'L1';
rslt = residualDARM(ifo);
%% Plot

colors.H1 = [1,0,0];
colors.L1 = [0,1,0]/2;

cla

% Plot
loglog(rslt.f, rslt.calibrated, ...
       '--', 'color', (colors.(ifo) + [1,1,1])/2, 'linewidth', 2);
hold all
loglog(rslt.f, rslt.residual, ...
       '-',  'color', colors.(ifo),   'linewidth', 2);
loglog(rslt.f, rslt.rms, ...
       ':',  'color', colors.(ifo)/2, 'linewidth', 2);

axis tight
L = legend('loop-corrected displacement', ...
       'residual displacement', ...
       'integrated RMS');
set(L, 'box', 'off');

title('DARM spectrum');
xlabel('frequency [Hz]');
ylabel('meters/rtHz [m]');

set([gca; findall(gca, 'Type','text')], 'FontSize', 16);

%% Make PDF

orient landscape
print -dpdf residualDARM.pdf
