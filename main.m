% MAIN function for PROCESSING recorded data
% by the radar @UPC CommSensLab
% 28/05/2025 Wu Ruochen

clear;
close all;

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
Digitizer.wfrm=8000; % 24s
% Sampling
Sampling.ZP=32;                                   % Zero-padding
Sampling.Fs=1.3672e+06/Digitizer.decimation;      % Sampling frequency CHANGED for new HW                 
Sampling.T=1/Sampling.Fs;                         % Sampling period (s)
Sampling.L=2048/Digitizer.decimation;             % Length of signal CHANGED was 256
t=(0:Sampling.L-1)*Sampling.T;                    % Time vector (s)


%% CARDIAC SIGNAL FILTERING
% Vital signal filtering and extraction of heartbeat & respiration signal
% original radar micro-motion signal extraction
load('D:\UPC\HUGTiP\EstudioPrevio\20250618\ruochen_t2_2_vitsig');
load('D:\UPC\HUGTiP\EstudioPrevio\20250618\synchronization\ruochen2t_2');

ecg_pro=700;
Radar.t_frame=(0:Digitizer.wfrm-1)*T_frame;
ECG_t_frame=(0:length(ecg_lead2)-1)*(1/500);

% FIR linear-phase filter
smp_f=1/T_frame; % sampling
cutoff_f=0.3; % cut-off frecuency %0.1
blp_r=fir1(300,cutoff_f/(smp_f/2),'low');
% filtering results
rsig_lp=filtfilt(blp_r,1,vitsig);
hsig_lp=vitsig-rsig_lp;

% clean the cardiac signal
hsig_fft=fft(hsig_lp);
hsig_fft(1:40)=0; % eliminate the noise
hsig_lp=real(ifft(hsig_fft));

figure('Name','SEPARATION OF BREATHING & CARDIAC SIGNAL');
subplot(2,1,1)
plot(Radar.t_frame,vitsig);
hold on
plot(Radar.t_frame,rsig_lp);
grid on
h1=legend('Vital signal','Respiratory signal');
%set(h1,'Orientation','horizon')
%legend('boxoff')
% ylim([-0.5 0.5])
xlabel('Time (s)')
ylabel('Amplitude (mm)')
title('Extracted respiratory signal')
subplot(2,1,2)
plot(Radar.t_frame,hsig_lp);
grid on
xlabel('Time (s)')
ylabel('Amplitude (mm)')
%xlim([0 24])
%ylim([-0.23 0.17])
title('Extracted cardiac signal')


%% FASE A: ITERATIVE PULSE PERIOD ESTIMATION
% ZP for FFT
orden_zp=32;
% RR estimation
[amp_rr,loc_rr]=findpeaks(rsig_lp,Radar.t_frame,'MinPeakProminence',0.2);
t_resp=(0:length(respiration)-1)/256; 
[amp_rrR,loc_rrR]=findpeaks(respiration,t_resp,'MinPeakProminence',50,'MinPeakDistance',0.5);

figure;
plot(Radar.t_frame,rsig_lp,loc_rr,amp_rr,'rv');
hold on
yyaxis right
plot(t_resp,respiration,loc_rrR,amp_rrR,'bv');

% RR by intervals between the peaks
loc_med_rr=mean(diff(loc_rr));
loc_med_rrR=mean(diff(loc_rrR));
bpm_rrR=60/loc_med_rrR;
bpm_rr=60/loc_med_rr;

% printing RR...
fprintf('The RR of the subject is: <strong>%.4f</strong> bpm.\n',bpm_rrR);
fprintf('The determined RR of the subject is: <strong>%.4f</strong> bpm.\n',bpm_rr);

% HR estimation
sig=hsig_lp;
sig_zp=[sig zeros(1,orden_zp*length(sig))];
sig_fft=fft(sig_zp); % FFT
% plot(abs(sig_fft))

% Signal cleaning accroding to normal bpm: 40-200 -> 0.667 Hz(bps)-3.333 Hz(bps)
% window function to smooth the signal
win=zeros(1,length(sig_fft));
% normal bpm corresponds to the sampling data in freq domain signal
h_low=round((0.667*length(sig))/(1/T_frame))+1; % in MATLAB +1
h_high=round((3.333*length(sig))/(1/T_frame))+1;

