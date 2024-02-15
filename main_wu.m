% MAIN function for RECORDING and READING recorded data as well as further 
% processing for VitalSense by the radar @UPC CommSensLab
% VitalSense 2024 for biometrics and biomedical applications
% 08/11/2023 Wu Ruochen (since 15/03/2023)

clear;
close all;
% ADD path to AlazarTech mfiles for the recording
addpath('C:\AlazarTech\ATS-SDK\7.3.0\Samples_MATLAB\Include')

% % Figure parameter settings
% set(groot,'defaultLineLineWidth',1)
% set(groot,'defaultAxesFontName','Times New Roman')
% set(groot,'defaultAxesFontSize',10)
% set(groot,'defaultAxesLabelFontSizeMultiplier',1)
% set(groot,'defaultFigurePosition',[600 500 400 300])


%-----------------------------------------RECORDING and PROCESSING CONFIGS----------------------------------------------

%--------------------------------------------RECORD or USE EXISTING DATA------------------------------------------------
useExistingFile = true;         % for evaluation of exising recording
%-----------------------------------------------------------------------------------------------------------------------
twoChannelMode = true;         % FALSE = ONLY radar channel, TRUE = 2 channels: CHA=radar channel + CHB=ECG signal;
produceCalibrationData = false; % not used anymore: Idea of subtracting static calibration data without testcandidate
doMoreAnalysingSwitch = true;   % more analysis with different algorithm: check Matlab version! STFT in Matlab Introduced in R2019a
    subtractThroughCalibration = false;
    tryCompensationBySubtraction = true;
    reduceBandwidthFunction = false;
HbsigFilterTest = false;        % not used anymore: Test the filter effect for heartbeat signal with different cutoff frequency
HRVanalysis = false;            % make Poincaré plot to analyze HRV
%-------------------------------------------------Format-Settings-------------------------------------------------------
openAsVariable = true;          % FALSE open as .bin file, used as only one channel mode; not used anymore
saveAsVariable = true;          % FALSE save as .bin file, used as only one channel mode; not used anymore
%------------------------------------------------Directory-Settings-----------------------------------------------------
% Search in folder for open existing measurement, or
Open_strFolder = 'D:\UPC\THzRadar\Radar_Measurement\data\*.mat'; 
% Select folder to save measurement
Save_strFolder = "D:\UPC\THzRadar\Radar_Measurement\data\20240214\";
%-----------------------------------------------------------------------------------------------------------------------
% Search peak in chirp x:
searchInMeasure = 30; % 

%--------------------------------------------------RADAR-Settings-------------------------------------------------------
Radar.f_0=122e9;                                  % Center freq: 122 GHz
Radar.c_0=3e8;                                    % Lightspeed (m/s)
Radar.lambda=Radar.c_0/Radar.f_0;                 % Wavelength (m)
% Measurement
L_samplesDwell=512;                               % Pause samples between chirps
T_frame=3e-3;                                     % T*(L+L_samplesDwell); 3ms ???

% CHIRP
Radar.Tm=0.0015;                                  % Chirp slope time: 1.5ms
Radar.deltaf=3e9;                                 % Chirp slope bandwidth: 3 GHz
%------------------------------------------------Digitizer-Settings-----------------------------------------------------
Digitizer.decimation=4; % ???? GIVING it to the function??? to configureBoard and 
Digitizer.long=round(2048/Digitizer.decimation);  % Length of Chirp in samples defined by DDS settings
Digitizer.wfrm=8000; %2400
% Sampling
Sampling.ZP=32;                                   % Zero-padding
Sampling.Fs=1.3672e+06/Digitizer.decimation;      % Sampling frequency CHANGED for new HW                 
Sampling.T=1/Sampling.Fs;                         % Sampling period (s)
Sampling.L=2048/Digitizer.decimation;             % Length of signal CHANGED was 256
t=(0:Sampling.L-1)*Sampling.T;                    % Time vector (s)


%% OPEN or RECORD Measurement
% .bin files are not used recently anymore. Saved and opened as Matlab
% matrix

