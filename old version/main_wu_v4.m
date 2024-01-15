% MAIN function for RECORDING and READING recorded data as well as further 
% processing for VitalSense by the radar @UPC CommSensLab
% 20/10/2023 Wu Ruochen

clear;
close all;
% ADD path to AlazarTech mfiles for the recording
addpath('C:\AlazarTech\ATS-SDK\7.3.0\Samples_MATLAB\Include')


%-----------------------------------------RECORDING and PROCESSING CONFIGS----------------------------------------------

%--------------------------------------------RECORD or USE EXISTING DATA------------------------------------------------
useExistingFile = true;        % for evaluation of exising recording
%-----------------------------------------------------------------------------------------------------------------------
twoChannelMode = false;         % FALSE = ONLY radar channel, TRUE = 2 channels: CHA=radar channel + CHB=CamSynchLED;
produceCalibrationData = false; % not used anymore: Idea of subtracting static calibration data without testcandidate
doMoreAnalysingSwitch = true;   % more analysis with different algorithm: check Matlab version! STFT in Matlab Introduced in R2019a
    subtractThroughCalibration = false;
    tryCompensationBySubtraction = true;
    reduceBandwidthFunction = false;
HbsigFilterTest = false;        % not used anymore: Test the filter effect for heartbeat signal with different cutoff frequency
%-------------------------------------------------Format-Settings-------------------------------------------------------
openAsVariable = true;          % FALSE open as .bin file, used as only one channel mode; not used anymore
saveAsVariable = true;          % FALSE save as .bin file, used as only one channel mode; not used anymore
%------------------------------------------------Directory-Settings-----------------------------------------------------
% Search in folder for open existing measurement, or
Open_strFolder = 'P:\ruochen.wu\PhD\THzRadar\Radar_Measurement\data\*.mat'; 
% Select folder to save measurement
Save_strFolder = "P:\ruochen.wu\PhD\THzRadar\Radar_Measurement\data\20230623\";
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
            % CHA Radar = beatingTone_time + CHB Button voltage = ButtonSignal
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
        %ButtonSignal=5*data2CH(2:2:end);
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
            save('outputVar.mat','data','beatingTone_time','ButtonSignal')
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
NowrapUncorrected=plotPhasewu(Radar,Digitizer,Sampling,LocFinder,Spectrum,RMS_Amplitude,false,'STANDARD');
UnwrapUncorrected=plotPhasewu(Radar,Digitizer,Sampling,LocFinder,Spectrum,RMS_Amplitude,true,'UNWRAP');

close(f)


%% SIGNAL REPRODUCTION
% Vital signal filtering and extraction of heartbeat & respiration signal
% original radar motion signal extraction
for i=1:length(LocFinder.locs_positive)
    lineWithPeak=find(Sampling.f==LocFinder.locs_positive(i));
    vitsig=1000*(Radar.lambda/(4*pi))*unwrap(angle(Spectrum(lineWithPeak,1:Digitizer.wfrm))-angle(Spectrum(lineWithPeak,1)));
end

% Faithfull reproduction of cardiac & breathing signals
% FIR linear-phase filter
smp_f=200; % sampling
blp_r=fir1(300,0.1/(smp_f/2),'low');
% filtering results
rsig_lp=filtfilt(blp_r,1,vitsig);
hsig_lp=vitsig-rsig_lp;

figure('Name','REPRODUCTION OF BREATHING & CARDIAC SIGNAL');
subplot(2,1,1)
plot(Radar.t_frame,rsig_lp);
hold on
plot(Radar.t_frame,vitsig);
grid on
legend('Respiration signal','Vital signal');
xlabel('Time (s)')
ylabel('Amplitude')
title('Extracted respiration signal')
subplot(2,1,2)
plot(Radar.t_frame,hsig_lp);
grid on
xlabel('Time (s)')
ylabel('Amplitude')
title('Extracted cardiac signal')

figure;
plot(Radar.t_frame,hsig_lp);
hold on
plot(Radar.t_frame,vitsig);
grid on
xlabel('Time (s)')
ylabel('Amplitude')
title('Vital signal & Extracted cardiac signal')


