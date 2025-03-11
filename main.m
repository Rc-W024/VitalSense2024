% MAIN function for RECORDING and READING recorded data as well as further 
% processing for VitalSense by the radar @UPC CommSensLab
% VitalSense 2024 for biometrics and biomedical applications
% 10/03/2025 Ruochen Wu for v.10.0 (since 15/03/2023 for v.0.0)

clear;
close all;
% ADD path to AlazarTech mfiles for the recording
addpath('C:\AlazarTech\ATS-SDK\7.3.0\Samples_MATLAB\Include')



%-----------------------------------------RECORDING and PROCESSING CONFIGS----------------------------------------------

%--------------------------------------------RECORD or USE EXISTING DATA------------------------------------------------
useExistingFile = true;         % keep this switch: for exising recording processing
%-----------------------------------------------------------------------------------------------------------------------
twoChannelMode = true;          % FALSE = ONLY radar channel, TRUE = 2 channels: CHA=radar channel + CHB=ECG channel;
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
Open_strFolder = 'X:\...\data\*.mat'; 
% Select folder to save measurement
Save_strFolder = "X:\...\data\";
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
            % CHA Radar = beatingTone_time + CHB ECG = ECGSignal
            load(fitxer,'data','beatingTone_time','ECGSignal')
            %ECGSignal=ButtonSignal; % ButtonSignal: !!ONLY USED IN CASES OF 20240214!!
        else
            % only radar signal beatingTone_time
            load(fitxer,'data','beatingTone_time')
        end
        
    else
        % use for .bin files, in latest measurements not used anymore
        [filename,pathname]=uigetfile('C:\AlazarTech\ATS-SDK\7.3.0\Samples_MATLAB\ATS9120\...\*.bin','Select Fast GBSAR file'); 
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

distanceOfObject=(Radar.Tm*Radar.c_0 .*Sampling.f)/(2*Radar.deltaf);

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
cutoff_f=0.3; % cut-off frecuency
blp_r=fir1(300,cutoff_f/(smp_f/2),'low');
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
% ZP for FFT
orden_zp=32;
% RR estimation
[amp_rr,loc_rr]=findpeaks(rsig_lp,Radar.t_frame,'MinPeakProminence',0.2);
% RR by intervals between the peaks
loc_med_rr=mean(diff(loc_rr));
bpm_rr=60/loc_med_rr;

% printing RR...
fprintf('The detected RR of the subject is: <strong>%.2f</strong> bpm.\n',bpm_rr);

% HR estimation
sig=hsig_lp;
sig_zp=[sig zeros(1,orden_zp*length(sig))];
sig_fft=fft(sig_zp); % FFT
% plot(abs(sig_fft))

% Signal cleaning accroding to normal bpm: 40-200 -> 0.667 Hz(bps)-3.333 Hz(bps)
% window function to smooth the signal
win=zeros(1,length(sig_fft));
% normal bpm corresponds to the 16th to 80th sampling data of the freq domain signal
%%% -> ((bps_min,max)*length(signal))/fs_radar %%%
%%% Modify dynamically according to the equation according to the actual situation %%%
win(17*orden_zp:81*orden_zp)=1; % in this case for MATLAB: 17-81
% smooth both sides of a rectangular wave
k=1;
for i=81*orden_zp+1:81*orden_zp+4
    win(i)=cos(k*pi/8);
    k=k+1;
end

k=1;
for i=17*orden_zp-1:-1:17*orden_zp-4
    win(i)=cos(k*pi/8);
    k=k+1;
end
% spectral window for both sides
win(length(sig_fft)-(81*orden_zp+4)+1:length(sig_fft)-(17*orden_zp-4)+1)=win(17*orden_zp-4:81*orden_zp+4);

% signal windowing
sig_fclean=sig_fft.*win;
%plot(abs(sig_fclean))
sig_fclean_cut=sig_fclean(1:length(sig_fclean)/2); % right side

% Determinate the cardiac period based on spectrum
SIG0=abs(sig_fclean_cut);
SIG=abs(sig_fclean_cut);
SIG(find(SIG<0.03))=[]; % clean the spectrum
amp_mean=mean(SIG);
% find the principle peaks
[amp_fft,loc_fft]=findpeaks(SIG0(1:length(SIG0)),1:length(SIG0),'MinPeakProminence',amp_mean*2,'MinPeakDistance',400);

% T estimation
loc_d=HRestim(T_frame,SIG0,sig_fclean_cut,sig_fft,amp_fft,loc_fft);

% spectrum resolution
Fs_fclean=1/(length(sig_fft)*T_frame);
% calcu heart rate of the subject (bps & bpm)
bps=loc_d*Fs_fclean;
bpm_fft=round(bps*60);
T.fil0=round((1/bps)/T_frame);

