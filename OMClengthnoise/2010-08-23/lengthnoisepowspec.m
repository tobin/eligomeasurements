

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

% meas 5 

meas5.P_t = 7.49567;
meas5.P_i = 378.026;
meas5.rawPSD = DTTloadspec('05-pdsum.txt');
meas5.lengthloop = DTTloadTF('05-lengthloop.txt');

meas5cal = calibratelengthnoise(meas5);

% am noise contribution

nooff.P_t = 20.7104;
nooff.P_i = 379.952;
nooff.rawPSD = DTTloadspec('01-pdsum.txt');

amnoise = meas2;
amnoise.rawPSD = colmult(nooff.rawPSD,[1,meas2.P_t/nooff.P_t]); % scale RIN to equivalent of meas 2

amnoisecal = calibratelengthnoise(amnoise);


% figures
figure(33)
SRSspec(amnoisecal.lengthnoisespectrum,...
        meas2cal.lengthnoisespectrum,...
        meas4cal.lengthnoisespectrum,...
        meas5cal.lengthnoisespectrum)
    
ylabel('m/rt(hz)')
xlabel('Frequency (Hz)')
xlim([10 8000])
ylim([3e-17 1e-13])

legend('AM noise','meas2','meas4','meas5')