% MAIN function for RECORDING and READING recorded data as well as further 
% processing for VitalSense by the radar @UPC CommSensLab
% 06/07/2023 Wu Ruochen

clear all;
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
HbsigFilterTest = false;        % TRUE = Compare the filter effect of heartbeat signal with different cutoff frequency
SigReproduction = true;        % TRUE = Faithfull reproduction of cardiac & breathing signals with FIR linear phase filter
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
    display('Subtract through chirp of time:');
    DivideThroughFrame*T_frame
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


%% SIGNAL FILTERING
% Vital signal filtering and extraction of heartbeat & respiration signal
for i=1:length(LocFinder.locs_positive)
    lineWithPeak=find(Sampling.f==LocFinder.locs_positive(i));
    vitsig=1000*(Radar.lambda/(4*pi))*unwrap(angle(Spectrum(lineWithPeak,1:Digitizer.wfrm))-angle(Spectrum(lineWithPeak,1)));
end

cutoff_hf=4; % cutoff of heartbeat
cutoff_rf=0.7; % cutoff of respiration
smp_f=200; % sampling
ord_iir=5; % order of IIR filter
ord_fir=80; % order of FIR filter

if HbsigFilterTest==true
    % Test the heartbeat signal at different cutoff frequencies
    % test simple filters with simulated signal
    a0=zeros(500);
    a0(250)=1; % bulid the simulated signal
    % simple filter of [15*1,15*-1]
    b_1(1:15)=1;
    b_1(16:30)=-1;
    % simple filter of [15*1,15*-2,15*1]
    b_2(1:15)=1;
    b_2(16:30)=-2;
    b_2(31:45)=1;
    
    % test simple filters with detected signal
    hsig1=filtfilt([1,-1],1,vitsig);
    hsig2=filtfilt(b_1,1,vitsig);
    hsig3=filtfilt(b_2,1,vitsig);
    % IIR filter design
    [b11,a11]=butter(ord_iir,1/(smp_f/2),'high');
    [b22,a22]=butter(ord_iir,2/(smp_f/2),'high');
    [b33,a33]=butter(ord_iir,4/(smp_f/2),'high');
    [b44,a44]=butter(ord_iir,8/(smp_f/2),'high');
    % FIR filter disign
    b55=fir1(ord_fir,1/(smp_f/2),'high');
    b66=fir1(ord_fir,2/(smp_f/2),'high');
    b77=fir1(ord_fir,4/(smp_f/2),'high');
    b88=fir1(ord_fir,8/(smp_f/2),'high');
    % filter the signal...
    hsig_iir1=filtfilt(b11,a11,vitsig);
    hsig_iir2=filtfilt(b22,a22,vitsig);
    hsig_iir3=filtfilt(b33,a33,vitsig);
    hsig_iir4=filtfilt(b44,a44,vitsig);
    hsig_fir1=filtfilt(b55,1,vitsig);
    hsig_fir2=filtfilt(b66,1,vitsig);
    hsig_fir3=filtfilt(b77,1,vitsig);
    hsig_fir4=filtfilt(b88,1,vitsig);
    % matched filter
    h=[0.2;0.5;1;0;-1;-0.5;-0.2]; % simple filter
    h2=[-0.11;-0.57;-0.92;-0.53;1.27;1.72;1.27;-0.53;-0.92;-0.57;-0.11]; % filter T
    h3=[-0.92;-0.45;-0.11;-0.57;-0.92;-0.53;1.27;1.72;1.27;-0.53;-0.92;-0.57;-0.11;-0.45;-0.92]; % filter W
    load('hd_resmp.mat'); %filter D
    rf=conv(vitsig,h);
    snf2=conv(rf,h);
    %snf3=conv(snf2,h3);
    snfd=conv(snf2,hd_resmp);
    
    % Print figs
    % figure('Name','A=ZEROS(500)'); % filtered unit-impulse signal for a0 
    % subplot(2,2,1)
    % plot(filtfilt(b44,a44,a0));
    % title('IIR 5th-order, 8 Hz')
    % subplot(2,2,2)
    % plot(filtfilt(b88,1,a0));
    % title('FIR 80th-order, 8 Hz')
    % subplot(2,3,4)
    % plot(filtfilt([1,-1],1,a0));
    % title('[1,-1]')
    % subplot(2,3,5)
    % plot(filtfilt(b_1,1,a0));
    % title('[15*1,15*-1]')
    % subplot(2,3,6)
    % plot(filtfilt(b_2,1,a0));
    % title('[15*1,15*-2,15*1]')
    
    % use 1, 2, 4, 8 Hz as cutoff freq to test the effcts of different filters
    figure('Name','IIR FILTER');
    subplot(4,1,1);
    plot(Radar.t_frame,hsig_iir1);
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('1 Hz')
    subplot(4,1,2);
    plot(Radar.t_frame,hsig_iir2);
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('2 Hz')
    subplot(4,1,3);
    plot(Radar.t_frame,hsig_iir3);
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('4 Hz')
    subplot(4,1,4);
    plot(Radar.t_frame,hsig_iir4);
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('8 Hz')

    figure('Name','FIR FILTER');
    subplot(4,1,1);
    plot(Radar.t_frame,hsig_fir1);
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('1 Hz')
    subplot(4,1,2);
    plot(Radar.t_frame,hsig_fir2);
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('2 Hz')
    subplot(4,1,3);
    plot(Radar.t_frame,hsig_fir3);
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('4 Hz')
    subplot(4,1,4);
    plot(Radar.t_frame,hsig_fir4);
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('8 Hz')
    
    % use different matched filter parameters for the test
    figure('Name','MATCHED FILTERING');
    subplot(3,1,1)
    plot(rf);
    xlabel('Sample (n)')
    ylabel('Amplitude')
    title('1st Matched Filter with simple filter')
    xlim([0 8000])
    grid on
    subplot(3,1,2)
    plot(snf2);
    xlabel('Sample (n)')
    ylabel('Amplitude')
    title('2nd Matched Filter with Filter T')
    xlim([0 8000])
    grid on
    subplot(3,1,3)
    plot(snfd);
    xlabel('Sample (n)')
    ylabel('Amplitude')
    title('3nd Matched Filter with Filter D')
    xlim([0 8000])
    grid on
    
    % compare test results
    figure('Name','VITSIG FILTERING');
    subplot(6,1,1);
    plot(hsig_iir4);
    title('IIR 5th-order, 8 Hz')
    subplot(6,1,2);
    plot(hsig_fir4);
    title('FIR 80th-order, 8 Hz')
    subplot(6,1,3)
    plot(snfd);
    title('3nd Matched Filter with Filter D')
    xlim([0 8000])
    subplot(6,1,4);
    plot(hsig1);
    title('[1,-1]')
    subplot(6,1,5);
    plot(hsig2);
    title('[15*1,15*-1]')
    subplot(6,1,6);
    plot(hsig3);
    title('[15*1,15*-2,15*1]')

    % heartbeat_sig_ord1=filtfilt([1,-1],1,vitsig);
    % heartbeat_sig_ord2=filtfilt([1,-2,1],1,vitsig);
    % figure;
    % subplot(2,1,1);
    % plot(Radar.t_frame,heartbeat_sig_ord1);
    % xlabel('Time (s)')
    % ylabel('Amplitude')
    % title('1st order')
    % subplot(2,1,2);
    % plot(Radar.t_frame,heartbeat_sig_ord2);
    % xlabel('Time (s)')
    % ylabel('Amplitude')
    % title('2nd order')
    
    % impulse response
    % figure('Name','IIR & FIR Filter Impulse Response');
    % subplot(4,2,1);
    % impz(b11,a11);
    % subplot(4,2,3);
    % impz(b22,a22);
    % subplot(4,2,5);
    % impz(b33,a33);
    % subplot(4,2,7);
    % impz(b44,a44);
    % subplot(4,2,2);
    % impz(b55);
    % subplot(4,2,4);
    % impz(b66);
    % subplot(4,2,6);
    % impz(b77);
    % subplot(4,2,8);
    % impz(b88);
