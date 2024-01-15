% MAIN function for RECORDING and READING recorded data as well as further 
% processing for Eyelid Motion by the radar @UPC ETSETB
% 11/22/2022 Patscheider Dominik
% 15/03/2023 Wu Ruochen

clear all;
close all;
% ADD path to AlazarTech mfiles for the recording
addpath('C:\AlazarTech\ATS-SDK\7.3.0\Samples_MATLAB\Include')


%-----------------------------------------RECORDING and PROCESSING CONFIGS----------------------------------------------

%--------------------------------------------RECORD or USE EXISTING DATA------------------------------------------------
useExistingFile = true; % for evaluation of exising recording
%-----------------------------------------------------------------------------------------------------------------------
twoChannelMode = false;          % FALSE = ONLY radar channel, TRUE = 2 channels: CHA=radar channel + CHB=CamSynchLED;
produceCalibrationData = false; % not used anymore: Idea of subtracting static calibration data without testcandidate
doMoreAnalysingSwitch = true;   % more analysis with different algorithm: check Matlab version! STFT in Matlab Introduced in R2019a
    subtractThroughCalibration = false;
    tryCompensationBySubtraction = true;
    reduceBandwidthFunction = false;
%-------------------------------------------------Format-Settings-------------------------------------------------------
openAsVariable = true;          % FALSE open as .bin file, used as only one channel mode; not used anymore
saveAsVariable = true;          % FALSE save as .bin file, used as only one channel mode; not used anymore
%------------------------------------------------Directory-Settings-----------------------------------------------------
% Search in folder for open existing measurement, or
Open_strFolder = 'P:\ruochen.wu\PhD\THzRadar\Radar_Measurement\data\*.mat'; 
% Select folder to save measurement
Save_strFolder = "P:\ruochen.wu\PhD\THzRadar\Radar_Measurement\data\";
%-----------------------------------------------------------------------------------------------------------------------
% Search peak in chirp x:
searchInMeasure = 30; % 

%--------------------------------------------------RADAR-Settings-------------------------------------------------------
Radar.f_0=122e9;                                  % Center freq
Radar.c_0=3e8;                                    % Lightspeed
Radar.lambda=Radar.c_0/Radar.f_0;                 % Wavelength
% Measurement
L_samplesDwell=512;                               % Pause samples between chirps
T_frame=3e-3;                                     % T*(L+L_samplesDwell); 3ms ???

% CHIRP
Radar.Tm=0.0015;                                  % Chirp Slope Time
Radar.deltaf=3e9;                                 % Chirp Slope Bandwidth
%------------------------------------------------Digitizer-Settings-----------------------------------------------------
Digitizer.decimation=4; % ???? GIVING it to the function??? to configureBoard and 
Digitizer.long=round(2048/Digitizer.decimation);  %Length of Chirp in samples defined by DDS settings
Digitizer.wfrm=8000; %2400
% Sampling
Sampling.ZP=32;                                   % Zero-padding
Sampling.Fs=1.3672e+06/Digitizer.decimation;      % Sampling frequency CHANGED for new HW                 
Sampling.T=1/Sampling.Fs;                         % Sampling period       
Sampling.L=2048/Digitizer.decimation;             % Length of signal CHANGED was 256
t=(0:Sampling.L-1)*Sampling.T;                    % Time vector




%% OPEN or RECORD Measurement
% .bin files are not used recently anymore. Saved and opened as Matlab
% matrix

if useExistingFile==true % open existing measurement
    if openAsVariable==true
        % open Matlab data as matrix
        [Open_filename,Open_pathname]=uigetfile(Open_strFolder,'Select file');
        fitxer=strcat(Open_pathname,Open_filename); %concatenate strings horizontally
        if twoChannelMode==true
            % CHA Radar=beatingTone_time + CHB Button voltage=ButtonSignal
            load(fitxer,'data','beatingTone_time','ButtonSignal')
        else
            % only radar signal beatingTone_time
            load(fitxer,'data','beatingTone_time')
        end
        
    else
        % use for .bin files, in latest measurements not used anymore
        [filename,pathname]=uigetfile('C:\AlazarTech\ATS-SDK\7.3.0\Samples_MATLAB\ATS9120\DualPort\NPT\Dominik\Recordings\20220712\*.bin','Select Fast GBSAR file'); 
        fitxer=strcat(pathname,filename); % concatenate strings horizontally
        ff=fopen(fitxer,'rb');
        data=fread(ff,Digitizer.long*Digitizer.wfrm,'uint16');
    end
