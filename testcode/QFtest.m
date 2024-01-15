% QF TEST BASED ON SYNTHETIC SIGNAL
% RC 03/11/2023
close all;
clear;

% load the adaptive matched filter and the signal to be tested
load('AMF_hd.mat'); %AMF
% synthetic signal (30 bursts)
load('synthetic_signal.mat');
% figure;
% plot(sig);
original=hd;

% peaks (cardiac pulse) detection
len_sig=length(sig); % length of sig
% minimum distance between peaks
minpeakdist=150;

% confirmation of the QF curve with diff lon of the filter
%interpfactor=[0.5;0.6;0.7;0.8;0.9;1;1.1;1.2;1.3;1.4;1.5];
interpfactor=[0.6;0.65;0.7;0.75;0.8;0.85;0.9;0.95;1;1.05;1.1;1.15;1.2;1.25;1.3;1.35;1.4;1.45;1.5]; % more intensive
for i=1:length(interpfactor)
    Filter(i).len=interp1((1:length(original)).',original,linspace(1,length(original),length(original)*interpfactor(i)).','linear');
    filsig(i).sig=circshift(conv(sig,Filter(i).len),fix(-length(original)/2));
    [Peak(i).amp,Peak(i).loc]=findpeaks(filsig(i).sig(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist);
    % subplot(length(interpfactor),1,i)
    % findpeaks(filsig(i).sig(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist);
    % text(Peak(i).loc+.02,Peak(i).amp,num2str((1:numel(Peak(i).amp))'))
    % hold on
    % plot(sig,'r');
    QF(i)=(sum(Peak(i).amp.^2)/length(Peak(i).loc))/(sum(abs(filsig(i).sig).^2)/length(filsig(i).sig));
end

% plot the QF curve
figure;
plot(interpfactor,QF,'-x','MarkerEdgeColor','r')
grid on
title('Quality Factors')
% more plots...
i=7; % select the filter
figure;
findpeaks(filsig(i).sig(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist);
text(Peak(i).loc+.02,Peak(i).amp,num2str((1:numel(Peak(i).amp))'))
hold on
plot(sig,'r');


