function out = RadRead(foldername, divename, radname, UTCshift, outfolder, version)
%%% Jacob Bernstein
%%% RadRead - Read raw radiometer data, save to .mat database
%%% 3.18.2020 

%%% Description
% Input a foldername, RadRead will pull the .txt and .bin files from the folder
% Output a data structure with all raw and derived data:
%   Metadata:
%%%     .foldername
%%%     .
%   Scalars:
%%%     .nPackets - number of packets
%%%     .nHearBeats - number of hearbeats
%%%     .nMinutes - number of minutes recorded (integer)
%%%     .nPings - number of pings
%   Vectors
%%%     .ping_us - microseconds per ping
%%%     .ping_Pulses - pulses per ping
%%%     .ping_PcntHi - percent time high per ping
%%%
%%%     .perS_UTC_S
%%%     .perS_UTC_u
%%%     .perS_X_inc
%%%     .perS_Y_inc
%%%     .perS_Pulses
%%%     .perS_PcntHi
%%%     .perS_Secs

%% Process Function Inputs
switch nargin
    case 0
        foldername = [];
        divename = [];
        radname = [];
        UTCshift = [];
        outfolder =[];
        version = [];
    case 1
        divename = [];                    
        radname = [];
        UTCshift = [];
        outfolder =[];
        version = [];
    case 2
        radname = [];
        UTCshift = [];
        outfolder =[];
        version = [];
    case 3
        UTCshift = [];
        outfolder =[];
        version = [];
end

if isempty(foldername)
    folderpath = uigetdir('Select Dive Folder');
    cd(folderpath);
else
    cd(foldername);      
end

%[~,filestem,~] = fileparts(filename);

if isempty(divename)
    divename = input('Input dive name:','s');
end

if isempty(radname)
    radname = input('Input radiometer name:','s');
end

if isempty(UTCshift)
    UTCshift = input('Input local time shift relative to UTC (hours):');
end
    
%% Open Files
MetaFile = dir('*.txt');
DataFiles = dir('*.bin');
DataFileName = DataFiles(1).name;
MetaFileName= MetaFile(1).name;

hDataFile = fopen(DataFileName);


% Specify samples per heartbeat -- should get ffrom Meta, but this is 
% faster to code. Sorry, user (aka future me)!
out.Nsamples = 1000; % 2000, 4000, 8000, 10000, 16000, 25000, 40000  

fileInfo = DataFiles(1);

% Each Data packet is 8B, and each heartbeat is 16B, so we can infer the 
% number of complete heartbeats (aka number of seconds) from file size:
out.nPackets    = floor(fileInfo.bytes / 8);
out.nHeartBeats = floor(out.nPackets/(out.Nsamples+2));
out.nMinutes    = floor(out.nHeartBeats/60);
out.nPings      = out.nHeartBeats *  out.Nsamples;

% Raw data: 
%    Data per Ping 
Ping_Data        = zeros(out.nHeartBeats,4,out.Nsamples);
out.ping_uS_delta = zeros(out.nHeartBeats,out.Nsamples);
out.ping_Pulses  = zeros(out.nHeartBeats,out.Nsamples);
out.ping_TimeHi  = zeros(out.nHeartBeats,out.Nsamples);

%    Data per Heartbeat 
out.perS_UTC_S  = zeros(1,out.nHeartBeats);
out.perS_mS_elapsed  = zeros(1,out.nHeartBeats);
out.perS_X_inc  = zeros(1,out.nHeartBeats);
out.perS_Y_inc  = zeros(1,out.nHeartBeats);

% Derived Data:
%    Ping Data per Second technically, per HB)
out.perS_Secs   = zeros(1,out.nHeartBeats);
out.perS_Pulses = zeros(1,out.nHeartBeats);
out.perS_PcntHi = zeros(1,out.nHeartBeats);
%    Ping Data per Minute technically, per 60 HB)
%Data_Secs_perM   = zeros(1,nMinutes);
%Data_Pulses_perM = zeros(1,nMinutes);
%Data_PcntHi_perM = zeros(1,nMinutes);


for i = 1:out.nHeartBeats

    Ping_Data(i,:,:)    = fread(hDataFile,[4,out.Nsamples],'uint16=>uint16');

    TokenD              = sum(squeeze(Ping_Data(i,1,:)));
    if (TokenD ~= 252 * out.Nsamples) %0xFC
        fprintf('Found a wrong TokenD at HeartBeat [%u]! \nShould be [%u], but we got [%u].\n', i, 252 * Nsamples,TokenD)
        break;
    end
    
    out.ping_uS_delta(i,:) = squeeze(Ping_Data(i,2,:));
    %out.ping_Pulses(i,:) = squeeze(Ping_Data(i,3,:));
    %out.ping_TimeHi(i,:) = squeeze(Ping_Data(i,4,:));
    out.ping_TimeHi(i,:) = squeeze(Ping_Data(i,3,:));
    out.ping_Pulses(i,:) = squeeze(Ping_Data(i,4,:));
    
    
    out.perS_Secs(i)   = sum(squeeze(out.ping_uS_delta(i,:)))/1000000;
    out.perS_Pulses(i) = sum(squeeze(out.ping_Pulses(i,:)));