else
    % Make Measurements with AlazarTech
    % Call mfile with library definitions
    AlazarDefs
    
    % Load driver library
    if ~alazarLoadLibrary()
      fprintf('Error: ATSApi library not loaded\n');
      return
    end
    
    % TODO: Select a board
    systemId=int32(1);
    boardId=int32(1);
    
    % Get a handle to the board
    boardHandle=AlazarGetBoardBySystemID(systemId,boardId);
    setdatatype(boardHandle,'voidPtr',1,1);
    if boardHandle.Value==0
      fprintf('Error: Unable to open board system ID %u board ID %u\n',systemId,boardId);
      return
    end
    % START CONFIG BOARD & RECORD
    if twoChannelMode==true
        % TWO CHANNEL MODE
        [result]=configureBoard2Ch(boardHandle,Digitizer.decimation,Digitizer.wfrm); 
        [result,data2CH]=acquireData2Ch(boardHandle,Digitizer.decimation,Digitizer.wfrm);
        data=400e-3*data2CH(1:2:end);
        ButtonSignal=5*data2CH(2:2:end);
        clear data2CH;
    else
        % ONE CHANNEL MODE
        [result]=configureBoard1Ch(boardHandle,Digitizer.decimation,Digitizer.wfrm);
        [result,data]=acquireData1Ch(boardHandle,Digitizer.decimation,Digitizer.wfrm);
    end

end

beatingTone_time=reshape(data,Digitizer.long,Digitizer.wfrm); 
Digitizer.wfrm=size(beatingTone_time,2);
%%% WARNING (data-2^15)/2^16 in AquireData forgot!!!!!!!!!!!!!!!!
%%% therefore the magnitude does not match

Radar.t_frame=(0:Digitizer.wfrm-1)*T_frame; % make time array for whole acquisition


%% CALC FFT
% applying window and FFT with zero padding and make spectrum. Subtracting calibration
% data was not used last, due to no improvement 
f=waitbar(0,'Calc FFT...');

% Apply Window
win_r_z=window('hann',Digitizer.long);
beatingTone_time_window=zeros(Digitizer.long,Digitizer.wfrm);
for k=1:Digitizer.wfrm
    beatingTone_time_window(:,k)=beatingTone_time(:,k).*win_r_z;
end

% FFT with ZP
Spectrum=fft(beatingTone_time_window,Digitizer.long*Sampling.ZP);


%------------------------SUBTRACT-CALIBRATION-DATA-------------------------
if (subtractThroughCalibration==true && useExistingFile==true)
    waitbar(.1,f,'Subtract Calibration Data ...');
    [filename,pathname]=uigetfile('C:\AlazarTech\ATS-SDK\7.3.0\Samples_MATLAB\ATS9120\DualPort\NPT\Dominik\Recordings\20220712\CalibrationData\*.mat','Select file'); 
    fitxer=strcat(pathname,filename); % concatenate strings horizontally
    load(fitxer,'CALIBRATION_DATA_FREQ')
    DivideThroughFrame=5;
    Spectrum=zeros(Digitizer.long*Sampling.ZP,Digitizer.wfrm);
%     Divider=CALIBRATION_DATA_FREQ;
%     for k=1:wfrm
%         fdb(:,k)=fda/Divider;
%     end
%     fdb=fda./Divider;
    Spectrum=Spectrum-CALIBRATION_DATA_FREQ;
    display('Subtract through chirp of time:');
    DivideThroughFrame*T_frame
else
    waitbar(.2,f,'Make Spectrum ...');
end
%-------------------------------------------------------------------

% Make spectrum
Sampling.f=Sampling.Fs*(1:(Sampling.L*Sampling.ZP))/(Sampling.L*Sampling.ZP);
Spec_abs=abs(Spectrum);
% Convert to magnitude
theMaxOfMatrix=max(Spec_abs);
theMaxOfMatrix=max(theMaxOfMatrix);
for k=1:length(Spec_abs(1,:))
    Spec_abs2(:,k)=Spec_abs(:,k)./theMaxOfMatrix;
