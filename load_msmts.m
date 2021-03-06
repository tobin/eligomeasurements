function msmts = load_msmts(msmt_root, ifo)
% >> msmts = load_msmts('/home/tobin/projects/eligomeasurements/', 'L1')
%
% msmts = 
% 
%     laserAM: [1x12 struct]
%     laserFM: [1x6 struct]
%       oscAM: [1x9 struct]
%       oscPM: [1x11 struct]

switch ifo
    case 'L1'
        msmts.laserAM = [ load_laserAM_L1(msmt_root) ...
                          load_laserAM_L1_20081217(msmt_root)];
        [ msmts.laserFM, msmts.CARMloop] = load_laserFM_L1(msmt_root);
        [ msmts.oscAM, msmts.oscPM] = load_osc_L1(msmt_root);
    case 'H1'
        msmts.laserAM = load_laserAM_H1(msmt_root);
        msmts.laserFM = load_laserFM_H1(msmt_root);
        msmts.oscAM   = load_oscAM_H1(msmt_root);
        msmts.oscPM   = load_oscPM_H1(msmt_root);
    otherwise
        error(['Don''t know where to find measurements for ' ifo])
end
