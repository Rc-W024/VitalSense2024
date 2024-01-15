function result = makeFreqPlots(Spec_abs_dBDivided,LocationsDivided,Sampling,Radar,decimationOfBandwidth)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
freqPlotsDivided = figure('Name','Time and Frequency Domain','NumberTitle','off');
distanceOfObject = (Radar.Tm * Radar.c_0 .*Sampling.f)/(2*Radar.deltaf/decimationOfBandwidth);

for k=1:decimationOfBandwidth
    subplot(decimationOfBandwidth,1,k);
    distanceOfObjectShift = distanceOfObject-(max(distanceOfObject)/2);
    plot(distanceOfObjectShift,fftshift(Spec_abs_dBDivided{k}(:,1:size(Spec_abs_dBDivided{k},2)/10:size(Spec_abs_dBDivided{k},2))));
    
    hold on;
    plot((Radar.Tm * Radar.c_0 .*LocationsDivided{k}.locs)/(2*Radar.deltaf/decimationOfBandwidth),LocationsDivided{k}.pks,'gd','LineWidth',2)
    title('Spectrum');
    xlabel('Range in m')
    ylabel('Magn in dB')
    xlim([-1.5 1.5])
    ylim([-40 2])
    grid on;
end

% plot(t,beatingTone_time(:,1:size(beatingTone_time,2)/10:size(beatingTone_time,2)));
% title('Time Domain of Chirps');
% xlabel('t (s)')
% ylabel('Amplitude ()')


result = 1;



% RMS_Amplitude = zeros(Digitizer.wfrm,1);
% for k=1:Digitizer.wfrm
%     RMS_Amplitude(k) = sqrt(mean(beatingTone_time(:,k).^2));
% end
% 
% 
% % Produce Unwrap Plot
% UnwrapUncorrected = plotPhase(Radar,Digitizer,Sampling,LocFinder,Spectrum,RMS_Amplitude,true,'UNWRAP');
% NowrapUncorrected = plotPhase(Radar,Digitizer,Sampling,LocFinder,Spectrum,RMS_Amplitude,false,'STANDARD');


end