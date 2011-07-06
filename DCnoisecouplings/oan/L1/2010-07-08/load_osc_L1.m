function [AM_msmts, PM_msmts] = load_osc_L1(msmt_root)
% [AM_msmts, PM_msmts] = load_osc_L1()
%
% Load the oscillator AM and oscillator PM noise coupling measurements

if nargin < 1
    msmt_root = '';
end

d = [msmt_root 'DCnoisecouplings/oan/L1/2010-07-08/'];

%% Load the DARM calibration
[f_DarmCalib, DarmCalib] = get_darm_calib('L1', 962679241, []);

%% Load the oscillator AM calibration
temp = dlmread([d '../2010-07-06/OSCAM_SBSB_amp=1.4142.txt']);
f_AMcalib = temp(:,1);
AMcalib = (temp(:,2*4+2) + 1i*temp(:,2*4+3)) /  0.2234;  % Gives RIN per count of EXC
clear temp;

%% Come up with an oscillator FM calibration
%  Keita's LHO elog of January 25, 2007 indicates 7.2 Hz/V measured, but
%  I'll use the indicated (10 Hz)/(1 Vrms) = 7.07 Hz/V.

f_PMcalib = f_AMcalib;
PMcalib =   (AMcalib / mean(AMcalib(1:10))) * (0.01 / sqrt(2));   % radians/count


%% Oscillator PM

PM_msmts = struct('f',{},'H',{},'x0',{},'units',{},'coh',{});

filenames= {'OSCPM_RF',     'OSCPM_x0=+20', 'OSCPM_x0=+15',  'OSCPM_x0=+13', ...
            'OSCPM_x0=+10', 'OSCPM_x0=+05', 'OSCPM_x0=-05',  'OSCPM_x0=-10', ...
            'OSCPM_x0=-13', 'OSCPM_x0=-15',	'OSCPM_x0=-20'};
         
offsets = [0, 20, 15, 13, 10, 5, -5, -10, -13, -15, -20];

for ii=1:length(filenames)
    filename = filenames{ii};       
    offset = offsets(ii);
    
    temp = dlmread([d filename '.txt']);
    f   = temp(:,1);
    Txy = temp(:,(1:7)*2) + 1i* temp(:,(1:7)*2+1);
    clear temp;
    
    temp = dlmread([d filename '.coh']);
    coh = temp(:,2:end);
    clear temp;
    
    trace = abs(Txy(:,1) ...
        .* interp1(f_DarmCalib, DarmCalib, f) ...
        ./ interp1(f_PMcalib,   PMcalib,   f));    
    
    PM_msmts(ii) = struct('f', f, 'H', trace, 'x0', offset, ...
                          'units', 'm/radian','coh',coh );
   
end


%% Oscillator AM

AM_msmts = struct('f',{},'H',{},'x0',{},'units',{},'coh',{});

filenames = {
    'OSCAM_RF_amp=0.010', 'OSCAM_x0=+20_amp=0.001',  'OSCAM_x0=+15_amp=0.001', 'OSCAM_x0=+10_amp=0.001', ...
    'OSCAM_x0=+05_amp=0.001',  'OSCAM_x0=-10_amp=0.001',  'OSCAM_x0=-13_amp=0.001', 'OSCAM_x0=-20_amp=0.001',...
    'OSCAM_x0=-20_amp=0.010'
    };
                 
offsets = [0, 20, 15, 10, 5, -10, -13, -20, -20];

for ii=1:length(filenames)
    filename = filenames{ii};    
    offset = offsets(ii);
    
    temp = dlmread([d filename '.txt']);
    f   = temp(:,1);
    Txy = temp(:,(1:7)*2) + 1i* temp(:,(1:7)*2+1);
    clear temp;
    
    temp = dlmread([d filename '.coh']);
    coh = temp(:,2:end);
    clear temp;

    trace = abs(Txy(:,1)  ...
               .* interp1(f_DarmCalib, DarmCalib, f) ...
               ./ interp1(f_AMcalib, AMcalib, f));
    
    AM_msmts(ii) = struct('f', f, 'H', trace, 'x0', offset, ...
                          'units', 'm/RIN','coh',coh );
end