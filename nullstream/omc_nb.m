
%% parameters
%t0 =  931767328 + 600;  
t0 = 938202950 - 600;
t0 = 938401489 - 60*35;
qe =  1.60217646e-19;         % elementary charge, Coulombs

bw = 1;
navg = 200;
dur = (1/bw)*navg/2

extra_delay = -0/32768;

% Load the open loop gain, as exported from DTT
OLG_filename = 'darmolg_090714.txt';
OLG = dlmread(OLG_filename);


% Load the dark noise spectra, as exported from DTT
dark_filename = 'darknoise.txt';
dark = dlmread(dark_filename);

%% Plot the OLG just to make sure it looks right
subplot(2,1,1)
semilogx(OLG(:,1), db(OLG(:,2) + i*OLG(:,3))); 
subplot(2,1,2);
semilogx(OLG(:,1), angle(OLG(:,2) + i*OLG(:,3))*180/pi); 
%%

data = get_data({'L1:OMC-PD_SUM_OUT_DAQ','L1:OMC-NULLSTREAM_OUT_DAQ'}, ...
       'raw', t0 - dur, dur);

% Compute the sum and nullstream
pd_nullstream = data(2).data;
pd_sum = data(1).data;
fs = data(1).rate;

%%
% Compute the expected shot noise
I = mean(pd_sum)/1000;       % DC current, Amps
shot_noise_ASD = sqrt(2*qe*I);   % sqrt(coulombs * coulombs/sec) = coulombs/sqrt(sec)

% Compute amplitude spectral densities
nfft = fs/bw;
[yf_null,f_null] = pwelch(pd_nullstream,hanning(nfft),nfft/2,nfft,fs);
[yf_sum,f_sum]   = pwelch(pd_sum,hanning(nfft),nfft/2,nfft,fs);

% PSD --> ASD
yf_null = sqrt(yf_null);
yf_sum  = sqrt(yf_sum);
%%

G = (OLG(:,2) + i*OLG(:,3));

% add extra phase delay
G = G .* exp(-i*2*pi*OLG(:,1)*extra_delay);

OLG_correction = abs(1 - G);
semilogx(OLG(:,1), db(OLG_correction));
title('OLG correction');
ylabel('dB');
grid on
axis tight
%%

subplot(1,1,1);

% draw the dark noise
total_dark = sqrt(dark(:,2).^2 + dark(:,3).^2);
total_shot_plus_dark = sqrt(total_dark.^2 + (shot_noise_ASD*1000).^2);
loglog(dark(:,1), total_shot_plus_dark, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 3);
hold all

loglog(dark(:,1), total_dark, '-k', 'LineWidth', 3);

% draw the expected shot noise on the graph
plot(get(gca,'Xlim'), shot_noise_ASD*[1 1]*1000, 'color', 'Red', 'LineWidth', 5);

% draw the measured pd_sum and nullstream

yf_sum_corrected = yf_sum .* interp1(OLG(:,1), OLG_correction, f_sum, 'nearest', NaN);

loglog(f_null, yf_null, 'color', [0 0 1], 'LineWidth', 3);
%%loglog(f_sum, yf_sum, ':', 'color', [1 0 1], 'LineWidth', 3);
loglog(f_sum, yf_sum_corrected, 'color', [1 0 1], 'LineWidth', 3);   

grid on;
ylabel('photocurrent spectral density [mA / rtHz]');  
xlabel('frequency [Hz]');
xlim([9 11111]);
hold off;

legend('dark + shot', 'dark noise',  ...
    sprintf('shot noise for %0.1f mA', I*1000), ...
    'nullstream', 'pd sum * abs(1 - OLG)');

title(sprintf('OMC spectra for t_0 = %d', t0));
%%

orient landscape
print -dpdf omc_nb.pdf
