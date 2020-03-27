function [time, PARdat] = readPAR(filename)
switch nargin
    case 0
        [filename, filepath] = uigetfile('*.PAR');
        cd(filepath);
end

%%% PAR Sensor Format:
% MET 2020/03/15 12:00:06.693 PAR $ME, 82.917, 9.42, 17.663
%%%

fid = fopen(filename);
formatSpec = 'MET %s PAR $ME, %f, %f, %f';
%formatSpec = 'MET %{yyyy/MM/dd HH:mm:ss.SSS}D PAR $ME, %f, %f, %f';
C = textscan(fid, formatSpec);

infmt = 'yyyy/MM/dd HH:mm:ss.SSS';
fclose(fid);



end

