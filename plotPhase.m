function [phasePlot]=plotPhase(Radar,Digitizer,Sampling,LocFinder,Spec_shift,RMS_Amplitude,DoUnWrapping,titleText,ECGSignal)
% PLOTPHASE Summary of this function goes here
% Detailed explanation goes here

phasePlot=figure('Name',titleText,'NumberTitle','off');
    for k=1:(length(LocFinder.locs_positive))
        Plot(k)=subplot(length(LocFinder.locs_positive)*2+1,1,(k*2)-1:(k*2));
        lineWithPeak=find(Sampling.f==LocFinder.locs_positive(k));
        if(DoUnWrapping==true)
            angleArray=1000*(Radar.lambda/(4*pi))*unwrap(angle(Spec_shift(lineWithPeak,1:Digitizer.wfrm))-angle(Spec_shift(lineWithPeak,1)));
        else
            angleArray=(angle(Spec_shift(lineWithPeak,1:Digitizer.wfrm)))-(angle(Spec_shift(lineWithPeak,1)));
        end
%         for l=2:(length(angleArray)-1)
%             angleArray(1,l+1)=angleArray(1,l+1)-angleArray(1,l);
%         end
%         ax(k)=nexttile;
        plot(Radar.t_frame,(angleArray))
        title(['Phase of Frequency ',num2str(LocFinder.locs_positive(k)),'Hz @ ',num2str((Radar.Tm*Radar.c_0 .*LocFinder.locs_positive(k))/(2*Radar.deltaf)),' m'])   
        
        if(DoUnWrapping==true)
            ylabel('Offset (mm)')
        else
            ylabel('\phi (rad)')
            ylim([-pi pi])
        end
        yyaxis right
        plot(Radar.t_frame,mag2db(RMS_Amplitude/max(RMS_Amplitude)));
        ylabel('Magnitude (dB)')
        grid on
        ax=gca;
        ax.YAxis(1).Color=[0,0.4470,0.7410];
    end

decimatedECGSignal=ECGSignal(1:Digitizer.long:end);
%         buttonPlot=plot(Radar.t_frame,decimatedButtonSignal/35000);
%         buttonPlot.Color='green';
axECG=subplot(length(LocFinder.locs_positive)*2+1,1,length(LocFinder.locs_positive)*2+1);
% =nexttile;
voltageRangeChannelB=10;
plot(Radar.t_frame,(double(decimatedECGSignal-2^15)/2^16)*voltageRangeChannelB,'g') % 1000e-3*(double(v-2^15)/2^16)
grid on;
ylabel('ECG')
xlabel('Time (s)')
% axButtonPlot=gca;
% set(axButtonPlot,height,)
linkaxes([Plot(1) axECG],'x')
end

