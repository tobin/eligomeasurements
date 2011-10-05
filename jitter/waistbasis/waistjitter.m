
% See elogs:
% http://ilog.ligo-la.caltech.edu/ilog/pub/ilog.cgi?group=detector&date_to_view=06/16/2008&anchor_to_scroll_to=2008:06:16:19:16:14-fricke
%

channels = { ...
    'L1:OMC-ASC_WAIST_X_OUT_DAQ',   ...
    'L1:OMC-ASC_WAIST_Y_OUT_DAQ',   ...
    'L1:OMC-ASC_WAIST_PIT_OUT_DAQ', ...
    'L1:OMC-ASC_WAIST_YAW_OUT_DAQ'};

t0 = 965543700;
dur = 4096;
server = 'ldas-pcdev1.ligo.caltech.edu:31200';

fprintf('Getting data...\n');
result = NDS2_GetData(channels, t0, dur, server);

%%

% Convert to double precision
for ii=1:length(result)
    f = fields(result(ii));
    for jj=1:length(f)
        if isa(result(ii).(f{jj}), 'single')
            result(ii).(f{jj}) = double(result(ii).(f{jj}));
        end
    end
end

%%

fprintf('Transforming...\n');
for ii=1:length(result)
    fs = result(ii).rate;
    
    bw = 0.005;  % resolution [Hz]
    bw = 2^nextpow2(bw);
    
    nfft = fs / bw;
    
    x = result(ii).data - mean(result(ii).data);
    [Pxx, f] = pwelch(x, hanning(nfft), nfft/2, nfft, fs);
    
    result(ii).Pxx = Pxx;
    result(ii).f = f;
end

%%

clf
colors = {[0 0 1], [0 0.5 0], [1 0 0], [0 0.75 0.75]};

for ii=1:length(result)
    loglog(result(ii).f, sqrt(result(ii).Pxx), 'linewidth', 1, 'color', colors{ii});
    hold all
end
% for ii=1:length(result)
%     rms = ampSpectrumRMS(result(ii).f, sqrt(result(ii).Pxx));
%     loglog(result(ii).f, rms, '--', 'color', colors{ii});
% end
hold off
%legend('X (um)', 'Y  (um)', 'PIT  (urad)', 'YAW  (urad)', 'Location', 'NorthWest');
xlabel('frequency [Hz]');
ylabel('beam motion at cavity waist');

set(gca, 'xscale', 'linear')
xlim([2 5]);
ylim([1e-1 1e2]);

%orient landscape
%print -dpdf tiptilt_dither_elog.pdf

filename = 'tiptilt_dither.pdf';
width = 6.5;
papersize = [1 (1/3)] * width;
margins = [36 36 0 -8]/72;

%lgrid(cgrid);
print_for_publication(filename, papersize, margins);
legend('X (\mu{}m)', 'Y  (\mu{}m)', 'PIT  (\mu{}rad)', 'YAW  (\mu{}rad)', 'Location', 'NorthEastOutside');
print('-dpdf',filename);