%    Data_PcntHi_perS(i) = 16*sum(squeeze(Ping_Data(i,4,:)))/10000000;
    out.perS_PcntHi(i) = (16/1e7)*double(sum(squeeze(out.ping_TimeHi(i,:))));

    TokenA              = fread(hDataFile,1,'uint16=>uint16');
    if (TokenA ~= 253) %0xFD
        fprintf('Found a wrong TokenA at HeartBeat [%u]! \nShould be [%u], but we got [%u].\n',i,253,TokenA)
        break;
    end

    out.perS_X_inc(i)  = fread(hDataFile,1,'uint16=>uint16');
    out.perS_UTC_S(i)  = fread(hDataFile,1,'uint32=>uint32');

    TokenB              = fread(hDataFile,1,'uint16=>uint16');
    if (TokenB ~= 254) %0xFE
        fprintf('Found a wrong TokenB at HeartBeat [%u]! \nShould be [%u], but we got [%u].\n',i,254,TokenB)
        break;
    end

    out.perS_Y_inc(i)  = fread(hDataFile,1,'uint16=>uint16');
    out.perS_mS_elapsed(i)  = fread(hDataFile,1,'uint32=>uint32');

end
fclose(hDataFile);

%% Postprocess
%Reshape the ping data
out.ping_uS_delta = reshape(out.ping_uS_delta,[],1);
out.ping_Pulses = reshape(out.ping_Pulses,[],1);
out.ping_TimeHi = reshape(out.ping_TimeHi,[],1);
out.ping_PcntHi = (16/1e4)*out.ping_TimeHi;

%Create .ut and .t timebases
starttime = datetime(out.perS_UTC_S(1),'ConvertFrom','posixtime') + hours(UTCshift);
startsecond = 60*(60*starttime.Hour + starttime.Minute) + starttime.Second;
out.perS_t = startsecond + [0:length(out.perS_Secs)-1];

out.ping_t = startsecond + 1e-3*[0:length(out.ping_uS_delta)-1];

%% Save Data
if ~isempty(outfolder)
    if isempty(version)
        version = input('What is the version number?:');
    end
    currdir = pwd;
    cd(outfolder);
    fname = sprintf('RadData_%s_%s_%02d',divename,radname,version);
    save(fname,'out');
    cd(currdir);
end
%{
for   m  = 1:nMinutes
    
    for  s=1:60
        i = 60*(m-1)+s;
        Data_Secs_perM(m)   = Data_Secs_perM(m)   + perS_Secs(i);
        Data_Pulses_perM(m) = Data_Pulses_perM(m) + perS_Pulses(i);
        Data_PcntHi_perM(m) = Data_PcntHi_perM(m) + perS_PcntHi(i);
    end
    
end

Data.nHeartBeats = nHeartBeats;
Data.Pulses_perS = perS_Pulses;
Data.PcntHi_perM = Data_PcntHi_perM;

figure(2)
clf
hold on;
% plot(((1:nHeartBeats)/60),Data_Secs_perS(1:nHeartBeats) ,'R','LineWidth',1)
plot(((1:nHeartBeats)/60),log10(perS_Pulses(1:nHeartBeats)),'G','LineWidth',1)
plot(((1:nHeartBeats)/60),log10(perS_PcntHi(1:nHeartBeats)),'B','LineWidth',1)
hold off;

TMP_Pulses = reshape(transpose(squeeze(Ping_Data(:,4,:))),[1,nPings]);
TMP_TimeHi = reshape(transpose(squeeze(Ping_Data(:,3,:))),[1,nPings]);

figure(3)
clf
hold on;
plot(((1:nPings)),log10(TMP_Pulses(1:nPings)) ,'B','LineWidth',1)
plot(((1:nPings)),log10(TMP_TimeHi(1:nPings)) ,'G','LineWidth',1)
hold off;

N_fft = nPings/2 +1;

fft_Pulses = fft(TMP_Pulses);
fft_Pulses_P2 = abs(fft_Pulses/nPings);
fft_Pulses_P1 = fft_Pulses_P2(1:N_fft);
fft_Pulses_P1(2:end-1) = 2*fft_Pulses_P1(2:end-1);

fft_TimeHI = fft(TMP_TimeHi);
fft_TimeHI_P2 = abs(fft_TimeHI/nPings);
fft_TimeHI_P1 = fft_TimeHI_P2(1:N_fft);
fft_TimeHI_P1(2:end-1) = 2*fft_TimeHI_P1(2:end-1);

figure(4)
PlotRange4 = 1:nPings/20;
clf
hold on;
plot(PlotRange4, log10(fft_TimeHI_P1(PlotRange4)) ,'G','LineWidth',1)
plot(PlotRange4, log10(fft_Pulses_P1(PlotRange4)) ,'B','LineWidth',1)
hold off;



% hSecData = fopen('~/CPS.bin','w+');
% fwrite(hSecData,sCounts,'double');
% fclose(hSecData);
%}
