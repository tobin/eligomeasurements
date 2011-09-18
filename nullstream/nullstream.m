% Nullstream inspection

% Notes:
% * pwelch works with single-precision numbers now, ... but doing so will
%   introduce too much numerical error.  Be sure to cast to double!
% * I introduced some filters to compensate for the in-vacuum whitening
%   mismatch.

%% Get the data
t0  = 965543700;
dur = 1024;

server = 'ldas-pcdev1.ligo.caltech.edu:31200';
channels = {'L1:OMC-PD_TRANS1_OUT_DAQ', 'L1:OMC-PD_TRANS2_OUT_DAQ'};
data = NDS2_GetData(channels, t0, dur, server);

%% Look at the data
bw = 1;
bw = 2^nextpow2(bw);
fs = data(1).rate;
nfft = fs/bw;

x = double(data(1).data);
y = double(data(2).data);

x = x - mean(x);
y = y - mean(y);

[Pxx,f] = pwelch(x,        hanning(nfft), nfft/2, nfft, fs);
[Pyy,f] = pwelch(y,        hanning(nfft), nfft/2, nfft, fs);
[Txy,f] = tfestimate(x, y, hanning(nfft), nfft/2, nfft, fs);

%%

loglog(f, abs(Pxx), '.-', ...
       f, abs(Pyy), '.-');

%% Compare transfer function to whitening mismatch

B = [0.833690680850844         -1.63778074340861         0.804160902742437];
A = [                1         -1.96896364300317         0.969048421938763];

H = freqz(A, B, f, fs);
subplot(2,1,1);
semilogx(f, db(Txy), '.', f, db(H), '-')
subplot(2,1,2);
semilogx(f, angle(Txy)*180/pi, '.', f, angle(H)*180/pi, '-')

%%

% High-pass filter (in lieu of detrending)
[B,A] =  tfdata(c2d(zpk(0, -2*pi*1, 1), 1/fs), 'v');
x = filter(B, A, double(data(1).data));
y = filter(B, A, double(data(2).data));

% Apply whitening tweak
B = [0.833690680850844         -1.63778074340861         0.804160902742437];
A = [                1         -1.96896364300317         0.969048421938763];
y2 = filter(B, A, y);

[Pyy2,f] = pwelch(y2,        hanning(nfft), nfft/2, nfft, fs);

%%
loglog(f, abs(Pxx), '.-', ...
       f, abs(Pyy2), '.-');
%%
bw = 1;
bw = 2^nextpow2(bw);
fs = data(1).rate;
nfft = fs/bw;

my_sum  = x+y;
my_null = x-y;
my_null2 = x-y2;

my_null2 = my_null2((8*fs):end);

[Pnn,f] = pwelch(my_null - mean(my_null),      hanning(nfft), nfft/2, nfft, fs);
[Pss,f] = pwelch(my_sum  - mean(my_sum),      hanning(nfft), nfft/2, nfft, fs);

[Pnn2,f2] = pwelch(my_null2 - mean(my_null2),      hanning(nfft), nfft/2, nfft, fs);

loglog(f,  sqrt(Pss), '-', ...   
       f2, sqrt(Pnn2), '-');
   
% For fun, put shot noise on the plot
h = 6.626e-34;
nu = 3e8/1064e-9;
P = mean(data(1).data + data(2).data)/1000;
line(get(gca, 'xlim'), 1000*sqrt(2 * h * nu * P)*[1 1], 'color', [0 0 0]);   