function [Dive] = UnpackRadDive(Folder_Name,Data_Offset,nSamples)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
switch nargin
    case 2
        nSamples = 1000;
end

Mask_Saturated_Points = 0;
Click_Cutoff_ns       = 999000000;


%cd(Folder_Name);
%MetaFile = dir('*.txt');
DataFiles = dir(strcat(Folder_Name,'/*.bin'));
%MetaFileName= MetaFile(1).name;
DataFileName = strcat(Folder_Name,'/',DataFiles(1).name);

% MetaData = Unpack_RadDive_MetaFile(MetaFileName);
UTCshift = 4;
%nSamples = 1000; % 2000, 4000, 8000, 10000, 16000, 25000, 40000  

Click_Cutoff = floor(Click_Cutoff_ns/nSamples); % timeHi above this considered saturated

fileInfo = dir(DataFileName);

%hMetaFile = fopen(MetaFileName);
hDataFile = fopen(DataFileName);

% Each Data packet is 8B, and each heartbeat is 16B, so we can infer the 
% number of complete heartbeats (aka number of seconds) from file size:
nPackets    = floor(fileInfo.bytes / 8);

if (Data_Offset ~= 0)
    % subtract off leading packets and initial heartbeat
    nPackets    = nPackets - (Data_Offset+2); 
    % Advance file pointer to start of fresh data
    fread(hDataFile,Data_Offset+2,'uint64=>uint64');
end



nHeartBeats    = floor(nPackets/(nSamples+2));
nPings         = nHeartBeats *  nSamples;

% Raw Data
Ping_RawData     = zeros(nHeartBeats,4,nSamples);
HeartBeat_UTC_S  = zeros(1,nHeartBeats);
HeartBeat_UTC_u  = zeros(1,nHeartBeats);

% Ping Data
Ping.t               = zeros(1,nPings); 
Ping.nSecOn          = zeros(1,nPings); % 
Ping.nSecHi          = zeros(1,nPings); % 
Ping.Pulses          = zeros(1,nPings); % 
Ping.Saturated       = zeros(1,nPings); % Logical
Ping.nSecHi_Smoothed = zeros(1,nPings); % 
Ping.Pulses_Smoothed = zeros(1,nPings); % 
Ping.PulseLength     = zeros(1,nPings); % 

%    Data per Heartbeat 
HeartBeat.t           = zeros(1,nHeartBeats); %
HeartBeat.X_inc       = zeros(1,nHeartBeats); %
HeartBeat.Y_inc       = zeros(1,nHeartBeats); %
HeartBeat.nSecOn      = zeros(1,nHeartBeats); %
HeartBeat.nSecHi      = zeros(1,nHeartBeats); %
HeartBeat.Pulses      = zeros(1,nHeartBeats); %
HeartBeat.PulseLength = zeros(1,nHeartBeats); %












% Loop over heartbeats and read the data...
for i = 1:nHeartBeats

    Ping_RawData(i,:,:)    = fread(hDataFile,[4,nSamples],'uint16=>uint16');

    TokenD              = sum(squeeze(Ping_RawData(i,1,:)));
    if (TokenD ~= 252 * nSamples) %0xFC
        error('Found a wrong TokenD at HeartBeat [%u]! \nShould be [%u], but we got [%u].\n', i, 252 * nSamples,TokenD)
        break;
    end
    
    TokenA              = fread(hDataFile,1,'uint16=>uint16');
    if (TokenA ~= 253) %0xFD
        error('Found a wrong TokenA at HeartBeat [%u]! \nShould be [%u], but we got [%u].\n',i,253,TokenA)
        break;
    end

    HeartBeat.X_inc(i)  = fread(hDataFile,1,'uint16=>uint16');
    HeartBeat_UTC_S(i)  = fread(hDataFile,1,'uint32=>uint32');

    TokenB              = fread(hDataFile,1,'uint16=>uint16');
    if (TokenB ~= 254) %0xFE
        error('Found a wrong TokenB at HeartBeat [%u]! \nShould be [%u], but we got [%u].\n',i,254,TokenB)
        break;
    end

    HeartBeat.Y_inc(i)  = fread(hDataFile,1,'uint16=>uint16');
    HeartBeat_UTC_u(i)  = fread(hDataFile,1,'uint32=>uint32');
    
    HeartBeat.t(i)    = HeartBeat_UTC_S(i) + (HeartBeat_UTC_u(i)/1e6);
        
    if(i~=1)
        Ping.t((1:nSamples) + (i-1)*nSamples) = HeartBeat.t(i-1)+ (HeartBeat.t(i)-HeartBeat.t(i-1))*(0:(nSamples-1))/(nSamples);
    else
        Ping.t(1:nSamples)                    = HeartBeat.t(i)-1 + (0:(nSamples-1))/(nSamples);
    end
