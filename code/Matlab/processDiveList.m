divelist = 'FullDiveList.csv';
rootdir = 'C:\Users\jgber\Dropbox (MIT)\Armstrong Data\SD Data';
dives = readtable(divelist,'Delimiter',',');
for i=1:size(dives.Variables,1)
    cd(rootdir)
    RadRead(dives.Foldername{i}, dives.Divename{i}, dives.Radname{i}, 4,...
        'C:\Users\jgber\Dropbox (MIT)\Armstrong Data\ProcessedDives', 0);
end