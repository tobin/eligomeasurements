%% Compare the various oscillator phase noise measurements

opn_f = [10 100 1000 10000];
opn   = [3e-6 1e-7 2e-8 8e-9];

valera = dlmread('valera-1229708489.txt');
valera_f = valera(:,1);
valera = valera(:,2);

rai = textread('RaiW-1110525697.dat', '', 'headerlines', 1);
rai_f = rai(:,1);
rai = rai(:,2);

loglog(opn_f, opn, 'o-');
hold all
loglog(valera_f, valera, rai_f, rai);
hold off
grid on


legend('Wenzel spec (according to Rupal)', 'Valera''s data', 'Rai''s data');