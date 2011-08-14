clear dataStructure;

filename = 'd.txt';
data = dlmread(filename);

dataStructure.filenames = filename;

dataStructure.fTF = [data(:,1) , data(:,2) .* exp(1i*data(:,3) * pi/180) ];

dataStructure.offset = 0;  % RF
dataStructure.legend = 'Data from Nicolas''s SURF report';

figure(121)
SRSbode(dataStructure.fTF)
legend(dataStructure.legend)

title('measured oscillator phase noise coupling for RF readout')
ylabel('m/radian')