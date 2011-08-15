% This script was used in the process of extracting the data from the PDF
% file "stefan-1170292352.pdf" which was found in the Hanford ilog here:
%
%     http://ilog.ligo-wa.caltech.edu/ilog/pub/ilog.cgi?group=detector&date_to_view=01/25/2007&anchor_to_scroll_to=2007:01:31:17:12:33-stefan
%
% The recipe was:
%  1. Use pdftk to decompress the PDF data:
%     > pdftk stefan-1170292352.pdf output uncompressed.pdf uncompress
%
%  2. Use emacs to find and extract the sections consisting of trace data.
%     These are long series of lines with two numbers and the letter "l".
%     Remember, PDF is like postscript, and postscript uses reverse polish
%     notation.  "l" seems to be the command for "line to", "m" for "move
%     to" and "S" for "stroke".  I saved it to files called dataA.txt and
%     dataB.txt.
%
%  3. Use cut and grep to get rid of the "l" and "S" commands in the
%     extracted text:
%     > cut -f1,2 dataB.txt -d " " | grep -v S > dataB-cut.txt
%     > cut -f1,2 dataA.txt -d " " | grep -v S > dataA-cut.txt
%
%  4. Now determine the scaling factors and offsets necessary to put the
%     postscript coordinates into the plot units.  To do this I found some
%     line-drawing commands that draw X and Y grid lines.  You just need
%     one vertical grid line and one horizontal grid line to get the extent
%     of the plot box.
%
%  The results are remarkably good.  I printed both the original PDF and a
%  new plot made in Matlab.  Holding up both pages to a light, I can see
%  that they overlap exactly - the plots are identical.
%
%  There is some funny business in the extracted data, however, such as
%  duplicate X values with very slightly different Y values.  I'm not sure
%  what causes that.  
%
% Tobin Fricke 2011-08-15

dataA = dlmread('dataA-cut.txt');
dataB = dlmread('dataB-cut.txt');

plot(dataA(:,1), dataA(:,2), '.', ...
     dataB(:,1), dataB(:,2), '.');
 
% frequency range of traces is 50 Hz to something above 7000 Hz
% xlim is 10^1 to 10^4 Hz
% ylim is 10^-16 to 10^-10
 
line([929.167 929.167], [2274.17 5795.83]); 
line([929.167 5392.5 ], [3625    3625]);

xrange_in = [929.167 5392.5];
yrange_in = [2274.17 5795.83];

xrange_out = [1 4];
yrange_out = [-16 -10];

x_in = dataA(:,1);
y_in = dataA(:,2);

x_out = (x_in - xrange_in(1))/(xrange_in(2) - xrange_in(1));
y_out = (y_in - yrange_in(1))/(yrange_in(2) - yrange_in(1));

x_outA = x_out * (xrange_out(2) - xrange_out(1)) + xrange_out(1);
y_outA = y_out * (yrange_out(2) - yrange_out(1)) + yrange_out(1);
%

x_in = dataB(:,1);
y_in = dataB(:,2);

x_out = (x_in - xrange_in(1))/(xrange_in(2) - xrange_in(1));
y_out = (y_in - yrange_in(1))/(yrange_in(2) - yrange_in(1));

x_outB = x_out * (xrange_out(2) - xrange_out(1)) + xrange_out(1);
y_outB = y_out * (yrange_out(2) - yrange_out(1)) + yrange_out(1);

%
plot(x_outA, y_outA, '.', ...
     x_outB, y_outB, '.');
xlim([1 4]);
ylim([-16 -10]);

%%
data_outA = 10.^[x_outA y_outA];
data_outB = 10.^[x_outB y_outB];

data_outA = sortrows(data_outA, 1);
data_outB = sortrows(data_outB, 1);

save data_outA.txt -ascii data_outA
save data_outB.txt -ascii data_outB

%%

loglog(data_outA(:,1), data_outA(:,2), '-', ...
       data_outB(:,1), data_outB(:,2), '-');
   
grid on

title('Data reconstructed from PDF file 2011-08-15');