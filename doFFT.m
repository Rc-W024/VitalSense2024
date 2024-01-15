function [Spectrum,Spec_abs_dB] = doFFT(timeSignalMatrix,Sampling,Digitizer,decimationOfBandwidth)
%Function uses a Window, FFT and converts Spectrum in dB
%   Detailed explanation goes here

win_r_z = window('hann', Digitizer.long);
beatingTone_time_window = cell(1, decimationOfBandwidth);
for k=1:decimationOfBandwidth
    beatingTone_time_window{k}=zeros(Digitizer.long,Digitizer.wfrm);
end

% for k=1:wfrm
%     data0_2(:,k) = conv(data0(:,k),win_r_z,'same');
% end

for k=1:decimationOfBandwidth
    for l=1:Digitizer.wfrm
        beatingTone_time_window{k}(:,l) = timeSignalMatrix{k}(:,l).*win_r_z;
    end
    beatingTone_time_window{k}(2,:)= 0;
    beatingTone_time_window{k}(511,:)= 0;
    beatingTone_time_window{k}(512,:)= 0;
end

%Initialize Matrix Array
Spectrum = cell(1, decimationOfBandwidth);
Spec_abs = cell(1, decimationOfBandwidth);
Spec_abs2 = cell(1, decimationOfBandwidth);
Spec_abs_dB = cell(1, decimationOfBandwidth);

for k=1:decimationOfBandwidth
    Spectrum{k}=fft(beatingTone_time_window{k},Digitizer.long*Sampling.ZP);
    Spec_abs{k} = abs(Spectrum{k});
    theMaxOfMatrix = max(Spec_abs{k});
    theMaxOfMatrix = max(theMaxOfMatrix);
    for l=1:length(Spec_abs{k}(1,:))
        Spec_abs2{k}(:,l) = Spec_abs{k}(:,l)./theMaxOfMatrix;
    end
    Spec_abs_dB{k} = mag2db(Spec_abs2{k});
end

%Make Spectrum in dB and norm to Max=0dB





end