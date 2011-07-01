function msmts = load_laserAM_L1()
% Return a struct array containing the measured transfer functions from
% laser AM to DC readout

% if we were smarter, we would read these directly from the xml files
file_prefix = 'tf_ISS_sweep_x0=';

filenames = {'-15B.txt',  '15C.txt', '-20.txt', '5.txt',  '-10.txt', ...
    '15B.txt',  '15D.txt',  '20.txt', '10.txt', '-15C.txt', ...
    '-15.txt',   '-5.txt'};

% add the prefix to the filenames
filenames = cellfun(@(fn) [file_prefix fn], filenames, 'UniformOutput', 0);

% load each file
msmts = cellfun(@load_laserAM_msmt_file, filenames);

end

function msmt = load_laserAM_msmt_file(filename)

% Load the DARM calibration - silly to do in the loop
[f_DarmCalib, DarmCalib] = get_darm_calib('L1', 956447014.0, []);

% The whitened channel has a gain of 1000, and the mean DC is 17486 counts
ISS_Calib = (1/1000)*(1/17486);

% parse the filename to get the offset
offset = sscanf(filename, 'tf_ISS_sweep_x0=%d[A-Z]*.txt');
data = dlmread(filename);

f = data(:,1);
y = data(:,4) + 1i*data(:,5);

% fix up the filename to get the coherence
filename((end-2):end)='coh';
data = dlmread(filename);
f_coh = data(:,1);
coh   = data(:,3);

if ~all(f_coh == f),
    error('Coherence and transfer function frequency vectors disagree!');
end

% Apply the calibration
y_calib = y .* interp1(f_DarmCalib, DarmCalib, f) / ISS_Calib;

msmt.x0 = offset;
msmt.f  = f;
msmt.H  = y_calib;
msmt.units = 'm/RIN';
msmt.coh = coh;
end
