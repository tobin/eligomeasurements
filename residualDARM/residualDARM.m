function rslt = residualDARM(ifo)
% rslts = residualDARM({'H1','L1'})
%
% This function plots the L1 and H1 DARM displacement spectra, along with
% spectra that have had the loop suppression correction removed, giving the
% residual displacement spectra.  Also would be nice to have the RMS.
%
% This script needs access to /data/dtt/Calibration in order to get the
% DARM OLG from the model.  I mount the laboratory filesystem on my laptop
% using sshfs:
%
% > sshfs -o reconnect fricke@llocds.ligo-la.caltech.edu:/data /data
%
% Tobin Fricke
% 2011-07-10

if iscell(ifo)
    % if they gave us a cell list of ifos, process each one:
    rslt = cellfun(@residualDARM, ifo, 'UniformOutput', 0);
    
else
    % just one ifo
    fprintf('ifo = %s\n', ifo);
    
    [data, rate] = load_strain_timeseries(ifo);
    [Pxx, f] = make_spectrum(data, rate);
    
    % delete the high frequency stuff to get rid of the unphysical
    % drumhead injection
    kk = f > 7000;
    Pxx(kk) = [];
    f(kk)   = [];
    
    G = get_OLG(ifo, f);
    
    calibrated = 3995 * sqrt(Pxx);
    residual = calibrated ./ abs(1 - G);
    rms = ampSpectrumRMS(f.', residual.');  % this is in mattlib
    
    % Copy to output argument
    rslt.calibrated = calibrated;
    rslt.residual = residual;
    rslt.rms = rms;
    rslt.f = f;
end

end

%% Load DARM OLG
function G = get_OLG(ifo, f)
calib_path = '/data/dtt/Calibration/CVS/calibration/';
if ~exist('DARMmodel','file'),
    fprintf('adding some things to the path\n');
    addpath(path, [calib_path 'frequencydomain/runs/S6/MatlabScripts']);
    addpath(path, [calib_path 'frequencydomain/runs/S6/L1/model/V2/']);
    addpath(path, [calib_path 'frequencydomain/runs/S6/H1/model/V2/']);
end

switch ifo
    case 'L1'
        calib_ifo_model = L1DARMparams_934487415;
    case 'H1'
        calib_ifo_model = H1DARMparams_942450950;
end
[G,~,~,~,~,~,~,~,~,~] = DARMmodel(calib_ifo_model, f);
end

%% Load h(t) data
function [data, rate] = load_strain_timeseries(ifo)
switch ifo
    case 'H1'
        filename = 'H1-STRAIN-962268780.bin';
    case 'L1'
        filename = 'L1-STRAIN-965543700.bin';
end

fd = fopen(filename, 'r');
data = fread(fd, inf, 'double');
rate = 16384;
fclose(fd);
end

%% Make a power spectrum
function [Pxx, f] = make_spectrum(data, rate)
bw = 2;  % resolution [Hz]
nfft = 2^nextpow2(rate/bw);
[Pxx, f] =  pwelch(detrend(data), hanning(nfft), nfft/2, nfft, rate);
end