if useExistingFile==true % open existing measurement
    if openAsVariable==true
        % open Matlab data as matrix
        [Open_filename,Open_pathname]=uigetfile(Open_strFolder,'Select file');
        fitxer=strcat(Open_pathname,Open_filename); % concatenate strings horizontally
        if twoChannelMode==true
            % CHA Radar = beatingTone_time + CHB EGC = ECGSignal
            load(fitxer,'data','beatingTone_time','ButtonSignal')
            ECGSignal=ButtonSignal;
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
        ECGSignal=5*data2CH(2:2:end);
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


%% PREPROCESSING: CALC FFT
% applying window and FFT with zero padding and make spectrum. Subtracting calibration
% data was not used last, due to no improvement 
f=waitbar(.1,'Calc FFT...');
% Apply Window
win_r_z=window('hann',Digitizer.long); % hanning: smooth the signal and reduce the leakage of the signal in the frequency spectrum
beatingTone_time_window=zeros(Digitizer.long,Digitizer.wfrm);
% increase the resolution of the spectrum
for k=1:Digitizer.wfrm
    beatingTone_time_window(:,k)=beatingTone_time(:,k).*win_r_z;
end

% FFT with ZP
Spectrum=fft(beatingTone_time_window,Digitizer.long*Sampling.ZP);

%------------------------SUBTRACT-CALIBRATION-DATA-------------------------
if (subtractThroughCalibration==true && useExistingFile==true)
    waitbar(.33,f,'Subtract Calibration Data ...');
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
    disp('Subtract through chirp of time:');
    DivideThroughFrame*T_frame;
else
    waitbar(.33,f,'Make Spectrum ...');
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
% to dB: relative strength of the signal
Spec_abs_dB=mag2db(Spec_abs2);


%% SEARCH PEAKS
% Find Maxima in Frequency Diagram
% until now it searches Max in the spectrum of one chirp and maintain this
% Max Sample for whole phase calculation
waitbar(.67,f,'Search Peaks ...');

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
            save('outputVar.mat','data','beatingTone_time','ECGSignal')
        else
            save('outputVar.mat','data','beatingTone_time')
        end
        strFile=append(Save_strFolder,strName,'.mat');
        copyfile("outputVar.mat",strFile);
    else
        % not saved as .bin in last measurements
        copyfile("data.bin",strFile);
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
waitbar(1,f,'Create Figures ...');
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
% range-magni & find peak
plot((Radar.Tm*Radar.c_0.*LocFinder.locs(1,1))/(2*Radar.deltaf),LocFinder.pks,'gd','LineWidth',2);

% Make mean for all chirps
RMS_Amplitude=zeros(Digitizer.wfrm,1);
for k=1:Digitizer.wfrm
    RMS_Amplitude(k)=sqrt(mean(beatingTone_time(:,k).^2));
end

% Unwrap plot
if twoChannelMode==true
    NowrapUncorrected=plotPhase(Radar,Digitizer,Sampling,LocFinder,Spectrum,RMS_Amplitude,false,'STANDARD',ECGSignal);
    UnwrapUncorrected=plotPhase(Radar,Digitizer,Sampling,LocFinder,Spectrum,RMS_Amplitude,true,'UNWRAP',ECGSignal);
else
    NowrapUncorrected=plotPhasewu(Radar,Digitizer,Sampling,LocFinder,Spectrum,RMS_Amplitude,false,'STANDARD');
    UnwrapUncorrected=plotPhasewu(Radar,Digitizer,Sampling,LocFinder,Spectrum,RMS_Amplitude,true,'UNWRAP');
end

close(f)


%% CARDIAC SIGNAL FILTERING
% Vital signal filtering and extraction of heartbeat & respiration signal
% original radar motion signal extraction
for i=1:length(LocFinder.locs_positive)
    lineWithPeak=find(Sampling.f==LocFinder.locs_positive(i));
    vitsig=1000*(Radar.lambda/(4*pi))*unwrap(angle(Spectrum(lineWithPeak,1:Digitizer.wfrm))-angle(Spectrum(lineWithPeak,1)));
end

% Start the timer
tic

% FIR linear-phase filter
smp_f=200; % sampling
blp_r=fir1(300,0.1/(smp_f/2),'low');
% filtering results
rsig_lp=filtfilt(blp_r,1,vitsig);
hsig_lp=vitsig-rsig_lp;

