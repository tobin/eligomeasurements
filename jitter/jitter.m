%% Show example of linear and bilinear jitter coupling

% Long lock on 2010-03-08
if (1 ~= exist('result')),
    fprintf('Getting new data...\n');
    t0 = 952065843;
    duration = 23619;  % length of lock
    duration = 2^11;
    server = 'ldas-pcdev1.ligo.caltech.edu:31200';
    
    chanlist = NDS2_GetChannels(server, 'raw', t0);
    
    result = NDS2_GetData({'L1:LSC-DARM_ERR'; ...
        'L1:OMC-QPD3_P_OUT_DAQ'; ...
        'L1:OMC-QPD3_Y_OUT_DAQ'; ...
        'L1:OMC-QPD3_SUM_IN1_DAQ'; ...
        'L1:OMC-QPD4_SUM_IN1_DAQ'; ...
        'L1:OMC-PD_SUM_OUT_DAQ'}, t0, duration, server);
    
    fs = 512;
else
    fprintf('re-using data in results structure...\n');
end

for ii=1:length(result)
    result(ii).dc = mean(result(ii).data);
end
%%
for ii=1:length(result)   
    if (mean(result(ii).data) > 1),
        fprintf('detrending %s\n', result(ii).name);
        result(ii).data = detrend(result(ii).data);
    end
    if (result(ii).rate > fs),
        fprintf('resampling %s\n', result(ii).name);
        result(ii).data = double(result(ii).data);
        result(ii).data = decimate(result(ii).data, double(result(ii).rate/fs));
        result(ii).rate = fs;
    end
 
end

%%

%  [B,A] = BUTTER(N,Wn,'high') designs a highpass filter.
[b,a] = butter(6, 100/(fs/2), 'high');
%drive_sig = filter(b,a,noise_drive); %filter noise_drive by a & b

%look at filter shape
[H,f] = freqz(b,a,1000,fs);
loglog(f,abs(H));
grid
%%
ii = 3;
jj = 5;
result(7) = result(1);
% result(6).data = result(ii).data .* result(jj).data;
result(7).name = sprintf('%s * %s', result(ii).name, result(jj).name);
result(7).data = filter(b, a, result(ii).data) .* result(jj).data / 50;
%result(6).name = sprintf('High-passed %s', result(ii).name);
%%
bw = 0.0625;

for ii=1:length(result)
    fprintf('transforming "%s"...\n', result(ii).name);
    result(ii).rate = double(result(ii).rate);    
    nfft = length(result(ii).data)/result(ii).rate/bw;
    nfft = 2^nextpow2(double(nfft));
    noverlap = nfft/2;
    navg = length(result(ii).data)/(nfft-noverlap);

    [Pxx, f] = pwelch(result(ii).data, hanning(nfft), noverlap, nfft, result(ii).rate);
    result(ii).f = f;
    result(ii).Pxx = Pxx;
end

%%
for ii=1:length(result),
    fprintf('cohering "%s"...\n', result(ii).name);
    nfft = length(result(ii).data)/result(ii).rate/bw;
    nfft = 2^nextpow2(double(nfft));
    noverlap = nfft/2;
    result(ii).Cxy =   mscohere(result(ii).data, result(1).data, hanning(nfft), noverlap, nfft, result(ii).rate);
    result(ii).Txy = tfestimate(result(ii).data, result(1).data, hanning(nfft), noverlap, nfft, result(ii).rate);
end

%% Plot DARM
ii = 6;
subplot(1,1,1);
semilogy(result(ii).f, result(ii).Pxx, 'LineWidth', 1, 'color', 0.2*[0 0 1]);
xlim([-5 5]+130);
ylim([1e-13 1e-10]);
title('transmitted intensity');
%xlabel('frequency [Hz]');
fontsize = 8;
set([gca; findall(gca, 'Type','text')], 'FontSize', fontsize)

lgrid(cgrid);
 
xticks = [125 130 135];
set(gca, 'XTick', xticks, 'XTickLabel', ...
     cellfun(@(x) sprintf('%d Hz', x), num2cell(xticks), 'UniformOutput', false));
set(gca, 'XTick', xticks, 'XTickLabel', {'    125', '130 Hz', '135    '});

set(gca, 'YTickLabel', ...
     cellfun(@(y) sprintf('%d', fix(log10(y))), num2cell(get(gca, 'YTick')), ...
     'UniformOutput', false));

filename = 'jitter12.pdf';
papersize= [2 2.37];
margins = [15 16 -10 -16]/72;
print_for_publication(filename, papersize, margins)

%print -dpng jitter12.png
%print -dpdf jitter12.pdf

%% Plot QPD YAW
ii = 3;
subplot(1,1,1);
semilogy(result(ii).f, result(ii).Pxx, 'LineWidth', 1, 'color', 0.2*[0 0 1]);
xlim([-5 5]+130);
title('incident motion');
%xlabel('frequency [Hz]');
set([gca; findall(gca, 'Type','text')], 'FontSize', fontsize)

lgrid(cgrid);

xticks = [125 130 135];
set(gca, 'XTick', xticks, 'XTickLabel', ...
     cellfun(@(x) sprintf('%d Hz', x), num2cell(xticks), 'UniformOutput', false));
set(gca, 'XTick', xticks, 'XTickLabel', {'    125', '130 Hz', '135    '}); 
set(gca, 'YTickLabel', ...
     cellfun(@(y) sprintf('%d', fix(log10(y))), num2cell(get(gca, 'YTick')), ...
     'UniformOutput', false));
filename = 'jitter2.pdf';
print_for_publication(filename, papersize, margins)

%% Plot QPD SUM
ii = 5;

semilogy(result(ii).f, result(ii).Pxx, 'LineWidth', 1, 'color', 0.2*[0 0 1]);
xlim([0 5]);
title('incident intensity');
%xlabel('frequency [Hz]');
set([gca; findall(gca, 'Type','text')], 'FontSize', fontsize)

lgrid(cgrid);

xticks = [0 1 2 3 4 5];
set(gca, 'XTick', xticks, 'XTickLabel', ...
     cellfun(@(x) sprintf('%d Hz', x), num2cell(xticks), 'UniformOutput', false));
set(gca, 'XTickLabel', {'0', '1', '2', '3', '4', '5 Hz'});
set(gca, 'YTickLabel', ...
     cellfun(@(y) sprintf('%d', fix(log10(y))), num2cell(get(gca, 'YTick')), ...
     'UniformOutput', false)); 
filename = 'jitter1.pdf';
print_for_publication(filename, papersize, margins)

%print -dpng jitter1.png
%print -dpdf jitter1.png

%%
clf;
ii = 6;
semilogy(result(ii).f, result(ii).Pxx, 'LineWidth', 1, 'color', 0.2*[0 0 1]);
xlim([0 5]);
