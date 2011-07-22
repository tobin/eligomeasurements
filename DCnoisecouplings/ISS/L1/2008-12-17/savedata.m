plot_olgans;   % found in /data/dtt/tf/notebook/2008/12/12
%%
M = [ f ,  ...                                        % frequency
      txys{1} .* chan2_calib ./ chan1_calib, ...      % RF coupling (m/RIN)
      txys{2} .* chan2_calib ./ chan1_calib, ...      % DC coupling +fringe
      txys{3} .* chan2_calib ./ chan1_calib ];        % DC coupling -fringe

M = abs(M);

C = [f, cohs{1}, cohs{2}, cohs{3}];

save('laserAM_data.txt', '-ascii', 'M')
save('laserAM_data.coh', '-ascii', 'C');

