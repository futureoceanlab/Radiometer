% DataFileName='FOL_WHOI_Radiometer_2020_03_14__20_40_57_f00.bin';
%MetaFileName='FOL_WHOI_Radiometer_2020_03_14__20_40_57.txt';

DataFileName='FOL_WHOI_Radiometer_2020_03_14__22_58_28_f00.bin';
MetaFileName='FOL_WHOI_Radiometer_2020_03_14__22_58_28.txt';

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
nMinutes    = floor(nHeartBeats/60);

% Raw data: 
%    Data per Ping 
Ping_Data        = zeros(nHeartBeats,4,Nsamples);
%    Data per Heartbeat 
HeartBeat_UTC_S  = zeros(1,nHeartBeats);
HeartBeat_UTC_u  = zeros(1,nHeartBeats);
HeartBeat_X_inc  = zeros(1,nHeartBeats);
HeartBeat_Y_inc  = zeros(1,nHeartBeats);

% Derived Data:
%    Ping Data per Second technically, per HB)
Data_Secs_perS   = zeros(1,nHeartBeats);
Data_Pulses_perS = zeros(1,nHeartBeats);
Data_PcntHi_perS = zeros(1,nHeartBeats);
%    Ping Data per Minute technically, per 60 HB)
Data_Secs_perM   = zeros(1,nMinutes);
Data_Pulses_perM = zeros(1,nMinutes);
Data_PcntHi_perM = zeros(1,nMinutes);


for i = 1:nHeartBeats

    Ping_Data(i,:,:)    = fread(hDataFile,[4,Nsamples],'uint16=>uint16');

    TokenD              = sum(squeeze(Ping_Data(i,1,:)));
    if (TokenD ~= 252 * Nsamples) %0xFC
        fprintf('Found a wrong TokenD at HeartBeat [%u]! \nShould be [%u], but we got [%u].\n', i, 252 * Nsamples,TokenD)
        break;
    end

    Data_Secs_perS(i)   = sum(squeeze(Ping_Data(i,2,:)))/1000000;
    Data_Pulses_perS(i) = sum(squeeze(Ping_Data(i,3,:)));
%    Data_PcntHi_perS(i) = 16*sum(squeeze(Ping_Data(i,4,:)))/10000000;
    Data_PcntHi_perS(i) = sum(squeeze(Ping_Data(i,4,:)));

    TokenA              = fread(hDataFile,1,'uint16=>uint16');
    if (TokenA ~= 253) %0xFD
        fprintf('Found a wrong TokenA at HeartBeat [%u]! \nShould be [%u], but we got [%u].\n',i,253,TokenA)
        break;
    end

    HeartBeat_X_inc(i)  = fread(hDataFile,1,'uint16=>uint16');
    HeartBeat_UTC_S(i)  = fread(hDataFile,1,'uint32=>uint32');

    TokenB              = fread(hDataFile,1,'uint16=>uint16');
    if (TokenB ~= 254) %0xFE
        fprintf('Found a wrong TokenB at HeartBeat [%u]! \nShould be [%u], but we got [%u].\n',i,254,TokenB)
        break;
    end

    HeartBeat_Y_inc(i)  = fread(hDataFile,1,'uint16=>uint16');
    HeartBeat_UTC_u(i)  = fread(hDataFile,1,'uint32=>uint32');

end

fclose(hDataFile);

for   m  = 1:nMinutes
    
    for  s=1:60
        i = 60*(m-1)+s;
        Data_Secs_perM(m)   = Data_Secs_perM(m)   + Data_Secs_perS(i);
        Data_Pulses_perM(m) = Data_Pulses_perM(m) + Data_Pulses_perS(i);
        Data_PcntHi_perM(m) = Data_PcntHi_perM(m) + Data_PcntHi_perS(i);
    end
    
end

figure(2)
clf
hold on;
plot(((1:nHeartBeats)/60),Data_Secs_perS(1:nHeartBeats) ,'R','LineWidth',1)
plot(((1:nHeartBeats)/60),log10(Data_Pulses_perS(1:nHeartBeats)),'G','LineWidth',1)
plot(((1:nHeartBeats)/60),log10(Data_PcntHi_perS(1:nHeartBeats)),'B','LineWidth',1)
hold off;


% hSecData = fopen('~/CPS.bin','w+');
% fwrite(hSecData,sCounts,'double');
% fclose(hSecData);