end

fclose(hDataFile);



%Create .ut and .t timebases

    
    
DiveStartTime        = datetime(HeartBeat_UTC_S(1),'ConvertFrom','posixtime') ;
DiveStartTime.Hour   = 0;
DiveStartTime.Minute = 0;
DiveStartTime.Second = 0;
DiveUTC_Dawn_S       = posixtime(DiveStartTime);

HeartBeat.t  = HeartBeat.t - DiveUTC_Dawn_S + UTCshift*3600;
Ping.t       = Ping.t      - DiveUTC_Dawn_S + UTCshift*3600;


% Construct cleaned & sorted ping data:
Ping.nSecOn = 1000*reshape(transpose(squeeze(Ping_RawData(:,2,:))),[1,nPings]); % uSec --> ns duration of ping
Ping.nSecHi =   16*reshape(transpose(squeeze(Ping_RawData(:,3,:))),[1,nPings]); % *16 for 4-bit prescalar
Ping.Pulses =      reshape(transpose(squeeze(Ping_RawData(:,4,:))),[1,nPings]);

% Fix initialization bug in Ping_nSecOn from Teensy code...
Ping.nSecOn(1) = 1e6;

% Find Saturated pings (higher than 99%cutoff during entire ping)
Ping.Saturated     = find(Ping.nSecHi > Click_Cutoff); %1 if valid, 0 if saturated

if (Mask_Saturated_Points == 1)    
    % Set Saturated duration and data to NANs so they don't contribute
    Ping.nSecOn(Ping.Saturated) = NaN;
    Ping.nSecHi(Ping.Saturated) = NaN;
    Ping.Pulses(Ping.Saturated) = NaN;
    %
    Ping.nSecOn(Ping.Saturated +1) = NaN;
    Ping.nSecHi(Ping.Saturated +1) = NaN;
    Ping.Pulses(Ping.Saturated +1) = NaN;
    %
    Ping.nSecOn(Ping.Saturated +2) = NaN;
    Ping.nSecHi(Ping.Saturated +2) = NaN;
    Ping.Pulses(Ping.Saturated +2) = NaN;
    %
    Ping.nSecOn(Ping.Saturated +3) = NaN;
    Ping.nSecHi(Ping.Saturated +3) = NaN;
    Ping.Pulses(Ping.Saturated +3) = NaN;
    %
    Ping.nSecOn(Ping.Saturated -1) = NaN;
    Ping.nSecHi(Ping.Saturated -1) = NaN;
    Ping.Pulses(Ping.Saturated -1) = NaN;
    %
    Ping.nSecOn(Ping.Saturated -2) = NaN;
    Ping.nSecHi(Ping.Saturated -2) = NaN;
    Ping.Pulses(Ping.Saturated -2) = NaN;
    %
    Ping.nSecOn(Ping.Saturated -3) = NaN;
    Ping.nSecHi(Ping.Saturated -3) = NaN;
    Ping.Pulses(Ping.Saturated -3) = NaN;
end


for hb = 1:nHeartBeats
    Ping_Range = (1:nSamples) + nSamples*(hb-1);
    HeartBeat.nSecOn(hb) = sum(Ping.nSecOn(Ping_Range),'omitnan');
    HeartBeat.nSecHi(hb) = sum(Ping.nSecHi(Ping_Range),'omitnan');
    HeartBeat.Pulses(hb) = sum(Ping.Pulses(Ping_Range),'omitnan');
end


Ping.nSecHi_Smoothed = smoothdata(Ping.nSecHi./Ping.nSecOn,'gaussian',100);
Ping.Pulses_Smoothed = smoothdata(Ping.Pulses./Ping.nSecOn,'gaussian',100);

Ping.PulseLength      = Ping.nSecHi      ./ Ping.Pulses;
HeartBeat.PulseLength = HeartBeat.nSecHi ./ HeartBeat.Pulses;

Dive.nSamples    = nSamples;
Dive.nHeartBeats = nHeartBeats;
Dive.nPings      = nPings;
Dive.UTC_Dawn    = DiveUTC_Dawn_S;
Dive.Ping        = Ping;
Dive.HeartBeat   = HeartBeat;



end