% printing HR...
fprintf('The estimated HR of the subject is: <strong>%d</strong> bpm.\n',bpm_fft);

if twoChannelMode==true
    % ECG period
    minpeakdist_initial=100; % minimum cardiac period: ~ 0.3s
    [amp_ecg,locs_ecg]=findpeaks((double(decimatedECGSignal-2^15)/2^16)*voltageRangeChannelB,1:length((double(decimatedECGSignal-2^15)/2^16)*voltageRangeChannelB),'MinPeakDistance',minpeakdist_initial,'MinPeakProminence',3e-5);
    periodPeaksECG=round(mean(diff(locs_ecg(1:10))));
    
    % print...
    fprintf('Period calculated by spectrum: <strong>%d</strong>.\n',T.fil0);
    fprintf('Period calculated by ECG: <strong>%d</strong>.\n',periodPeaksECG);
end

% Locs of the peaks determination for FASE B
% various filters
filter_simple=1; % 1=sine; 2=triangle; 3=rectangular
% create Filter 0 
if filter_simple==1
    % sin wave
    filA=max(sig)*sin(linspace(0,pi,T.fil0))+min(sig);
elseif filter_simple==2
    % triangle wave
    filA=min(sig)+(sawtooth(2*pi*linspace(0,1,T.fil0),0.5)+1)*(max(sig)-min(sig))/2;
elseif filter_simple==3
    % rectangular wave
    filA=zeros(1,100+T.fil0);
    rectg=max(sig)*square(linspace(0,1,T.fil0));
    filA(51:50+length(rectg))=rectg;
end

% filtering with fil0 to determinate locs of the peaks
sig1_0=conv(sig,filA);
sig1_0=2*(sig1_0*(max(abs(sig))/max(abs(sig1_0))));
% signal shifting to eliminate delay
sig1=circshift(sig1_0,fix(-length(filA)/2));
% peaks detection
len_sig=length(sig); % length of sig
minpeakdist=fix(T.fil0*0.7);
% peaks...
[amp_sig1,locs_sig1]=findpeaks(sig1(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist);
% figure('Name','SIGNAL AFTER APPLYING FILTER 0');
% findpeaks(sig1(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist);
% text(locs_sig1+.02,amp_sig1,num2str((1:numel(amp_sig1))'))
% hold on
% plot(sig,'r');


%% FASE B: PULSE WAVEFORM RECONSTRUCTION FOR AMF
try
    % extract the first and second half of a cardiac period respectively
    pulseA=round(locs_sig1-T.fil0/2);
    pulseB=round(locs_sig1+T.fil0/2);
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
    [amp_hsig,locs_hsig]=findpeaks(hsig(1:len_sig),Radar.t_frame,'MinPeakDistance',minpeakdist*T_frame,'MinPeakProminence',0.02);
    
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
        [amp_ecg,locs_ecg]=findpeaks((double(decimatedECGSignal-2^15)/2^16)*voltageRangeChannelB,Radar.t_frame,'MinPeakDistance',minpeakdist*T_frame,'MinPeakProminence',2e-05);
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
    bpm_pks=length(locs_hsig)/(length(sig)*T_frame/60);
    % by intervals between the peak
    loc_med_rr=mean(diff(locs_hsig));
    bpm_intv=60/loc_med_rr;

    % printing...
    fprintf('The detected HR of the subject is: <strong>%.2f</strong> bpm. (by detected peaks)\n',bpm_pks);
    fprintf('The determined HR of the subject is: <strong>%.2f</strong> bpm. (by intervals)\n',bpm_intv);

    % Reproduction of blood pressure waveform
    % find the locs...
    [amph,locsh]=findpeaks(hsig(1:len_sig),1:len_sig,'MinPeakDistance',minpeakdist,'MinPeakProminence',0.05);
    T.fil1=round(mean(diff(locsh)));
    % extract the first and second half of a cardiac period
    pulseC=round(locsh-T.fil1/2);
    pulseD=round(locsh+T.fil1/2);
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
    % BP waveform
    BP=bp_sum/numel(bp);
    
    figure('Name','BLOOD PRESSURE WAVEFORM');
    plot((1:length(BP))*T_frame,BP,'Color','#D95319','LineWidth',1.5);
    %set(gca,'Box','off');
    xlabel('Time (s)')
    ylabel('Amplidute (mm)')
    grid on
    % set(gca,'xtick',[],'xticklabel',[]);
    % set(gca,'ytick',[],'yticklabel',[]);
catch
    warning('NO target detected! Please check the measurement position.');
end

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