win(h_low*orden_zp:h_high*orden_zp)=1;
% smooth both sides of a rectangular wave
k=1;
for i=h_high*orden_zp+1:h_high*orden_zp+4
    win(i)=cos(k*pi/8);
    k=k+1;
end

k=1;
for i=h_low*orden_zp-1:-1:h_low*orden_zp-4
    win(i)=cos(k*pi/8);
    k=k+1;
end
% spectral window for both sides
win(length(sig_fft)-(h_high*orden_zp+4)+1:length(sig_fft)-(h_low*orden_zp-4)+1)=win(h_low*orden_zp-4:h_high*orden_zp+4);

% signal windowing
sig_fclean=sig_fft.*win;
% plot(abs(sig_fclean))
sig_fclean_cut=sig_fclean(1:length(sig_fclean)/2); % right side

% Determinate the cardiac period based on spectrum
SIG0=abs(sig_fclean_cut);
SIG=abs(sig_fclean_cut);
SIG(find(SIG<0.03))=[]; % clean the spectrum
amp_mean=mean(SIG);
% find the principle peaks
[amp_fft,loc_fft]=findpeaks(SIG0(1:length(SIG0)),1:length(SIG0),'MinPeakProminence',amp_mean*2,'MinPeakDistance',400);

% T estimation
loc_d=HRestim(T_frame,sig,sig_fclean_cut,sig_fft,loc_fft);
%loc_d=HRestim0(T_frame,SIG0,sig_fclean_cut,sig_fft,amp_fft,loc_fft);

% spectrum resolution
Fs_fclean=1/(length(sig_fft)*T_frame);
% calcu heart rate of the subject (bps & bpm)
bps=loc_d*Fs_fclean;
bpm_fft=bps*60;
T.fil0=round((1/bps)/T_frame);

% printing HR...
fprintf('The estimated HR of the subject is: <strong>%.2f</strong> bpm. (by FFT)\n',bpm_fft);

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
figure('Name','CARDIAC PULSE IDENTIFICATION');
subplot(3,1,1:2)
plot(Radar.t_frame,hsig(1:len_sig),locs_hsig,amp_hsig,'rv','LineWidth',1.3);
text(locs_hsig+.1,amp_hsig,num2str((1:numel(amp_hsig))'))
hold on
plot(Radar.t_frame,sig,'-','Color','#D95319','LineWidth',1.5);
%xlabel('Time (s)')
grid on
ylabel('Cardiac Amplitude (mm)')
legend('Heartbeat detection','Identified pulse','Cardiac signal');

% peaks detection based on ECG signal
[amp_ecg,locs_ecg]=findpeaks(ecg_leadv1,ECG_t_frame,'MinPeakProminence',ecg_pro);
% plot ECG signal...
subplot(3,1,3);
plot(ECG_t_frame,ecg_leadv1,'g',locs_ecg,amp_ecg,'rv','LineWidth',1.3);
text(locs_ecg+.1,amp_ecg,num2str((1:numel(amp_ecg))'))
grid on
xlabel('Time (s)')
ylabel('ECG')

% calcu heart rate of the subject
bpm_ecg=60/mean(diff(locs_ecg));
%bpm_pks=length(locs_hsig)/(length(sig)*T_frame/60); % by peaks
% by intervals between the peak
loc_diff=diff(locs_hsig);
threshold=mean(loc_diff)+2*std(loc_diff);  

% check whether there is any missed peak
while max(loc_diff)>threshold
    [~,idx]=max(loc_diff);
    loc_diff(idx)=[];
end

loc_med_rr=mean(loc_diff);
bpm_intv=60/loc_med_rr;

% printing...
fprintf('The HR of the subject is: <strong>%.4f</strong> bpm. (by ECG)\n',bpm_ecg);
fprintf('The determined HR of the subject is: <strong>%.4f</strong> bpm. (by intervals)\n',bpm_intv);

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
