

% these are the PD levels while locked with no detuning

P_t_zerodetune = 20.7104; %PDSUM
P_i_zerodetune = 379.952; %QPD3SUM


% measurement "2"
meas2.P_t = .999435;
meas2.P_i = 376.135;
meas2.rawPSD = DTTloadspec('02-pdsum.txt');
meas2.lengthloop = DTTloadTF('02-lengthloop.txt');

meas2cal = calibratelengthnoise(meas2);

% meas 4
meas4.P_t = 4.00675;
meas4.P_i = 376.832;
meas4.rawPSD = DTTloadspec('04-pdsum.txt');
meas4.lengthloop = DTTloadTF('04-lengthloop.txt');

meas4cal = calibratelengthnoise(meas4);

% figures
figure(33)
SRSspec(meas2cal.lengthnoisespectrum,meas4cal.lengthnoisespectrum)
ylabel('m/rt(hz)')
xlabel('Frequency (Hz)')
xlim([50 8000])
ylim([3e-17 1e-13])

legend('meas2','meas4')