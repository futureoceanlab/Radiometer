DataFileName='FOL_WHOI_Radiometer_2020_03_13__19_02_29_f00.bin';
MetaFileName='FOL_WHOI_Radiometer_2020_03_13__19_02_29_f00.txt';

%hMetaFile = fopen(MetaFileName);
hDataFile = fopen(DataFileName);

% Specify samples per heartbeat -- should get ffrom Meta, but this is 
% faster to code. Sorry, user (aka future me)!
Nsamples = 1000; % 2000, 4000, 8000, 10000, 16000, 25000, 40000  

% fseek(hDataFile, 0, 'eof');
% Nchunks =  ftell(hDataFile)/4096;
% fseek(hDataFile, 0, 'bof');

fileInfo = dir(DataFileName);

% Each Data packet is 8B, and each heartbeat is 16B, so we can infer the 
% number of complete heartbeats (aka number of seconds) from file size:
nPackets    = floor(fileInfo.bytes / 8);
nHeartBeats = floor(nPackets/(Nsamples+2));
nMinutes    = floor(nSecs/60);

% Raw data: 
%    Data per Ping 
Ping_Data        = zeros(nHeartBeats,4,NSamples);
%    Data per Heartbeat 
HeartBeat_UTC_S  = zeros(1,nHeartBeats);
HeartBeat_UTC_u  = zeros(1,nHeartBeats);
HeartBeat_X_inc  = zeros(1,nHeartBeats);
HeartBeat_Y_inc  = zeros(1,nHeartBeats);


% Derived Data:
%    Ping Data per Second technically, per HB)
Data_uSecs_perS  = zeros(1,nHeartBeats);
Data_Pulses_perS = zeros(1,nHeartBeats);
Data_TimeHi_perS = zeros(1,nHeartBeats);
%    Ping Data per Minute technically, per 60 HB)
Data_uSecs_perM  = zeros(1,nMinutes);
Data_Pulses_perM = zeros(1,nMinutes);
Data_TimeHi_perM = zeros(1,nMinutes);


for i = 1:nHeartBeats
Ping_Data(i,:,:)    = fread(hDataFile,[4,Nsamples],'uint16=>uint16');

TokenD              = sum(squeeze(Ping_Data(i,1,:)));
if (TokenD ~= 64764 * NSamples) %0xFCFC
    fprintf('Found a wrong Token in Ping_Data! \nShould be [%u], but we got [%u].\n',  64764 * NSamples,TokenA)
    break;
end

Data_uSecs_perS(i)  = sum(squeeze(Ping_Data(i,2,:)));
Data_Pulses_perS(i) = sum(squeeze(Ping_Data(i,3,:)));
Data_TimeHi_perS(i) = sum(squeeze(Ping_Data(i,4,:)));

TokenA              = fread(hDataFile,1,'uint16=>uint16');
if (tokenA ~= 65021) %0xFDFD 
    fprintf('Found a wrong Token in HeartBeat B! \nShould be [%u], but we got [%u].\n',65021 * NSamples,TokenA)
    break;
end

HeartBeat_X_inc(i)  = fread(hDataFile,1,'uint16=>uint16');
HeartBeat_UTC_S(i)      = fread(hDataFile,1,'uint32=>uint32');

TokenB              = fread(hDataFile,1,'uint16=>uint16');
if (tokenB ~= 65278) %0xFEFE
    fprintf('Found a wrong Token in HeartBeat B! \nShould be [%u], but we got [%u].\n',65278 * NSamples,TokenB)
    break;
end

HeartBeat_Y_inc(i)  = fread(hDataFile,1,'uint16=>uint16');
HeartBeat_UTC_u(i)     = fread(hDataFile,1,'uint32=>uint32');

end

fclose(hDataFile);

for   m  = 1:nMinutes
    
    for  s=1:60
        i = 60*(m-1)+s;
        Data_uSecs_perM(m)  = Data_uSecs_perM(m)  + Data_uSecs_perS(i);
        Data_Pulses_perM(m) = Data_Pulses_perM(m) + Data_Pulses_perS(i);
        Data_TimeHi_perM(m) = Data_TimeHi_perM(m) + Data_TimeHi_perS(i);
    end
    
end

figure(2)
clf
hold on;
plot(1:nMinutes,log10(Minute_Pulses(1:end)/60),'b','LineWidth',3)
plot(((1:nHeartBeats)/60),log10(Data_Pulses_perS(1:nHeartBeats)),'g','LineWidth',1)
%plot((61:nMins*60)/60,log10(sCounts(61:nMins*60)),'.','MarkerSize',1)
%plot((61:nMinutes*60)/60,log10(Minute_Pulses(61:nMins*60)),'g','LineWidth',1)
hold off;


% hSecData = fopen('~/CPS.bin','w+');
% fwrite(hSecData,sCounts,'double');
% fclose(hSecData);
