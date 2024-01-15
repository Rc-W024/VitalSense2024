%% CREATE A SIGNAL TO TEST THE QF
sig0=hsig_lp(4286:4536);
sig1=interp1((1:length(sig0)),sig0,linspace(1,length(sig0),length(sig0)*0.7),'linear');
sig=repmat(sig1,1,30);
figure;
plot(sig);

%% ATAPTIVE MATCHED FILTER DESIGN
% extract the pulse waveform
hd1=hsig_lp(4286:4536);
hd2=hd1;
hd2(length(hd2))=hd2(1);
hd=fliplr(hd2); % h(t)=p(-t)

% no use anymore: align to 0
%plot(autocorr(hd));
zhd=zeros(1,1000);
zhd(250:250+length(hd)-1)=hd;
%plot(zhd);
fil=conv(zhd,hd);
%plot(fil);
% filtering test
res1=conv(fil,hsig_lp);
res0=2*(res1*(max(abs(hsig_lp))/max(abs(res1))));
res=circshift(res0,fix(-length(res0)-550));
figure;
plot(res);
hold on
plot(hsig_lp);
% no use anymore: down resmp
hd=hd-mean(hd);
hd_resmp0=hd(1:20:end);
hd_resmp0=hd_resmp0';
dani_long=[0;hd_resmp0(1:end);0];

%% NUEVO FILTRADO - HAO 20230623
% vitsig
hd=vitsig(3928:4190);
hd=hsig_lp(3928:4190);
hd_ac=hd-mean(hd);
fft_hd_ac=fft(hd_ac);
fft_hd_ac_clean=zeros(1,263);
fft_hd_ac_clean(1:81)=fft_hd_ac(1:81);
fft_hd_ac_clean(181:263)=fft_hd_ac(181:263);
hao2_nominal=real(ifft(fft_hd_ac_clean));
hao2_nominal=fliplr(hao2_nominal)';

%% QF - OLD VERSION (dead case)
% find troughs in the signal due to their apparent
[~,locs_lon]=findpeaks(-rf_lon,1:length(rf_lon),'MinPeakProminence',0.1,'MinPeakDistance',220);
[~,locs_longer]=findpeaks(rf_longer,1:length(rf_longer),'MinPeakProminence',0.1,'MinPeakDistance',220);
[~,locs_nom]=findpeaks(rf_nom,1:length(rf_nom),'MinPeakProminence',0.1,'MinPeakDistance',220);
[~,locs_sh]=findpeaks(-rf_sh,1:length(rf_sh),'MinPeakProminence',0.1,'MinPeakDistance',220);
% calcu width
width_lon=diff(locs_lon);
width_nom=diff(locs_nom);
width_sh=diff(locs_sh);
width_longer=diff(locs_longer);
% calcu QF using standard deviation (the smaller the better)
QF_lon=std(width_lon);
QF_nom=std(width_nom);
QF_sh=std(width_sh);
QF_longer=std(width_longer);
% printing...
fprintf('QF of longer: %.4f\n',QF_lon);
fprintf('QF of longer+: %.4f\n',QF_longer);
fprintf('QF of nominal: %.4f\n',QF_nom);
fprintf('QF of shoter: %.4f\n',QF_sh);

%% RECTANGULAR FILTER PLOT
subplot(11,1,1)
stem(rec50)
xlim([0 480])
ylim([-0.05 0.2])
title('50%')
subplot(11,1,2)
stem(rec60)
xlim([0 480])
ylim([-0.05 0.2])
title('60%')
subplot(11,1,3)
stem(rec70)
xlim([0 480])
ylim([-0.05 0.2])
title('70%')
subplot(11,1,4)
stem(rec80)
xlim([0 480])
ylim([-0.05 0.2])
title('80%')
subplot(11,1,5)
stem(rec90)
xlim([0 480])
ylim([-0.05 0.2])
title('90%')
subplot(11,1,6)
stem(nominal)
xlim([0 480])
ylim([-0.05 0.2])
title('100% (nominal)')
subplot(11,1,7)
stem(rec110)
xlim([0 480])
ylim([-0.05 0.2])
title('110%')
subplot(11,1,8)
stem(rec120)
xlim([0 480])
ylim([-0.05 0.2])
title('120%')
subplot(11,1,9)
stem(rec130)
xlim([0 480])
ylim([-0.05 0.2])
title('130%')
subplot(11,1,10)
stem(rec140)
xlim([0 480])
ylim([-0.05 0.2])
title('140%')
subplot(11,1,11)
stem(rec150)
xlim([0 480])
ylim([-0.05 0.2])
title('150%')

