%% Vitalsense 3. Non perfect repetitive cardiac pulses analysis and filtering
% TB may 2023
close all;
clear;
L=1024; % length of the FMCW radar motion recording after phase unwrap of FFT patient range sample
nrep=64; % nominal samples of nominal cardiac beat period 
zeropad=16; % zeropadding for better Fourier analysis with FFT
%a= zeros (L,1);
% % tren periodic
% log2L=log2(L)
% a=zeros(nrep,1);
% a(1)=1;
% b=repmat(a,L/nrep,1)
% figure;
% plot(b);
% TFb = fft(b,L*zeropad);
% figure;
% plot(abs(TFb));
% periodic train (burst) of deltas corresponding to cardiac beats
nominal_positions=(1:nrep:L);
c=zeros(L,1);
c(nominal_positions)=1;
figure;
plot(c);
title('periodic burst')
TFc=fft(c,L*zeropad);
figure;
plot(abs(TFc));
title('FFT of periodic burst')
% now we buid a more realistic cardiac beat burst introducing random time jitter
d=zeros(L,1);
nominal_positions=(1:nrep:L)'; % cardiac beat nominal positions
jitter_level=2; % jitter shift level in sample positions +/- induced by a realistic heart 
jitter_vector=round(jitter_level*(2*rand(size(nominal_positions,1),1)-1)); % time sample jitter shift w.r.t. periodic case
perturbed_positions=nominal_positions+jitter_vector;
if perturbed_positions(1)<1
    perturbed_positions(1)=1; % we enforce the first position is not under vector limits
end
if perturbed_positions(end)>L
    perturbed_positions(end)=L; % we force the last position is not above vector limits
end
d(perturbed_positions)=1;
figure;
plot(d);
title('aperiodic burst')
TFd=fft(d,L*zeropad);
figure;
plot(abs(TFd));
title('FFT of aperiodic burst')
% we design a cardiac-like pulse
pulse=[-0.2;-0.5;-1;0;1;0.5;0.2];
figure;
plot(pulse)
title('pulse')
TFpulse=fft(pulse,L*zeropad);
figure;
plot(abs(TFpulse));
title('FFT of pulse')
% we use the aperiodic burst to build a radar-like thorax motion signal 
signal=conv(d,pulse);
figure;
plot(signal);
title('signal')
TFsignal=fft(signal,L*zeropad);
figure;
plot(abs(TFsignal));
title('FFT of signal')
% we generate white gaussian noise of variance=1
whitenoise=randn(L,1);
figure;
plot(whitenoise);
title('whitenoise')
% we filter low pass the noise to correlate it
% we maintain the variance = 1
LPF_length=256;
LPF=triang(LPF_length); % we use a triangular window as low-pass imp. response
noise=(1/sqrt(LPF_length))*conv(whitenoise,LPF);
figure;
plot(noise);
title('noise')
% we use the shortest vector length signal and noise since after the convolution 
% they do not have the same duration
length=min(size(signal,1),size(noise,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
snr_dB=-34; % SNR in dB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
snr=10^(snr_dB/10); % SNR in linear ratio
var_s=((size(pulse,1)-1)/size(pulse,1))*var(pulse); % signal variance compensating for matlab wrong normalization
var_n=((size(pulse,1)-1)/size(pulse,1))*var(noise); % noise variance compensating for matlab wrong normalization
noise_gain=sqrt((var_s/var_n)/snr); % we compute the noise gain to be applied to satisfy desired SNR
sn=signal(1:length)+noise_gain*noise(1:length);
figure;
plot(sn);
title('signal + noise')
% we extract the DC to avoid the large peak at origin after FFT
dc=mean(sn);
snac=sn-dc;
TFsnac=fft(snac,L*zeropad);
figure;
plot(abs(TFsnac));
title('FFT of signal (ac) + noise')
% high Pass matched filter to pulse
h=[0.2;0.5;1;0;-1;-0.5;-0.2]; % for a HP response make sure the sum of all coeff's is zero
snf=conv(sn,h); % matched filter response
figure;
plot(snf)
title('snf')

% 2nd HP matched filter to flaten filtered signal and enhance peaks
% for a HP response make sure the sum of all coeff's is zero
h2=[-0.11;-0.57;-0.92;-0.53;1.27;1.72;1.27;-0.53;-0.92;-0.57;-0.11]; 
snf2=conv(snf,h2);
figure;
plot(snf2);
title('snf2')
% autocorrel
snfauto=conv(snf,snf);
figure;
plot(snfauto);
title('autocorrelation of filtered sn');

% FIR linear-phase filter for the breathing signal reproduction
b=fir1(30,0.1/(200/2),'low');
rsig=filtfilt(b,1,sn);
figure;
plot(rsig);
hold on
plot(sn);
% extraction of cardiac signal
hsig=sn-rsig;
figure;
plot(hsig);
hold on
plot(sn);


%% TEST FOR THE RADAR MEASUREMENTS
h=[0.2;0.5;1;0;-1;-0.5;-0.2]; % simple filter
h2=[-0.11;-0.57;-0.92;-0.53;1.27;1.72;1.27;-0.53;-0.92;-0.57;-0.11]; % filter T
h3=[-0.92;-0.45;-0.11;-0.57;-0.92;-0.53;1.27;1.72;1.27;-0.53;-0.92;-0.57;-0.11;-0.45;-0.92]; % filter W
snf=conv(vitsig,h);
snf2=conv(snf,h2);
snf3=conv(snf2,h3);
figure;
subplot(3,1,1)
plot(snf);
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
plot(snf3);
xlabel('Sample (n)')
ylabel('Amplitude')
title('3nd Matched Filter with Filter W')
xlim([0 8000])
grid on


