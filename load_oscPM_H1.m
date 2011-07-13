function msmts = load_oscPM_H1(msmt_root)

msmts2 = load_H1(msmt_root, 'DCnoisecouplings/opn/H1/2010-07-02', 'opnPlot');
msmts1 = load_H1(msmt_root, 'DCnoisecouplings/opn/H1/2010-10-11', 'opnPlot');

msmts = [msmts1 msmts2];