figure('Name','SEPARATION OF BREATHING & CARDIAC SIGNAL');
subplot(2,1,1)
plot(Radar.t_frame,vitsig);
hold on
plot(Radar.t_frame,rsig_lp);
grid on
legend('Vital signal','Respiratory signal');
xlabel('Time (s)')
ylabel('Amplitude (mm)')
title('Extracted respiratory signal')
subplot(2,1,2)
plot(Radar.t_frame,hsig_lp);
grid on
xlabel('Time (s)')
ylabel('Amplitude (mm)')
title('Extracted cardiac signal')

% ECG signal & extracted cardiac signal
if twoChannelMode==true
    decimatedECGSignal=ECGSignal(1:Digitizer.long:end);
    voltageRangeChannelB=10;

    figure('Name','ECG SIGNAL & CARDIAC SIGNAL');
    yyaxis left
    plot(Radar.t_frame,hsig_lp);
    ylabel('Amplitude (mm)')
    yyaxis right
    plot(Radar.t_frame,(double(decimatedECGSignal-2^15)/2^16)*voltageRangeChannelB,'g');
    grid on
    xlabel('Time (s)')
    ylabel('ECG')
end


%% FASE A: ITERATIVE PULSE PERIOD ESTIMATION
sig=hsig_lp;
% filter parameters setting
T.fil0=500; % T for fil0
% test various filters
filter_simple=1; % 1=sine; 2=triangle; 3=rectangular
% create Filter 0 
if filter_simple==1
    % sin wave
    fil0=max(sig)*sin(linspace(0,pi,T.fil0))+min(sig);
elseif filter_simple==2
    % triangle wave
    fil0=min(sig)+(sawtooth(2*pi*linspace(0,1,T.fil0),0.5)+1)*(max(sig)-min(sig))/2;
elseif filter_simple==3
    % rectangular wave
    fil0=zeros(1,100+T.fil0);
    rectg=max(sig)*square(linspace(0,1,T.fil0));
    fil0(51:50+length(rectg))=rectg;
end
% figure;
% plot(fil0);

