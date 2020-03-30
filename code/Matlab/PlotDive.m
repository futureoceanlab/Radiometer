% 2020_03_14__05_36_13
%Folder_Name='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/LongOptics/2020_03_14__05_36_13';
%Data_Offset =  0;

% 2020_03_14__13_24_52
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/LongOptics/2020_03_14__13_24_52';
%Data_Offset = 684;  % FOR f01.bin ---- f00.bin missing

% 2020_03_15__00_31_55
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/LongOptics/2020_03_15__00_31_55';
%Data_Offset = 774;


%Mesobot21:     2020_03_14__05_25_08
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/ShortOptics/2020_03_14__05_25_08';
%Data_Offset = 720;
% Fails at HB 16,675 out of 18,310, min 277 of 305

%Mesobot22:     2020_03_14__13_17_53
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/ShortOptics/2020_03_14__13_17_53';
%Data_Offset = 36; % FOR f01.bin ---- f00.bin missing

%Mesobot23:     2020_03_15__00_39_10
%DataFileName='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/ShortOptics/2020_03_15__00_39_10';
%Data_Offset =  0;

%Mesobot24:     2020_03_15__10_18_12
Folder_Name='/Users/allan/Dropbox (MIT)/Armstrong Data/SD Data/ShortOptics/2020_03_15__10_18_12';
Data_Offset =  0;
Dive_Name = 'Mesobot 24';
Separator = '  ::  ';

%Dive = UnpackRadDive(Folder_Name,Data_Offset);

xlims = [1090 1091]; % Bottom of dive
xlims = [850 1200]; % Bottom of dive

%%%%%%%%%
figure(1)
clf
hold on;
%plot(Dive.Ping.t/60,        1e-6 * Dive.Ping.nSecOn                    ,'R','LineWidth',1)
plot(Dive.Ping.t/60, log10(6.3e4 * Dive.Ping.nSecHi./Dive.Ping.nSecOn) ,'G','LineWidth',1)
plot(Dive.Ping.t/60, log10(1.0e6 * Dive.Ping.Pulses./Dive.Ping.nSecOn) ,'B','LineWidth',1)
xlim(xlims)
title(strcat(Dive_Name,Separator,'  Raw Pings'));
xlabel('Minutes since Midnight');
ylabel('Log10(Data)');
legend({'Ping.nSecHi','Ping.Pulses'},'Location','northwest')
hold off;
%%%%%%%%%


%%%%%%%%%
figure(2)
clf
hold on;
plot(Dive.Ping.t/60, log10(6.3e4 * Dive.Ping.nSecHi_Smoothed)  ,'G','LineWidth',1)
plot(Dive.Ping.t/60, log10(1.0e6 * Dive.Ping.Pulses_Smoothed)  ,'B','LineWidth',1)
xlim(xlims)
title(strcat(Dive_Name,Separator,'  50uS Gaussian Avg'));
xlabel('Minutes since Midnight');
ylabel('Log10(Data)');
legend({'Ping.nSecHi','Ping.Pulses'},'Location','northwest')
hold off;
%%%%%%%%%


%%%%%%%%%
figure(3)
clf
hold on;
%plot(Dive.HeartBeat.t/60,   4 + (1e-9 * HeartBeat_nSecOn)                    ,'R','LineWidth',1)
plot(Dive.HeartBeat.t/60, log10(6.3e7 * Dive.HeartBeat.nSecHi./Dive.HeartBeat.nSecOn)  ,'G','LineWidth',1)
plot(Dive.HeartBeat.t/60, log10(1.0e9 * Dive.HeartBeat.Pulses./Dive.HeartBeat.nSecOn)  ,'B','LineWidth',1)
xlim(xlims)
title(strcat(Dive_Name,Separator,'  1S Heartbeats'));
xlabel('Minutes since Midnight');
ylabel('Log10(Data)');
legend({'HeartBeat.nSecHi','HeartBeat.Pulses'},'Location','northwest')
hold off;
%%%%%%%%%


%%%%%%%%%
figure(4)
clf
hold on;
plot(Dive.HeartBeat.t/60, Dive.HeartBeat.PulseLength,'G','LineWidth',1)
%plot(Dive.Ping.t/60,      Dive.Ping.PulseLength     ,'B','LineWidth',1)
ylim([0 150])
title(strcat(Dive_Name,Separator,'  <nanoSeconds per Pulse>'));
xlabel('Minutes since Midnight');
ylabel('HeartBeat.PulseLength');
%legend({'Ping.nSecHi','Ping.Pulses'},'Location','northwest')
hold off;