%% CARDIAC SIGNAL PULSE DETECTION
% Adaptive matched filter
% reference signal for filter design
load('AMF.mat');
% Linear interpolation based on MF
long_plus=fil;
% create filter using linear interpolation
interpol_sh=linspace(1,length(long_plus),length(long_plus)*0.6).';
interpol_nom=linspace(1,length(long_plus),length(long_plus)*0.7).';
interpol_lon=linspace(1,length(long_plus),length(long_plus)*0.9).';
short=interp1((1:length(long_plus)).',long_plus,interpol_sh,'linear');
nominal=interp1((1:length(long_plus)).',long_plus,interpol_nom,'linear');
long=interp1((1:length(long_plus)).',long_plus,interpol_lon,'linear');

% adaptive matched filters with diff width
% figure;
% plot(short);
% hold on
% plot(nominal);
% hold on
% plot(long);
% hold on
% plot(long_plus);
% grid on
% legend('shorter','nominal','longer','longer+')

% Application of MF
rf_nom1=conv(hsig_lp,nominal);
rf_sh1=conv(hsig_lp,short);
rf_lon1=conv(hsig_lp,long);
rf_longer1=conv(hsig_lp,long_plus);
% amplitude normalization referring to 2*hsig_lp
rf_nom2=2*(rf_nom1*(max(abs(hsig_lp))/max(abs(rf_nom1))));
rf_sh2=2*(rf_sh1*(max(abs(hsig_lp))/max(abs(rf_sh1))));
rf_lon2=2*(rf_lon1*(max(abs(hsig_lp))/max(abs(rf_lon1))));
rf_longer2=2*(rf_longer1*(max(abs(hsig_lp))/max(abs(rf_longer1))));
% signal shifting to eliminate delay
rf_nom=circshift(rf_nom2,fix(-length(nominal)/2+40));
rf_sh=circshift(rf_sh2,fix(-length(short)/2+30));
rf_lon=circshift(rf_lon2,fix(-length(long)/2+60));
rf_longer=circshift(rf_longer2,fix(-length(long_plus)/2+70));

% Peaks (cardiac pulse) detection
% length of hsig_lp
len_hsig=length(hsig_lp);
% minimum distance between peaks
minpeakdist=150;
[amp_sh,locs_sh]=findpeaks(rf_sh(1:len_hsig),1:len_hsig,'MinPeakDistance',minpeakdist);
[amp_nom,locs_nom]=findpeaks(rf_nom(1:len_hsig),1:len_hsig,'MinPeakDistance',minpeakdist);
[amp_lon,locs_lon]=findpeaks(rf_lon(1:len_hsig),1:len_hsig,'MinPeakDistance',minpeakdist);
[amp_longer,locs_longer]=findpeaks(rf_longer(1:len_hsig),1:len_hsig,'MinPeakDistance',minpeakdist);
% plot figs...
figure;
subplot(4,1,1)
findpeaks(rf_sh(1:len_hsig),1:len_hsig,'MinPeakDistance',minpeakdist);
text(locs_sh+.02,amp_sh,num2str((1:numel(amp_sh))'))
hold on
plot(hsig_lp,'r');
title('shorter')
%legend('Signal pulse with peaks detected','Extracted cardiac signal')
subplot(4,1,2)
findpeaks(rf_nom(1:len_hsig),1:len_hsig,'MinPeakDistance',minpeakdist);
text(locs_nom+.02,amp_nom,num2str((1:numel(amp_nom))'))
hold on
plot(hsig_lp,'r');
title('nominal')
subplot(4,1,3)
findpeaks(rf_lon(1:len_hsig),1:len_hsig,'MinPeakDistance',minpeakdist);
text(locs_lon+.02,amp_lon,num2str((1:numel(amp_lon))'))
hold on
plot(hsig_lp,'r');
title('longer')
subplot(4,1,4)
findpeaks(rf_longer(1:len_hsig),1:len_hsig,'MinPeakDistance',minpeakdist);
text(locs_longer+.02,amp_longer,num2str((1:numel(amp_longer))'))
hold on
plot(hsig_lp,'r');
title('longer+')

% Quality factor setting
% calcu RMS of the signal power
power_rms_nom=sum(abs(rf_nom).^2)/length(rf_nom);
power_rms_sh=sum(abs(rf_sh).^2)/length(rf_sh);
power_rms_lon=sum(abs(rf_lon).^2)/length(rf_lon);
power_rms_longer=sum(abs(rf_longer).^2)/length(rf_longer);
% calcu QF
QF_lon=(sum(amp_lon.^2)/length(locs_lon))/power_rms_lon;
QF_longer=(sum(amp_longer.^2)/length(locs_longer))/power_rms_longer;
QF_nom=(sum(amp_nom.^2)/length(locs_nom))/power_rms_nom;
QF_sh=(sum(amp_sh.^2)/length(locs_sh))/power_rms_sh;
% printing Q-factors...
fprintf('QF of shoter: %.4f\n',QF_sh);
fprintf('QF of nominal: %.4f\n',QF_nom);
fprintf('QF of longer: %.4f\n',QF_lon);
fprintf('QF of longer+: %.4f\n',QF_longer);


