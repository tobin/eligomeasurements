
ifo = 'L1';

if strcmp(ifo, 'L1'),
    t0 = 965543700;  % Aug 11 2010 06:34:45 UTC -- best L1 range
elseif strcmp(ifo,  'H1'),
    t0 = 962268780;  % Jul 04 2010 08:52:45 UTC -- best H1 range
end


server = 'ldas-pcdev1.ligo.caltech.edu';
dur = 128;

chanlist = {[ifo ':PSL-ISS_ILMONPD_NW'], [ifo ':PSL-ISS_ILMONPD_W']};

result = NDS2_GetData(chanlist, t0, dur, server);    

%%
dc_val = mean(result(1).data);

fs = double(result(2).rate);
bw = 10;
bw = 2^nextpow2(bw);
nfft = fs/bw;

[Pxx, f] = pwelch(double(result(2).data), hanning(nfft), nfft/2, nfft, fs);

%%

f0 = 60;
whitening = abs(1000 * f ./ (1 + 1i * f/f0) / f0);

loglog(f, whitening);

%%

RIN = sqrt(Pxx)/dc_val./whitening;
loglog(f, RIN);
xlim([40 7444]);
xlabel('f [Hz]');
ylabel('RIN');
title('intensity noise seen at ILMON');
ylim([1e-9 2e-7]);

result = [f  RIN];

save([ifo '-RIN.txt'], '-ascii', 'result');