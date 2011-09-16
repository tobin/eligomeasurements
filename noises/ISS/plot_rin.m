ifos = {'H1', 'L1'};
for ifo = ifos,
    data = dlmread([ifo{1} '-RIN.txt']);
    loglog(data(:,1), data(:,2));
    hold all
end
hold off
legend(ifos);

ylim([1e-9 1e-6]);
xlim([40 7444]);

title('ISS ILMON RIN');
xlabel('frequency [Hz]');
ylabel('RIN (\delta P/P)');

grid on

orient landscape
print -dpdf ISS-RIN.pdf
