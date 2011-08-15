function msmts = load_oscPM_H1(msmt_root)

msmts2 = load_H1(msmt_root, 'DCnoisecouplings/opn/H1/2010-07-02', 'opnPlot');
msmts1 = load_H1(msmt_root, 'DCnoisecouplings/opn/H1/2010-10-11', 'opnPlot');
msmts3 = load_H1(msmt_root, 'DCnoisecouplings/opn/H1/2005-SURF',  'opnPlot');
msmts4 = load_H1(msmt_root, 'DCnoisecouplings/opn/H1/2007-01-25', 'opnPlot');

msmts = [msmts1 msmts2 msmts3 msmts4];