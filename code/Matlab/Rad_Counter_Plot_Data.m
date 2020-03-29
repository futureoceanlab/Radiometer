% LongOptics

% 2020_03_14__05_36_13
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/LongOptics/2020_03_14__05_36_13/FOL_WHOI_Radiometer_2020_03_14__05_36_13.bin';
%Data_Offset =  0;
%Works

% 2020_03_14__13_24_52
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/LongOptics/2020_03_14__13_24_52/FOL_WHOI_Radiometer_2020_03_14__13_24_52_f01.bin';
%Data_Offset = 684;  % FOR f01.bin ---- f00.bin missing
%Works

% 2020_03_15__00_31_55
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/LongOptics/2020_03_15__00_31_55/FOL_WHOI_Radiometer_2020_03_15__00_31_55.bin';
%Data_Offset = 774;
%Works


% ShortOptics

%Mesobot21:     2020_03_14__05_25_08
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/ShortOptics/2020_03_14__05_25_08/FOL_WHOI_Radiometer_2020_03_14__05_25_08.bin';
%Data_Offset = 720;
% Fails at HB 16,675 out of 18,310, min 277 of 305

%Mesobot22:     2020_03_14__13_17_53
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/ShortOptics/2020_03_14__13_17_53/FOL_WHOI_Radiometer_2020_03_14__13_17_53_f01.bin';
%Data_Offset = 36; % FOR f01.bin ---- f00.bin missing
%Works

%Mesobot23:     2020_03_15__00_39_10
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/ShortOptics/2020_03_15__00_39_10/FOL_WHOI_Radiometer_2020_03_15__00_39_10.bin';
%Data_Offset =  0;
%Works

%Mesobot24:     2020_03_15__10_18_12
DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/ShortOptics/2020_03_15__10_18_12/FOL_WHOI_Radiometer_2020_03_15__10_18_12.bin';
Data_Offset =  0;
%Works



%hMetaFile = fopen(MetaFileName);
hDataFile = fopen(DataFileName);

% Specify samples per heartbeat -- should get ffrom Meta, but this is 
% faster to code. Sorry, user (aka future me)!
Nsamples = 1000; % 2000, 4000, 8000, 10000, 16000, 25000, 40000  
Click_Cutoff = floor(999000); % timeHi above this considered saturated

fileInfo = dir(DataFileName);

% Each Data packet is 8B, and each heartbeat is 16B, so we can infer the 
% number of complete heartbeats (aka number of seconds) from file size:
nPackets    = floor(fileInfo.bytes / 8);

if (Data_Offset ~= 0)
    % subtract off leading packets and initial heartbeat
    nPackets    = nPackets - (Data_Offset+2); 
    % Advance file pointer to start of fresh data
    fread(hDataFile,Data_Offset+2,'uint64=>uint64');
end

nHeartBeats = floor(nPackets/(Nsamples+2));
nMinutes    = floor(nHeartBeats/60);
nPings      = nHeartBeats *  Nsamples;

% Raw data: 
%    Data per Ping 
Ping_Data        = zeros(nHeartBeats,4,Nsamples);
%    Data per Heartbeat 
HeartBeat_UTC_S  = zeros(1,nHeartBeats);
HeartBeat_UTC_u  = zeros(1,nHeartBeats);
HeartBeat_X_inc  = zeros(1,nHeartBeats);
HeartBeat_Y_inc  = zeros(1,nHeartBeats);


% Derived Data:
%   Per Ping data
% Ping_nSecOn = zeros(1,nPings); % 
% Ping_nSecHi = zeros(1,nPings); % 
% Ping_Pulses = zeros(1,nPings); % 

%   Per Heartbeat Data
HeartBeat_nSecOn = zeros(1,nHeartBeats);
HeartBeat_nSecHi   = zeros(1,nHeartBeats);
HeartBeat_Pulses   = zeros(1,nHeartBeats);

%   Per Minute Data (technically, per 60 HB)
Minute_nSecOn = zeros(1,nMinutes);
Minute_nSecHi   = zeros(1,nMinutes);
Minute_Pulses   = zeros(1,nMinutes);


% Loop over heartbeats and read the data...
for i = 1:nHeartBeats

    Ping_Data(i,:,:)    = fread(hDataFile,[4,Nsamples],'uint16=>uint16');

    TokenD              = sum(squeeze(Ping_Data(i,1,:)));
    if (TokenD ~= 252 * Nsamples) %0xFC
        fprintf('Found a wrong TokenD at HeartBeat [%u]! \nShould be [%u], but we got [%u].\n', i, 252 * Nsamples,TokenD)
        break;
    end
    
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



% Construct cleaned & sorted ping data:
Ping_nSecOn = 1000*reshape(transpose(squeeze(Ping_Data(:,2,:))),[1,nPings]); % uSec --> ns duration of ping
Ping_nSecHi =   16*reshape(transpose(squeeze(Ping_Data(:,3,:))),[1,nPings]); % *16 for 4-bit prescalar
Ping_Pulses =      reshape(transpose(squeeze(Ping_Data(:,4,:))),[1,nPings]);

% Fix initialization bug in Ping_nSecOn from Teensy code...
Ping_nSecOn(1) = 1e6;

% Find Saturated pings (higher than 99%cutoff during entire ping)
Saturated_Pings     = find(Ping_nSecHi > Click_Cutoff); %1 if valid, 0 if saturated

