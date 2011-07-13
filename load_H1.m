function msmts = load_H1(msmt_root, datadir, func_name)
% msmts = load_H1(msmt_root, datadir, func_name)

datadir = [msmt_root datadir];
thisdir = pwd;

cd(datadir)
eval(func_name);
cd(thisdir)

for ii=1:length(dataStructure)
    msmts(ii).ifo= 'H1';
    msmts(ii).x0 = dataStructure(ii).offset * 1e12;
    msmts(ii).f  = dataStructure(ii).fTF(:,1);
    msmts(ii).H  = dataStructure(ii).fTF(:,2);
    msmts(ii).units = get(get(gca,'ylabel'), 'string'); %kludge
end
close