function [msmts, CM] = load_laserFM_L1(msmt_root)
% [msmt, CM] = load_laserFM_L1(msmt_root)
%
% Load laser frequency noise coupling data
%
% msmts = the measurements
% CM = measurement of common mode open loop gain

f_probe = 7300;  % where the calibration was done

d = [msmt_root 'DCnoisecouplings/freq/L1/2010-06-02/'];

%% Load common-mode open-loop-gain (CM OLG)
undb = @(mag_db) 10.^(mag_db/20);

foo = textread([d 'CM000.ASC'], '', 'headerlines', 17);
CM = struct();
CM.f   = foo(:,1);
CM.OLG = undb(foo(:,2)) .* exp(1i * foo(:,3) * pi / 180);

CM_OLG_at_probe = interp1(CM.f, CM.OLG, f_probe);

fprintf('CM OLG at probe freq = %0.1f dB and %0.1f degrees\n', ...
    db(CM_OLG_at_probe), angle(CM_OLG_at_probe)*180/pi);

CM_corr = 1 - CM_OLG_at_probe;
fprintf('CM correction at probe freq = %0.1f dB and %0.1f degrees\n', ...
    db(CM_corr), angle(CM_corr)*180/pi);

%% Load DARM Calibration

[f_DarmCalib, DarmCalib] = get_darm_calib('L1', 962679241, []);

DARM_Calib_at_probe = interp1(f_DarmCalib, DarmCalib, f_probe);
fprintf('DARM calibration at probe freq = %0.4g meters/count and %0.1f degrees\n', ...
    abs(DARM_Calib_at_probe), angle(DARM_Calib_at_probe)*180/pi);

%% Read the files
msmts = struct('f',{},'H',{},'x0',{},'units',{},'coh',{});

offsets = [-20, -10, -5, 5, 10, 20];
 
for ii=1:length(offsets),
    offset = offsets(ii);
    filename = sprintf('%stf_CM_sweep_x0=%+d.txt', d, offset);
    
    data = dlmread(filename);
    f = data(:,1);   
    y = data(:,2) + 1i*data(:,3);
    clear data;
    
    filename((end-2):end)='coh';
    data = dlmread(filename);
    f_coh = data(:,1);
    coh   = data(:,3);
    clear data;
    
    if ~all(f_coh == f)
       error('error reading coherence file');
    end
    
    %  REFL2_I calibration = 1.66e-4 Hz/count * [ f/(7300 Hz) ]
    ReflCalib =  (1.66e-4) .* (f / 7300);
    
    % Apply the calibration
    y_calib = y .* interp1(f_DarmCalib, DarmCalib, f) ./ ReflCalib;
    
    msmts(ii) = struct('f', f, 'H', y_calib, 'x0', offset, ...
                   'units', 'm/Hz', 'coh', coh);               
end