% 1st filtering with fil0
sig1_0=conv(sig,fil0);
sig1_0=2*(sig1_0*(max(abs(sig))/max(abs(sig1_0))));
% signal shifting to eliminate delay
sig1=circshift(sig1_0,fix(-length(fil0)/2));
% peaks detection
len_sig=length(sig); % length of sig
minpeakdist=150; % minimum distance between peaks
minprom=0.01; % minimum prominence between peaks
%minpeakpro=0.015; % minimum prominence of the peak
% peaks...
[amp_sig1,locs_sig1]=findpeaks(sig1(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist,'MinPeakProminence',minprom);
% figure('Name','SIGNAL AFTER APPLYING FILTER 0');
% findpeaks(sig1(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist,'MinPeakProminence',minprom);
% text(locs_sig1+.02,amp_sig1,num2str((1:numel(amp_sig1))'))
% hold on
% plot(sig,'r');
% calcu T1 based on the peaks detected
T1=diff(locs_sig1);
T1_mean=mean(T1); % T1_average
T1_save=[]; % save the values of T1

% 2st filtering with fil1
% Filter 1: sin wave with the longitude of T1_average
T.fil1=round(T1_mean);
if filter_simple==1
    fil1=max(sig)*sin(linspace(0,pi,T.fil1))+min(sig);
elseif filter_simple==2
    fil1=min(sig)+(sawtooth(2*pi*linspace(0,1,T.fil1),0.5)+1)*(max(sig)-min(sig))/2;
elseif filter_simple==3
    fil1=zeros(1,100+T.fil1);
    rectg=max(sig)*square(linspace(0,1,T.fil1));
    fil1(51:50+length(rectg))=rectg;
end
% application of fil1
sig2_0=conv(sig,fil1);
sig2_0=2*(sig2_0*(max(abs(sig))/max(abs(sig2_0))));
% signal shifting to eliminate delay
sig2=circshift(sig2_0,fix(-length(fil1)/2));
% peaks...
[amp_sig2,locs_sig2]=findpeaks(sig2(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist,'MinPeakProminence',minprom);
% figure('Name','SIGNAL AFTER APPLYING FILTER 1');
% findpeaks(sig2(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist,'MinPeakProminence',minprom);
% text(locs_sig2+.02,amp_sig2,num2str((1:numel(amp_sig2))'))
% hold on
% plot(sig,'r');
% calcu T2 based on the peaks detected
T2=diff(locs_sig2);
T2_mean=mean(T2); % T2_average
T2_save=[]; % save the values of T2

T3_save=[]; % save the values of T3
i=0;
while abs(T2_mean-T1_mean)>5
    i=i+1;
    % 3st filtering with fil2
    % Filter 2: sin wave with the longitude of T1_average
    T.fil2=round(T2_mean);
    if filter_simple==1
        fil2=max(sig)*sin(linspace(0,pi,T.fil2))+min(sig);
    elseif filter_simple==2
        fil2=min(sig)+(sawtooth(2*pi*linspace(0,1,T.fil2),0.5)+1)*(max(sig)-min(sig))/2;
    elseif filter_simple==3
        fil2=zeros(1,100+T.fil2);
        rectg=max(sig)*square(linspace(0,1,T.fil2));
        fil2(51:50+length(rectg))=rectg;
    end
    % application of fil2
    sig3_0=conv(sig,fil2);
    sig3=circshift(sig3_0,fix(-length(fil2)/2));
    [amp_sig3,locs_sig3]=findpeaks(sig3(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist,'MinPeakProminence',minprom);
    T3_mean=mean(diff(locs_sig3)); % T3_average
    T3_save=[T3_save,T3_mean]; % save the value
    T1_save=[T1_save,T1_mean];
    T2_save=[T2_save,T2_mean];

    % limit the number of iterations
    if i==10
        break
    end

    % variable assignment
    T1_mean=T2_mean;
    T2_mean=T3_mean;
end

% final vaule of T
if isempty(T2_save)
    T.fil2=T2_mean;
else
    T.fil2=mean(T2_save);
end

%% FASE B: PULSE WAVEFORM RECONSTRUCTION FOR AMF
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

% calcu mean of the pulses
fil_sum=zeros(1,length(pulse(1).sig));
for i=1:numel(pulse)
    fil_sum=fil_sum+pulse(i).sig; % sum of the pulses
end
filB=fil_sum/numel(pulse); % filter of average
figure('Name','WAVEFORM DESIGN');
plot(filB);
title('Average waveform filter');


%% FASE C: VITAL INFORMATION EXTRACTION
% Cadiac pulse identification
% adaptive matched filter design
filC=fliplr(filB); % filC(t)=filB(-t)
% application of AMF
hsig1=conv(sig,filC);
% amplitude normalization referring to 2*hsig_lp
hsig2=2*(hsig1*(max(abs(sig))/max(abs(hsig1))));
% signal shifting to eliminate delay
hsig=circshift(hsig2,fix(-length(filC)/2));
% peaks (cardiac pulse) detection
minpeakdist_d=length(filC)-50;
[amp_hsig,locs_hsig]=findpeaks(hsig(1:len_sig),Radar.t_frame,'MinPeakDistance',minpeakdist_d*T_frame,'MinPeakProminence',0.02);

% plot fig...
if twoChannelMode==true
    figure('Name','CARDIAC PULSE IDENTIFICATION');
    subplot(length(LocFinder.locs_positive)*2+1,1,1:2)
    plot(Radar.t_frame,hsig(1:len_sig),locs_hsig,amp_hsig,'rv','LineWidth',1.3);
    text(locs_hsig+.1,amp_hsig,num2str((1:numel(amp_hsig))'))
    hold on
    plot(Radar.t_frame,sig,'-','Color','#D95319','LineWidth',1.5);
    %xlabel('Time (s)')
    grid on
    ylabel('Cardiac Amplitude (mm)')
    legend('Heartbeat detection','Identified pulse','Cardiac signal');
    
    % peaks detection based on ECG signal
    [amp_ecg,locs_ecg]=findpeaks((double(decimatedECGSignal-2^15)/2^16)*voltageRangeChannelB,Radar.t_frame,'MinPeakDistance',minpeakdist_d*T_frame,'MinPeakProminence',3e-05);
    % plot ECG signal...
    subplot(length(LocFinder.locs_positive)*2+1,1,length(LocFinder.locs_positive)*2+1);
    plot(Radar.t_frame,(double(decimatedECGSignal-2^15)/2^16)*voltageRangeChannelB,'g',locs_ecg,amp_ecg,'rv','LineWidth',1.3);
    text(locs_ecg+.1,amp_ecg,num2str((1:numel(amp_ecg))'))
    grid on
    xlabel('Time (s)')
    ylabel('ECG')
else
    figure('Name','CARDIAC PULSE IDENTIFICATION');
    %yyaxis left
    plot(Radar.t_frame,hsig(1:len_sig),locs_hsig,amp_hsig,'rv','LineWidth',1.3)
    text(locs_hsig+.1,amp_hsig,num2str((1:numel(amp_hsig))'))
    hold on
    plot(Radar.t_frame,sig,'-','Color','#D95319','LineWidth',1.5);
    xlabel('Time (s)')
    ylabel('Cardiac Amplitude (mm)')
    legend('Heartbeat detection','Identified pulse','Cardiac signal');
    
    % yyaxis right
    % plot(Radar.t_frame,rsig_lp,'-','Color','#EDB120','LineWidth',1.2);
    % hold on
    % plot(Radar.t_frame,vitsig,':','Color','#C82423','LineWidth',1.5);
    % grid on
    % ylabel('Breathing Amplitude (mm)')
    % lege=legend('Heartbeat detection','Identified pulse','Cardiac signal','Respiratory signal','Vital signal','NumColumns',2);
    % set(lege,'box','off')
end

% calcu heart rate of the subject
bpm=round(length(locs_hsig)/(length(sig)*T_frame/60));
% printing...
fprintf('The detected heart rate of the subject is: %d bpm. (by detected peaks)\n',bpm);

% Reproduction of blood pressure waveform
% find the locs...
[amph,locsh]=findpeaks(hsig(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist_d,'MinPeakProminence',0.02);
% extract the first and second half of a cardiac period
pulseC=round(locsh-mean(diff(locsh))/2);
pulseD=round(locsh+mean(diff(locsh))/2);
% make sure the matrix aize does not exceed the original signal size
if pulseC(1)<=0
    pulseC(1)=1; % the signal should start at 1
end
% extract all pulses
if pulseD(end)>length(sig)
    pulseD(end)=length(sig);
end
% eliminate the 1st & last data
for i=1:length(pulseC)
    bp(i).sig=sig(pulseC(i):pulseD(i));
end
bp(1).sig=0;
bp(end).sig=0;
% calcu mean of the pulses
bp_sum=zeros(1,length(bp(1).sig));
for i=1:numel(bp)
    bp_sum=bp_sum+bp(i).sig; % sum of the pulses
end
BP=bp_sum/numel(bp); % BP waveform
figure('Name','BLOOD PRESSURE WAVEFORM');
plot((1:length(BP))*T_frame,BP,'Color','#D95319','LineWidth',1.5);
%set(gca,'Box','off');
xlabel('Time (s)')
ylabel('Amplidute (mm)')
grid on
% set(gca,'xtick',[],'xticklabel',[]);
% set(gca,'ytick',[],'yticklabel',[]);

% calcu bpm based on T of peaks 
bpm_T=round(1/(length(BP)*T_frame)*60);
fprintf('The detected heart rate of the subject is: %d bpm. (by cardiac period)\n',bpm_T);

% End the timer
toc


%% HRV ANALYSIS
if HRVanalysis==true
    % Poincare plot based on R-R intervals
    % calcu RR based on the peaks detected
    RR0=diff(locs_hsig);
    RR=RR0*1000; % s->ms
    % calcu x & y axes
    PlotX=RR(1:end-1); % RR interval of current peak
    PlotY=RR(2:end); % RR interval of next peak
    
    % SDNN
    sdnn=std(RR,0);
    % SDSD
    sdsd=std(diff(RR));
    % SD1 & SD2
    sd1=sqrt(0.5)*sdnn;
    sd2=sqrt(2*sdnn^2-0.5*sdsd^2);
    % dynamic balance indicator
    RatioHRV=sd1/sd2;
    
    % plot...
    figure('Name','POINCARÉ PLOT');
    line([min(PlotX),max(PlotY)],[min(PlotX),max(PlotY)],'Color','#808080','Linestyle','--');
    hold on
    scatter(PlotX,PlotY,60,[0 0.4470 0.7410],'+','LineWidth',1.5);
    xlabel('RR_n (ms)');
    ylabel('RR_{n+1} (ms)');
    grid on
end


