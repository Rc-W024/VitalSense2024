function loc_d=HRestim(T_frame,sig,sig_fclean_cut,sig_fft,loc_fft)
if length(loc_fft)==1
    loc_d=loc_fft;
elseif isempty(loc_fft)
    loc_d=find(abs(sig_fclean_cut)==max(abs(sig_fclean_cut)));
else
    % bpm estimation
    bpm_estim=loc_fft*(1/(length(sig_fft)*T_frame))*60;
    % cantidate selection
    loc_cantidate=loc_fft(find(bpm_estim>40 & bpm_estim<130));
    bpm_cantidate=loc_cantidate*(1/(length(sig_fft)*T_frame))*60;

    if length(bpm_cantidate)==2
        diff_min=abs(bpm_cantidate(1)-40);
        diff_max=abs(bpm_cantidate(2)-120);
        if diff_min>diff_max
            loc_d=loc_cantidate(1);
        else
            loc_d=loc_cantidate(2);
        end
    else
        % Calcu signal's autocorrelation to obtain the ref period
        % minimum distance between peaks
        minpeakdist_initial=round(60/(130*T_frame)); % bpm ~130
        [c,lags]=xcorr(sig); % autocorrelation
        idx_end=length(sig)+round(60/(40*T_frame)); % bpm ~40
        [amp_arr0,loc_arr0]=findpeaks(c(length(sig):end),'MinPeakDistance',minpeakdist_initial);
        minpeakpro_initial=mean(amp_arr0);
        [amp_arr,loc_arr]=findpeaks(c(length(sig):idx_end),'MinPeakProminence',minpeakpro_initial);
        
        % T determination
        if length(loc_arr)>1
            bpm_matriu=60./(loc_arr'*T_frame);
            bpm_matriu=flipud(bpm_matriu);
            bpm_cantidate=bpm_cantidate(:);
    
            bpm_matriu(find(bpm_matriu<40))=[];
            bpm_matriu(find(bpm_matriu>120))=[];
    
            if isempty(bpm_matriu)
                loc_d=loc_cantidate(1);
            else
                diff_matriu=abs(bpm_matriu-bpm_cantidate.');
                [ind_m,ind_c]=find(diff_matriu<10);
    
                loc_d=loc_cantidate(ind_c);
    
                if length(loc_d)>1
                    bpm_estim_d=loc_d*(1/(length(sig_fft)*T_frame))*60;
                    bpm_estim_d(find(bpm_estim_d>100))=[];
                    loc_d=loc_d(1);
                elseif isempty(loc_d)
                    if bpm_matriu(1)<100
                        loc_d=(bpm_matriu(1)/60)/(1/(length(sig_fft)*T_frame));
                    else
                        loc_d=loc_cantidate(1);
                    end
                end
            end
        else
            diff_cantidate=abs(bpm_cantidate-(60/(loc_arr*T_frame)));
            loc_d=loc_cantidate(find(diff_cantidate==min(diff_cantidate)));
        end
    end
end
end