end
Spec_abs_dB=mag2db(Spec_abs2);

%% SEARCH PEAKS
% Find Maxima in Frequency Diagram
% until now it searches Max in the spectrum of one chirp and maintain this
% Max Sample for whole phase calculation
waitbar(.25,f,'Search Peaks ...');

[LocFinder.pks,LocFinder.locs]=findpeaks(Spec_abs_dB(:,searchInMeasure),Sampling.f,'SortStr','descend','MinPeakDistance',5,'MinPeakHeight',-35,'NPeaks',2);
LocFinder.locs_positive=LocFinder.locs(LocFinder.locs>0 & LocFinder.locs<=5e4);
text(LocFinder.locs+.02,LocFinder.pks,num2str((1:numel(LocFinder.pks))'))

%% SAVE TO FILE
% save Calibration Data or Measurement. Files were saved as Matlab File
% .mat or in past as .bin file.

if (useExistingFile==false && produceCalibrationData==false)
    % New acquisitions and not a recording of a calibration data.  
    
    strName=input('Name of Recording: ','s');
    strFile=append(Save_strFolder,strName,'.bin');
    if saveAsVariable==true
        if twoChannelMode==true
            save('outputVar.mat','data','beatingTone_time','ButtonSignal')
        else
            save('outputVar.mat','data','beatingTone_time')
        end
        
        strFile=append(Save_strFolder,strName,'.mat');
        copyfile("outputVar.mat", strFile);
    else
        % not saved as .bin in last measurements
        copyfile("data.bin", strFile);
    end
elseif (useExistingFile==false && produceCalibrationData==true)
    % CALIBRATION_DATA_FREQ: saves the matrix of n chirps with m samples of the
    % spectrum as a calibration matrix for a later subtraction of measurements
    Save_strFolder="Recordings\20220712\CalibrationData\";
    strName="CalibrationData";
    CALIBRATION_DATA_FREQ=fda;
    save('CalibrationData.mat','CALIBRATION_DATA_FREQ')
    strFile=append(Save_strFolder,strName,'.mat');
    copyfile("CalibrationData.mat",strFile);
end



%% PRINT FIGURES
% Prints every 10th chirp of the acquisiton in time domain or frequency
% domain as a spectrum depending on the range
close all;
waitbar(.3,f,'Create Figures ...');

freqPlots=figure('Name','Time and Frequency Domain','NumberTitle','off');

subplot(2,1,1); % for beating tones in time domain
plot(t,beatingTone_time(:,1:size(beatingTone_time,2)/10:size(beatingTone_time,2)));
title('Time Domain of Chirps');
xlabel('Time (s)')
ylabel('Amplitude')
grid on

distanceOfObject=(Radar.Tm * Radar.c_0 .*Sampling.f)/(2*Radar.deltaf);

subplot(2,1,2); % spectrum depending on range
distanceOfObjectShift=distanceOfObject-(max(distanceOfObject)/2);
plot(distanceOfObjectShift,fftshift(Spec_abs_dB(:,1:size(Spec_abs_dB,2)/10:size(Spec_abs_dB,2))));
title('Spectrum');
xlabel('Range (m)')
ylabel('Magnitude (dB)')
xlim([0 1.5])
ylim([-25 2])
grid on
hold on
plot((Radar.Tm * Radar.c_0 .*LocFinder.locs)/(2*Radar.deltaf),LocFinder.pks,'gd','LineWidth',2);


% Make mean for all chirps
RMS_Amplitude=zeros(Digitizer.wfrm,1);
for k=1:Digitizer.wfrm
    RMS_Amplitude(k)=sqrt(mean(beatingTone_time(:,k).^2));
end


% Produce Unwrap Plot
UnwrapUncorrected=plotPhase(Radar,Digitizer,Sampling,LocFinder,Spectrum,RMS_Amplitude,true,'UNWRAP',ButtonSignal);
NowrapUncorrected=plotPhase(Radar,Digitizer,Sampling,LocFinder,Spectrum,RMS_Amplitude,false,'STANDARD',ButtonSignal);


%% FURTHER Signal Processing with different algorithm
% includes: subtracting mean, MTI algorithm, EMD, STFT
if doMoreAnalysingSwitch==true
    %----------------------------------TRY-EMD-----------------------------------------------
    waitbar(.4,f,'Apply EMD ...');
    lineWithPeak=find(Sampling.f==LocFinder.locs_positive(1)); %TAKE RIGHT NOW PEAK 1
    angleArrayUnwrap=1000 * ((Radar.lambda/(4*pi)) * unwrap(angle(Spectrum(lineWithPeak,1:Digitizer.wfrm))) - angle(Spectrum(lineWithPeak,1)) * Radar.lambda/(4*pi));
    [imf,residual]=emd(angleArrayUnwrap,'Interpolation','pchip','Display',1,'MaxNumIMF',9);
    emdPlot=figure('Name','EMD Plot');
    for k=1:length(imf(1,:))
        subplot(9,1,k)
        plot(Radar.t_frame,imf(:,k))
        ylabel(['IMF ',num2str(k)])
        grid on;
    end
    % Make Plot of 8 IMFs and one Residual
    subplot(9,1,9)
    plot(Radar.t_frame,residual(:,1))
    hold on;
    [TF,S1,S2]=ischange(imf(:,1),'linear','Threshold',0.01);
    plot(Radar.t_frame,TF);
    hold off
    ylabel('Residual');
    xlabel('Time (s)');
    
    
    %% EVALUATE SAMPLES AROUND PEAK
    % Select space between peaks for evaluation for detecting another peak
    % close to the original. Thus, the result of the peak sample depend
    % also on the chirp which is used for searching a peak
    waitbar(.45,f,'Evaluate samples around Peak ...');

    evaluationOffset=64;      % Space in samples betweeen each other (consider ZP!)
    evaluationPoints=9;        % Number of evaluated samples in surrounding incl. the origin in the middle of first peak
    lineWithPeak=find(Sampling.f==LocFinder.locs_positive(1)); % it takes the original highes peak to observe surrounding
    
    evaluationNextToPeak=figure('Name','Evaluate Surrounding Next To Peak');
    for k=1:evaluationPoints
        subplot(9,1,k)
        SmpNextToPeak=lineWithPeak + evaluationOffset*(k-round(evaluationPoints/2)); 
        angleArrayUnwrap=1000*((Radar.lambda/(4*pi))*unwrap(angle(Spectrum(SmpNextToPeak,1:Digitizer.wfrm)))-angle(Spectrum(SmpNextToPeak,1))*Radar.lambda/(4*pi));
        plot(Radar.t_frame,angleArrayUnwrap);
        ylabel('Dist (mm)')
        title(['Cell Nmbr:',num2str(SmpNextToPeak)]);
        yyaxis right
        plot(Radar.t_frame,mag2db(Spec_abs(SmpNextToPeak,1:Digitizer.wfrm)/max(Spec_abs(SmpNextToPeak,1:Digitizer.wfrm))));
        ylabel('Mag (dB)')
        grid on;
    end
    
    
%% Subtract Mean Value
% Mean value over whole acquisition is build to subtract
    if(tryCompensationBySubtraction==true)
        % it contains right now only subtract by mean value
        waitbar(.5,f,'Subtract Mean Value ...');
        estimationMatrix=mean(Spectrum,2);
        fdbCORRECTED=zeros(Sampling.ZP*Sampling.L,Digitizer.wfrm);
        for k=1:size(Spectrum,2)
            fdbCORRECTED(:,k)=Spectrum(:,k)-1*estimationMatrix;
        end
        
        Spec_shiftCORRECTED=((fdbCORRECTED));
        Spec_absCORRECTED=abs(Spec_shiftCORRECTED);
        theMaxOfMatrixCORRECTED=max(Spec_absCORRECTED);
        theMaxOfMatrixCORRECTED=max(theMaxOfMatrixCORRECTED);
        for k=1:length(Spec_absCORRECTED(1,:))
            Spec_abs2CORRECTED(:,k)=Spec_absCORRECTED(:,k)./theMaxOfMatrixCORRECTED;
        end
        Spec_abs_dBCORRECTED=mag2db(Spec_abs2CORRECTED);
        % Plot the subtracted Phase
        phaseWithUnwrapCORRECTED=plotPhase(Radar,Digitizer,Sampling,LocFinder,Spec_shiftCORRECTED,RMS_Amplitude,true,'SUBTRACTED MEAN VALUE',ButtonSignal);
        
        %-------
        waitbar(.6,f,'Make more Plots ...');
        %---------
        figure;
        timesignal=reshape(beatingTone_time_window,[1 4096000]);
        subplot(3,1,1);
        stft(imf(:,1),Sampling.Fs,'FFTLength',128*4,'Window',hamming(16)) % hamming64
        title('STFT of IMF 1')
        %xlim([21 23])
        subplot(3,1,2);
        plot(Radar.t_frame,(imf(:,1)+imf(:,2)+imf(:,3)+imf(:,4))); 
        xlabel('Time (s)')
        ylabel('IMF sum of 1,2,3')
        %xlim([22 24])
        subplot(3,1,3);
        stft(RMS_Amplitude,Sampling.Fs,'FFTLength',64,'Window',hamming(8))
        %xlim([21 23])
        title('STFT of RMS Amplitude')
        
        [imf2,residual2]=emd(RMS_Amplitude,'Interpolation','pchip','Display',1,'MaxNumIMF',9);
        emdPlot2=figure('Name','EMD Plot Amplitude');
        for k=1:length(imf2(1,:))
            subplot(9,1,k)
            plot(Radar.t_frame,imf2(:,k))
            ylabel(['IMF ',num2str(k)])
            ylabel('IMF x')
            xlabel('Time (s)')
            grid on;
        end
        
        imfsum2=imf2(:,1)+imf2(:,2)+imf2(:,3);
        figure;
        plot(Radar.t_frame,imfsum2)
        xlabel('Time (s)')
        ylabel('Amplitude IMFs sum of 1,2,3')
        set(phaseWithUnwrapCORRECTED,'Position',[580, 30, 580, 800])
    end
    

    
    % divide bandwidth in n similiar parts
    if(reduceBandwidthFunction==true)
        waitbar(.7,f,'Set down Bandwidth ...');
        decimationOfBandwidth=3; % will split into x parts
        divBeatingTone_time=setDownBandwidthOfChirp(beatingTone_time,decimationOfBandwidth);
        waitbar(.8,f,'Make new FFT for sperated Bandwidth ...');
        [SpectrumDivided,Spec_abs_dBDivided]=doFFT(divBeatingTone_time,Sampling,Digitizer,decimationOfBandwidth);
        waitbar(.9,f,'Search Peaks and produce Plots ...');
        [LocationsDivided,checkValue]=searchPeaks(Spec_abs_dBDivided,Sampling,decimationOfBandwidth);
        result=makeFreqPlots(Spec_abs_dBDivided,LocationsDivided,Sampling,Radar,decimationOfBandwidth);
        % Produce Unwrap Plot
        UnwrapUncorrected1=plotPhase(Radar,Digitizer,Sampling,LocationsDivided{1},SpectrumDivided{1},RMS_Amplitude,true,'UNWRAP_DECBW1',ButtonSignal);
        UnwrapUncorrected2=plotPhase(Radar,Digitizer,Sampling,LocationsDivided{2},SpectrumDivided{2},RMS_Amplitude,true,'UNWRAP_DECBW2',ButtonSignal);
        UnwrapUncorrected3=plotPhase(Radar,Digitizer,Sampling,LocationsDivided{3},SpectrumDivided{3},RMS_Amplitude,true,'UNWRAP_DECBW3',ButtonSignal);
        %NoUnwrapUncorrected=plotPhase(Radar,Digitizer,Sampling,LocationsDivided{1},SpectrumDivided{1},RMS_Amplitude,false,'STANDARD');
    end
end
delete(f);
% close(f);
%----------Sort on Screen-----------
%set(freqPlots,'Position', [580, 30, 750, 450])
%set(UnwrapUncorrected,'Position', [0, 30, 580, 800])
%set(phaseNoUnwrap,'Position', [580, 530, 1050, 450])