% Set Saturated duration to zero and data to NANs so they don't plot
Ping_nSecOn(Saturated_Pings) = NaN;
Ping_nSecHi(Saturated_Pings) = NaN;
Ping_Pulses(Saturated_Pings) = NaN;

Ping_nSecOn(Saturated_Pings +1) = NaN;
Ping_nSecHi(Saturated_Pings +1) = NaN;
Ping_Pulses(Saturated_Pings +1) = NaN;

Ping_nSecOn(Saturated_Pings +2) = NaN;
Ping_nSecHi(Saturated_Pings +2) = NaN;
Ping_Pulses(Saturated_Pings +2) = NaN;

Ping_nSecOn(Saturated_Pings +3) = NaN;
Ping_nSecHi(Saturated_Pings +3) = NaN;
Ping_Pulses(Saturated_Pings +3) = NaN;

Ping_nSecOn(Saturated_Pings -1) = NaN;
Ping_nSecHi(Saturated_Pings -1) = NaN;
Ping_Pulses(Saturated_Pings -1) = NaN;

Ping_nSecOn(Saturated_Pings -2) = NaN;
Ping_nSecHi(Saturated_Pings -2) = NaN;
Ping_Pulses(Saturated_Pings -2) = NaN;

Ping_nSecOn(Saturated_Pings -3) = NaN;
Ping_nSecHi(Saturated_Pings -3) = NaN;
Ping_Pulses(Saturated_Pings -3) = NaN;




for hb = 1:nHeartBeats
    Ping_Range = (1:Nsamples) + Nsamples*(hb-1);
    HeartBeat_nSecOn(hb) = sum(Ping_nSecOn(Ping_Range),'omitnan');
    HeartBeat_nSecHi(hb) = sum(Ping_nSecHi(Ping_Range),'omitnan');
    HeartBeat_Pulses(hb) = sum(Ping_Pulses(Ping_Range),'omitnan');
end

for   m  = 1:nMinutes
    HB_Range = (1:60) + 60*(m-1);    
    Minute_nSecOn(m) = sum(HeartBeat_nSecOn(HB_Range),'omitnan');
    Minute_nSecHi(m) = sum(HeartBeat_nSecHi(HB_Range),'omitnan');
    Minute_Pulses(m) = sum(HeartBeat_Pulses(HB_Range),'omitnan');
end


%%%%%%%%%
figure(1)
clf
hold on;
plot((1:nPings)/60000,            Ping_nSecOn(1:nPings) /1e6                     ,'R','LineWidth',1)
plot((1:nPings)/60000,log10(1e6 * Ping_nSecHi(1:nPings)./Ping_nSecOn(1:nPings))  ,'G','LineWidth',1)
plot((1:nPings)/60000,log10(1e6 * Ping_Pulses(1:nPings)./Ping_nSecOn(1:nPings))  ,'B','LineWidth',1)
hold off;
%%%%%%%%%


%%%%%%%%%
figure(2)
clf
hold on;
plot(((1:nHeartBeats)/60),            HeartBeat_nSecOn(1:nHeartBeats) /1e9                               ,'R','LineWidth',1)
plot(((1:nHeartBeats)/60),log10(1e9 * HeartBeat_nSecHi(1:nHeartBeats)./HeartBeat_nSecOn(1:nHeartBeats))  ,'G','LineWidth',1)
plot(((1:nHeartBeats)/60),log10(1e9 * HeartBeat_Pulses(1:nHeartBeats)./HeartBeat_nSecOn(1:nHeartBeats))  ,'B','LineWidth',1)
hold off;
%%%%%%%%%


%%%%%%%%%

Ping_PulseLength      = Ping_nSecHi      ./ Ping_Pulses;
HB_PulseLength = HeartBeat_nSecHi ./ HeartBeat_Pulses;

figure(3)
clf
hold on;
plot(((1:nHeartBeats)), HB_PulseLength(1:nHeartBeats)-10,'G','LineWidth',1)
%plot((1:nPings)/1000,     Ping_PulseLength(1:nPings)   ,'B','LineWidth',1)
ylim([0 100])
hold off;


% %%%%%%%%%
% 
% 
% N_fft = nPings/2 +1;
% 
% fft_Pulses = fft(TMP_Pulses);
% fft_Pulses_P2 = abs(fft_Pulses/nPings);
% fft_Pulses_P1 = fft_Pulses_P2(1:N_fft);
% fft_Pulses_P1(2:end-1) = 2*fft_Pulses_P1(2:end-1);
% 
% fft_nSecHI = fft(TMP_nSecHi);
% fft_nSecHI_P2 = abs(fft_nSecHI/nPings);
% fft_nSecHI_P1 = fft_nSecHI_P2(1:N_fft);
% fft_nSecHI_P1(2:end-1) = 2*fft_nSecHI_P1(2:end-1);
% 
% 
% %%%%%%%%%
% figure(4)
% PlotRange4 = 1:nPings/20;
% clf
% hold on;
% plot(PlotRange4, log10(fft_nSecHI_P1(PlotRange4)) ,'G','LineWidth',1)
% plot(PlotRange4, log10(fft_Pulses_P1(PlotRange4)) ,'B','LineWidth',1)
% hold off;
% %%%%%%%%%



