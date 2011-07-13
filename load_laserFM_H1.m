function msmts = load_laserFM_H1(msmt_root)

msmts1 = load_H1(msmt_root, 'DCnoisecouplings/freq/H1/2010-06-25', 'freqPlot');
msmts2 = load_H1(msmt_root, 'DCnoisecouplings/freq/H1/2010-10-07', 'freqPlot');

msmts = [msmts1 msmts2];
