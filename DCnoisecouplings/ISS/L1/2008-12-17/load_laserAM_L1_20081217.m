function msmts = load_laserAM_L1_20081217(msmt_root)
% Return a struct array containing the measured transfer functions from
% laser AM to DC readout

d = [msmt_root 'DCnoisecouplings/ISS/L1/2008-12-17/'];

data = load([d 'laserAM_data.txt']);
coh  = load([d 'laserAM_data.coh']);

offsets = [0 16 -16] * (0.75);  % DARMs to picometers

for ii = 1:3,
    msmts(ii).x0 = offsets(ii);
    msmts(ii).f  = data(:,1);
    msmts(ii).H  = data(:,ii+1);  % warning: only magnitude
    msmts(ii).units = 'm/RIN';
    msmts(ii).coh = coh(:,ii+1);
    
    % perform some coherence cutting here: (kludgey)
    jj =   (msmts(ii).coh > 0.15)  ...      % very liberal coherence cutoff
         & (abs(msmts(ii).f - 120) > 1) ... % stay away from 120 Hz line
         & (msmts(ii).f < 6500);            % high frequency cutoff
    msmts(ii).f   = msmts(ii).f(jj);
    msmts(ii).coh = msmts(ii).coh(jj);
    msmts(ii).H   = msmts(ii).H(jj);
end