function msmts = load_oscAM_H1(msmt_root)

msmts1 = load_H1(msmt_root, 'DCnoisecouplings/oan/H1/2010-07-01', 'oanPlot');
msmts2 = load_H1(msmt_root, 'DCnoisecouplings/oan/H1/2010-10-11', 'oanPlot');

msmts = [msmts1 msmts2];