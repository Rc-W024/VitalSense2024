function [phasePlot]=plotPhasewu(Radar,Digitizer,Sampling,LocFinder,Spec_shift,RMS_Amplitude,DoUnWrapping,titleText)
% PLOTPHASE Summary of this function goes here
% Detailed explanation goes here

phasePlot=figure('Name',titleText,'NumberTitle','off');
    for i=1:length(LocFinder.locs_positive)
        lineWithPeak=find(Sampling.f==LocFinder.locs_positive(i));
        if DoUnWrapping==true
            angleArray=1000*(Radar.lambda/(4*pi))*unwrap(angle(Spec_shift(lineWithPeak,1:Digitizer.wfrm))-angle(Spec_shift(lineWithPeak,1)));
        else
            angleArray=angle(Spec_shift(lineWithPeak,1:Digitizer.wfrm))-angle(Spec_shift(lineWithPeak,1));
        end

        plot(Radar.t_frame,(angleArray))
        title(['Phase of Frequency ',num2str(LocFinder.locs_positive(i)),'Hz @ ',num2str((Radar.Tm*Radar.c_0 .*LocFinder.locs_positive(i))/(2*Radar.deltaf)),' m'])   
        
        if DoUnWrapping==true
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
        ax.YAxis(1).Color=[0, 0.4470, 0.7410];
    end
end