elseif SigReproduction==true
    % Faithfull reproduction of cardiac & breathing signals
    % test of FIR linear-phase filter
    blp1=fir1(100,0.5/(smp_f/2),'high');
    blp2=fir1(100,1/(smp_f/2),'high');
    blp3=fir1(100,1.5/(smp_f/2),'high');
    blp4=fir1(100,2/(smp_f/2),'high');
    %blp_h=fir1(ord_fir,0.5/(smp_f/2),'high');
    blp_r=fir1(300,0.1/(smp_f/2),'low');
    % signal filtering...
    hsig_lp1=filtfilt(blp1,1,vitsig);
    hsig_lp2=filtfilt(blp2,1,vitsig);
    hsig_lp3=filtfilt(blp3,1,vitsig);
    hsig_lp4=filtfilt(blp4,1,vitsig);
    %hsig_lp=filtfilt(blp_h,1,vitsig);
    % filtering results
    rsig_lp=filtfilt(blp_r,1,vitsig);
    hsig_lp=vitsig-rsig_lp;

    % Print figs
    % figure('Name','LINEAR PHASE FILTER OF CARDIAC SIGNAL');
    % subplot(2,2,1);
    % plot(hsig_lp1);
    % title('0.5 Hz')
    % subplot(2,2,2);
    % plot(hsig_lp2);
    % title('1 Hz')
    % subplot(2,2,3);
    % plot(hsig_lp3);
    % title('1.5 Hz')
    % subplot(2,2,4);
    % plot(hsig_lp4);
    % title('2 Hz')
    %plot(vitsig);
    %hold on
    % plot(hsig_lp1);
    % hold on
    % plot(hsig_lp2);
    % hold on
    % plot(hsig_lp3);
    % hold on
    % plot(hsig_lp4);
    % legend('0.5 Hz','1 Hz','1.5 Hz','2 Hz')
    
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
    
    Rectang_filter=false;
    ZP_filter=false;
    
    if ZP_filter==true
        InterPol=true;
        if InterPol==false
            % Nominal/shorter/longer/longer+ matched filter of Hao
            load('hao_nominal.mat');
            load('hao_short.mat');
            load('hao_long.mat');
            load('hao_longer.mat');
            % Nominal/shorter/longer matched filter of Daniel
            % load('dani_nominal.mat');
            % load('dani_short.mat');
            % load('dani_long.mat');
            %load('longer+.mat'); % not used anymore
        else
            load('hao2_nominal.mat');
            % create filter using linear interpolation
            interpol_sh=linspace(0,length(nominal),length(nominal)*0.5).';
            interpol_lon=linspace(1,length(nominal),length(nominal)*1.5).';
            interpol_longer=linspace(1,length(nominal),length(nominal)*2).';
            short=interp1((1:length(nominal)).',nominal,interpol_sh,'spline');
            long=interp1((1:length(nominal)).',nominal,interpol_lon,'linear');
            long_plus=interp1((1:length(nominal)).',nominal,interpol_longer,'linear');
        end
    elseif Rectang_filter==true
        % Test rectangular filter
        % width
        len_rec_sh=50;
        len_rec_nom=60;
        len_rec_lon=80;
        len_rec_longer=100;
        % nominal
        nominal=zeros(100+len_rec_nom,1);
        nominal(50:50+len_rec_nom)=0.1;
        % shorter
        short=zeros(100+len_rec_sh,1);
        short(50:50+len_rec_sh)=0.1;
        % longer
        long=zeros(100+len_rec_lon,1);
        long(50:50+len_rec_lon)=0.1;
        % longer+
        long_plus=zeros(100+len_rec_longer,1);
        long_plus(50:50+len_rec_longer)=0.1;
        %figure;
        %stem(nominal);
    else
        load('hao_long.mat');
        % Test ZP and linear interpolation based on hao_nominal
        short0=long;
        ZP_orden=2;
        %figure;
        %stem(abs(fft(short0)));
        % create filter using ZP
        fft_sh=fft(short0);
        matri_cero=zeros(length(short0)*ZP_orden,1);
        matri_cero(1:fix(length(short0)/2))=fft_sh(1:fix(length(short0)/2));
        matri_cero(end-(fix(length(short0)/2)-1):end)=fft_sh(end-(fix(length(short0)/2)-1):end);
        short=real(ZP_orden*ifft(matri_cero));
    
        % create filter using linear interpolation based on ZP filter
        interpol_nom=linspace(1,length(short),length(short)*1.1).';
        interpol_lon=linspace(1,length(short),length(short)*1.2).';
        interpol_longer=linspace(1,length(short),length(short)*1.3).';
        nominal=interp1((1:length(short)).',short,interpol_nom,'linear');
        long=interp1((1:length(short)).',short,interpol_lon,'linear');
        long_plus=interp1((1:length(short)).',short,interpol_longer,'linear');
    end

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
    
    MF2=false; % 2nd matched filter
    if MF2==true
        % 1st matched filtering
        rf_nom1=conv(hsig_lp,nominal);
        rf_sh1=conv(hsig_lp,short);
        rf_lon1=conv(hsig_lp,long);
        % 2nd matched filtering
        rf_nom2=conv(rf_nom1,nominal);
        rf_sh2=conv(rf_sh1,short);
        rf_lon2=conv(rf_lon1,long);
        % amplitude normalization referring to hsig_lp
        rf_nom=rf_nom2*(max(abs(hsig_lp))/max(abs(rf_nom2)));
        rf_sh=rf_sh2*(max(abs(hsig_lp))/max(abs(rf_sh2)));
        rf_lon=rf_lon2*(max(abs(hsig_lp))/max(abs(rf_lon2)));
        % test longer+ filter
        rf_longer1=conv(hsig_lp,long_plus);
        rf_longer2=conv(rf_longer1,long_plus);
        rf_longer=rf_longer2*(max(abs(hsig_lp))/max(abs(rf_longer2)));
    elseif Rectang_filter==true
        % 1st MF
        rf_nom1=conv(hsig_lp,nominal);
        rf_sh1=conv(hsig_lp,short);
        rf_lon1=conv(hsig_lp,long);
        rf_longer1=conv(hsig_lp,long_plus);
        % signal shifting to eliminate delay
        rf_nom=circshift(rf_nom1,-length(nominal)/2);
        rf_sh=circshift(rf_sh1,-length(short)/2);
        rf_lon=circshift(rf_lon1,-length(long)/2);
        rf_longer=circshift(rf_longer1,-length(long_plus)/2);
    else
        % 1st MF
        rf_nom1=conv(hsig_lp,nominal);
        rf_sh1=conv(hsig_lp,short);
        rf_lon1=conv(hsig_lp,long);
        rf_longer1=conv(hsig_lp,long_plus);
        % amplitude normalization referring to hsig_lp
        rf_nom=rf_nom1*(max(abs(hsig_lp))/max(abs(rf_nom1)));
        rf_sh=rf_sh1*(max(abs(hsig_lp))/max(abs(rf_sh1)));
        rf_lon=rf_lon1*(max(abs(hsig_lp))/max(abs(rf_lon1)));
        rf_longer=rf_longer1*(max(abs(hsig_lp))/max(abs(rf_longer1)));
    end
    
    % figure('Name','Adaptive Matched Filter: NOMINAL');
    % plot(rf_nom);
    % hold on
    % plot(vitsig);
    % grid on
    % figure('Name','Adaptive Matched Filter: SHORTER');
    % plot(rf_sh);
    % hold on
    % plot(vitsig);
    % grid on
    % figure('Name','Adaptive Matched Filter: LONGER');
    % plot(rf_lon);
    % hold on
    % plot(vitsig);
    % grid on
 
    % Evaluation and quality factor
    if Rectang_filter==true
        % calcu RMS
        power_rms_sh=sum(abs(rf_sh).^2)/length(rf_sh);
        power_rms_nom=sum(abs(rf_nom).^2)/length(rf_nom);
        power_rms_lon=sum(abs(rf_lon).^2)/length(rf_lon);
        power_rms_longer=sum(abs(rf_longer).^2)/length(rf_longer);
        % peaks detection
        [amp_sh,locs_sh]=findpeaks(rf_sh,1:length(rf_sh),'MinPeakProminence',power_rms_sh);
        [amp_nom,locs_nom]=findpeaks(rf_nom,1:length(rf_nom),'MinPeakProminence',power_rms_nom);
        [amp_lon,locs_lon]=findpeaks(rf_lon,1:length(rf_lon),'MinPeakProminence',power_rms_lon);
        [amp_longer,locs_longer]=findpeaks(rf_longer,1:length(rf_longer),'MinPeakProminence',power_rms_longer);
        % plot figs...
        figure('Name','Adaptive Matched Filter: SHORTER');
        findpeaks(rf_sh,1:length(rf_sh),'MinPeakProminence',power_rms_sh);
        text(locs_sh+.02,amp_sh,num2str((1:numel(amp_sh))'))
        hold on
        plot(hsig_lp);
        %legend('Filtered signal with peaks detected','Extracted cardiac signal')
        figure('Name','Adaptive Matched Filter: NOMINAL');
        findpeaks(rf_nom,1:length(rf_nom),'MinPeakProminence',power_rms_nom);
        text(locs_nom+.02,amp_nom,num2str((1:numel(amp_nom))'))
        hold on
        plot(hsig_lp);
        figure('Name','Adaptive Matched Filter: LONGER');
        findpeaks(rf_lon,1:length(rf_lon),'MinPeakProminence',power_rms_lon);
        text(locs_lon+.02,amp_lon,num2str((1:numel(amp_lon))'))
        hold on
        plot(hsig_lp);
        figure('Name','Adaptive Matched Filter: LONGER+');
        findpeaks(rf_longer,1:length(rf_longer),'MinPeakProminence',power_rms_longer);
        text(locs_longer+.02,amp_longer,num2str((1:numel(amp_longer))'))
        hold on
        plot(hsig_lp);
        % calcu QF
        % index of peaks detection
        IndexPeaks_sh=(sum(amp_sh.^2)/length(locs_sh))/power_rms_sh;
        IndexPeaks_nom=(sum(amp_nom.^2)/length(locs_nom))/power_rms_nom;
        IndexPeaks_lon=(sum(amp_lon.^2)/length(locs_lon))/power_rms_lon;
        IndexPeaks_longer=(sum(amp_longer.^2)/length(locs_longer))/power_rms_longer;
        %QF=max(abs(rf).^2)/power_rms;
        % printing...
        fprintf('Index of peaks detection - shorter: %.4f\n',IndexPeaks_sh);
        fprintf('Index of peaks detection - nominal: %.4f\n',IndexPeaks_nom);
        fprintf('Index of peaks detection - longer: %.4f\n',IndexPeaks_lon);
        fprintf('Index of peaks detection - longer+: %.4f\n',IndexPeaks_longer);
        %fprintf('QF of rectangle: %.4f\n',QF);
    else
        % print fig...
        figure;
        subplot(4,1,1)
        plot(rf_nom1);
        title('nominal')
        subplot(4,1,2)
        plot(rf_sh1);
        title('shorter')
        subplot(4,1,3)
        plot(rf_lon1);
        title('longer')
        subplot(4,1,4)
        plot(rf_longer1);
        title('longer+')

        % calcu RMS of the signal power
        power_rms_nom=sum(abs(rf_nom).^2)/length(rf_nom);
        power_rms_sh=sum(abs(rf_sh).^2)/length(rf_sh);
        power_rms_lon=sum(abs(rf_lon).^2)/length(rf_lon);
        power_rms_longer=sum(abs(rf_longer).^2)/length(rf_longer);
        % calcu QF
        QF_lon=max(abs(rf_lon).^2)/power_rms_lon;
        QF_longer=max(abs(rf_longer).^2)/power_rms_longer;
        QF_nom=max(abs(rf_nom).^2)/power_rms_nom;
        QF_sh=max(abs(rf_sh).^2)/power_rms_sh;
        % printing...
        fprintf('QF of longer: %.4f\n',QF_lon);
        fprintf('QF of longer+: %.4f\n',QF_longer);
        fprintf('QF of nominal: %.4f\n',QF_nom);
        fprintf('QF of shoter: %.4f\n',QF_sh);
    end
end


%% TRABAJO POSTERIOR
% %% FURTHER Signal Processing with different algorithm
% % includes: subtracting mean, MTI algorithm, EMD, STFT
% if doMoreAnalysingSwitch==true
%     %----------------------------------TRY-EMD-----------------------------------------------
%     waitbar(.4,f,'Apply EMD ...');
%     lineWithPeak=find(Sampling.f==LocFinder.locs_positive(1)); %TAKE RIGHT NOW PEAK 1
%     angleArrayUnwrap=1000 * ((Radar.lambda/(4*pi)) * unwrap(angle(Spectrum(lineWithPeak,1:Digitizer.wfrm))) - angle(Spectrum(lineWithPeak,1)) * Radar.lambda/(4*pi));
%     [imf,residual]=emd(angleArrayUnwrap,'Interpolation','pchip','Display',1,'MaxNumIMF',9);
%     emdPlot=figure('Name','EMD Plot');
%     for k=1:length(imf(1,:))
%         subplot(9,1,k)
%         plot(Radar.t_frame,imf(:,k))
%         ylabel(['IMF ',num2str(k)])
%         grid on;
%     end
%     % Make Plot of 8 IMFs and one Residual
%     subplot(9,1,9)
%     plot(Radar.t_frame,residual(:,1))
%     hold on;
%     [TF,S1,S2]=ischange(imf(:,1),'linear','Threshold',0.01);
%     plot(Radar.t_frame,TF);
%     hold off
%     ylabel('Residual');
%     xlabel('Time (s)');
%     
%     
%     %% EVALUATE SAMPLES AROUND PEAK
%     % Select space between peaks for evaluation for detecting another peak
%     % close to the original. Thus, the result of the peak sample depend
%     % also on the chirp which is used for searching a peak
%     waitbar(.45,f,'Evaluate samples around Peak ...');
% 
%     evaluationOffset=64;      % Space in samples betweeen each other (consider ZP!)
%     evaluationPoints=9;        % Number of evaluated samples in surrounding incl. the origin in the middle of first peak
%     lineWithPeak=find(Sampling.f==LocFinder.locs_positive(1)); % it takes the original highes peak to observe surrounding
%     
%     evaluationNextToPeak=figure('Name','Evaluate Surrounding Next To Peak');
%     for k=1:evaluationPoints
%         subplot(9,1,k)
%         SmpNextToPeak=lineWithPeak + evaluationOffset*(k-round(evaluationPoints/2)); 
%         angleArrayUnwrap=1000*((Radar.lambda/(4*pi))*unwrap(angle(Spectrum(SmpNextToPeak,1:Digitizer.wfrm)))-angle(Spectrum(SmpNextToPeak,1))*Radar.lambda/(4*pi));
%         plot(Radar.t_frame,angleArrayUnwrap);
%         ylabel('Dist (mm)')
%         title(['Cell Nmbr:',num2str(SmpNextToPeak)]);
%         yyaxis right
%         plot(Radar.t_frame,mag2db(Spec_abs(SmpNextToPeak,1:Digitizer.wfrm)/max(Spec_abs(SmpNextToPeak,1:Digitizer.wfrm))));
%         ylabel('Mag (dB)')
%         grid on;
%     end
% 
% 
% %% Subtract Mean Value
% % Mean value over whole acquisition is build to subtract
%     if(tryCompensationBySubtraction==true)
%         % it contains right now only subtract by mean value
%         waitbar(.5,f,'Subtract Mean Value ...');
%         estimationMatrix=mean(Spectrum,2);
%         fdbCORRECTED=zeros(Sampling.ZP*Sampling.L,Digitizer.wfrm);
%         for k=1:size(Spectrum,2)
%             fdbCORRECTED(:,k)=Spectrum(:,k)-1*estimationMatrix;
%         end
%         
%         Spec_shiftCORRECTED=((fdbCORRECTED));
%         Spec_absCORRECTED=abs(Spec_shiftCORRECTED);
%         theMaxOfMatrixCORRECTED=max(Spec_absCORRECTED);
%         theMaxOfMatrixCORRECTED=max(theMaxOfMatrixCORRECTED);
%         for k=1:length(Spec_absCORRECTED(1,:))
%             Spec_abs2CORRECTED(:,k)=Spec_absCORRECTED(:,k)./theMaxOfMatrixCORRECTED;
%         end
%         Spec_abs_dBCORRECTED=mag2db(Spec_abs2CORRECTED);
%         % Plot the subtracted Phase
%         phaseWithUnwrapCORRECTED=plotPhase(Radar,Digitizer,Sampling,LocFinder,Spec_shiftCORRECTED,RMS_Amplitude,true,'SUBTRACTED MEAN VALUE');
%         
%         %-------
%         waitbar(.6,f,'Make more Plots ...');
%         %---------
%         figure;
%         timesignal=reshape(beatingTone_time_window,[1 4096000]);
%         subplot(3,1,1);
%         stft(imf(:,1),Sampling.Fs,'FFTLength',128*4,'Window',hamming(16)) % hamming64
%         title('STFT of IMF 1')
%         %xlim([21 23])
%         subplot(3,1,2);
%         plot(Radar.t_frame,(imf(:,1)+imf(:,2)+imf(:,3)+imf(:,4))); 
%         xlabel('Time (s)')
%         ylabel('IMF sum of 1,2,3')
%         %xlim([22 24])
%         subplot(3,1,3);
%         stft(RMS_Amplitude,Sampling.Fs,'FFTLength',64,'Window',hamming(8))
%         %xlim([21 23])
%         title('STFT of RMS Amplitude')
%         
%         [imf2,residual2]=emd(RMS_Amplitude,'Interpolation','pchip','Display',1,'MaxNumIMF',9);
%         emdPlot2=figure('Name','EMD Plot Amplitude');
%         for k=1:length(imf2(1,:))
%             subplot(9,1,k)
%             plot(Radar.t_frame,imf2(:,k))
%             ylabel(['IMF ',num2str(k)])
%             ylabel('IMF x')
%             xlabel('Time (s)')
%             grid on;
%         end
%         
%         imfsum2=imf2(:,1)+imf2(:,2)+imf2(:,3);
%         figure;
%         plot(Radar.t_frame,imfsum2)
%         xlabel('Time (s)')
%         ylabel('Amplitude IMFs sum of 1,2,3')
%         set(phaseWithUnwrapCORRECTED,'Position',[580, 30, 580, 800])
%     end
%     
%     % divide bandwidth in n similiar parts
%     if(reduceBandwidthFunction==true)
%         waitbar(.7,f,'Set down Bandwidth ...');
%         decimationOfBandwidth=3; % will split into x parts
%         divBeatingTone_time=setDownBandwidthOfChirp(beatingTone_time,decimationOfBandwidth);
%         waitbar(.8,f,'Make new FFT for sperated Bandwidth ...');
%         [SpectrumDivided,Spec_abs_dBDivided]=doFFT(divBeatingTone_time,Sampling,Digitizer,decimationOfBandwidth);
%         waitbar(.9,f,'Search Peaks and produce Plots ...');
%         [LocationsDivided,checkValue]=searchPeaks(Spec_abs_dBDivided,Sampling,decimationOfBandwidth);
%         result=makeFreqPlots(Spec_abs_dBDivided,LocationsDivided,Sampling,Radar,decimationOfBandwidth);
%         % Produce Unwrap Plot
%         UnwrapUncorrected1=plotPhase(Radar,Digitizer,Sampling,LocationsDivided{1},SpectrumDivided{1},RMS_Amplitude,true,'UNWRAP_DECBW1');
%         UnwrapUncorrected2=plotPhase(Radar,Digitizer,Sampling,LocationsDivided{2},SpectrumDivided{2},RMS_Amplitude,true,'UNWRAP_DECBW2');
%         UnwrapUncorrected3=plotPhase(Radar,Digitizer,Sampling,LocationsDivided{3},SpectrumDivided{3},RMS_Amplitude,true,'UNWRAP_DECBW3');
%         %NoUnwrapUncorrected=plotPhase(Radar,Digitizer,Sampling,LocationsDivided{1},SpectrumDivided{1},RMS_Amplitude,false,'STANDARD');
%     end
% end
% 
% delete(f);
