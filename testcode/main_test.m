close all;
clear;

%% FASE A: T_mean DETERMINATION
% synthetic signal (30 bursts)
%load('synthetic_signal.mat');
load('synthetic_signal_intensive.mat');
% filter parameters setting
T.fil0=251; % T_average of the signal: (T_min+T_max)/2
% test various filters
filter_simple=1; % 1=sine; 3=triangle; 2=rectangular
% create Filter 0 
if filter_simple==1
    % sin wave
    fil0=max(sig)*sin(linspace(0,pi,T.fil0))+min(sig);
elseif filter_simple==2
    % rectangular wave
    fil0=zeros(1,100+T.fil0);
    rectg=max(sig)*square(linspace(0,1,T.fil0));
    fil0(51:50+length(rectg))=rectg;
elseif filter_simple==3
    % triangle wave
    fil0=min(sig)+(sawtooth(2*pi*linspace(0,1,T.fil0),0.5)+1)*(max(sig)-min(sig))/2;
end
% figure;
% plot(fil0);

% 1st filtering with fil0
sig1_0=conv(sig,fil0);
% signal shifting to eliminate delay
sig1=circshift(sig1_0,fix(-length(fil0)/2));
% peaks detection
len_sig=length(sig); % length of sig
minpeakdist=150; % minimum distance between peaks
minpeakpro=0.015; % minimum prominence of the peak
% peaks...
[amp_sig1,locs_sig1]=findpeaks(sig1(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist);
figure('Name','SIGNAL AFTER APPLYING FILTER 0');
findpeaks(sig1(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist);
hold on
plot(sig,'r');
% calcu T1 based on the peaks detected
T1=diff(locs_sig1);
T1_mean=mean(T1); % T1_average
T1_save=[]; % save the values of T1

% 2st filtering with fil1
% Filter 1: sin wave with the longitude of T1_average
T.fil1=round(T1_mean);
t1=linspace(0,pi,T.fil1);
fil1=max(sig)*sin(t1)+min(sig);
% application of fil1
sig2_0=conv(sig,fil1);
% signal shifting to eliminate delay
sig2=circshift(sig2_0,fix(-length(fil1)/2));
% peaks...
[amp_sig2,locs_sig2]=findpeaks(sig2(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist);
figure('Name','SIGNAL AFTER APPLYING FILTER 1');
findpeaks(sig2(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist);
hold on
plot(sig,'r');
% calcu T2 based on the peaks detected
T2=diff(locs_sig2);
T2_mean=mean(T2); % T2_average
T2_save=[]; % save the values of T2

T3_save=[]; % save the values of T3
while abs(T2_mean-T1_mean)>2
    % 3st filtering with fil2
    % Filter 2: sin wave with the longitude of T1_average
    T.fil2=round(T2_mean);
    if filter_simple==1
        fil2=max(sig)*sin(linspace(0,pi,T.fil2))+min(sig);
    elseif filter_simple==2
        fil2=zeros(1,100+T.fil2);
        rectg=max(sig)*square(linspace(0,1,T.fil2));
        fil2(51:50+length(rectg))=rectg;
    elseif filter_simple==3
        fil2=min(sig)+(sawtooth(2*pi*linspace(0,1,T.fil2),0.5)+1)*(max(sig)-min(sig))/2;
    end
    % application of fil2
    sig3_0=conv(sig,fil2);
    sig3=circshift(sig3_0,fix(-length(fil2)/2));
    [amp_sig3,locs_sig3]=findpeaks(sig3(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist);
    T3=diff(locs_sig3);
    T3_mean=mean(T3); % T3_average
    T3_save=[T3_save,T3_mean]; % save the value
    T1_save=[T1_save,T1_mean];
    T2_save=[T2_save,T2_mean];
    % variable assignment
    T1_mean=T2_mean;
    T2_mean=T3_mean;
end

% final vaule of T
T.fil2=T2_mean;

%% FASE B: FAITHFULL REPRODUCTION OF PULSE WAVEFORM
% extract the first and second half of a cardiac period respectively
pulseA=round(locs_sig2-T.fil2/2);
pulseB=round(locs_sig2+T.fil2/2);
% make sure the matrix aize does not exceed the original signal size
if pulseA(1)<=0
    pulseA(1)=1; % the signal should start at 1
end
if pulseB(end)>length(sig)
    pulseB(end)=length(sig);
end

% extract all pulses
for i=1:length(pulseA)
    pulse(i).sig=sig(pulseA(i):pulseB(i));
end

% eliminate the 1st & last data: usually the 1st & last pulse signal may not be complete
pulse(1)=[];
pulse(end)=[];
% struct initialization
if isempty(pulse)
    pulse=struct('sig',[]);
end

% for k=1:length(pulse)
%     plot(pulse(k).sig)
%     hold on
% end

% calcu mean of the pulses
fil_sum=zeros(1,length(pulse(1).sig));
for i=1:numel(pulse)
    fil_sum=fil_sum+pulse(i).sig; % sum of the pulses
end
filB=fil_sum/numel(pulse); % filter of average
figure('Name','BLOOD PRESSURE WAVEFORM');
plot(filB);
title('average waveform filter');


%% FASE C: CARDIAC SIGNAL PULSE DETECTION
% adaptive matched filter design
filC=fliplr(filB); % filC(t)=filB(-t)
% application of AMF
hsig1=conv(sig,filC);
% % amplitude normalization referring to 2*hsig_lp
% hsig2=2*(hsig1*(max(abs(sig))/max(abs(hsig1))));
% signal shifting to eliminate delay
hsig=circshift(hsig1,fix(-length(filC)/2));
% peaks (cardiac pulse) detection
[amp_hsig,locs_hsig]=findpeaks(hsig(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist,'MinPeakProminence',minpeakpro);
% plot fig...
figure('Name','CARDIAC PULSE DETECTION');
findpeaks(hsig(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist,'MinPeakProminence',minpeakpro);
text(locs_hsig+.02,amp_hsig,num2str((1:numel(amp_hsig))'))
hold on
plot(sig,'r');


