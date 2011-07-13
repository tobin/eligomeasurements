function msmts = load_laserAM_H1(msmt_root)

msmts1 = load_H1(msmt_root, 'DCnoisecouplings/ISS/H1/2010-06-02', 'ISSplot');
msmts2 = load_H1(msmt_root, 'DCnoisecouplings/ISS/H1/2010-10-07', 'ISSplot');

msmts = [msmts1 msmts2];
