divelist = 'FullDiveList.csv';
rootdir = 'C:\Users\jgber\Dropbox (MIT)\Armstrong Data\SD Data';
%savedir = 'C:\Users\jgber\Dropbox (MIT)\Armstrong Data\ProcessedDives';
savedir = [];
dives = readtable(divelist,'Delimiter',',');
for i=1:size(dives.Variables,1)
    cd(rootdir)
    try
        RadRead(dives.Foldername{i}, dives.Divename{i}, dives.Radname{i}, 4,...
            savedir, 0);
    catch ME
        fprintf(1,'In %s,',dives.Foldername{i})
        fprintf(1,ME.message);
    end
end