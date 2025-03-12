function loc_d=HRestim(T_frame,SIG0,sig_fclean_cut,sig_fft,amp_fft,loc_fft)
if length(loc_fft)==1
    loc_d=loc_fft;
elseif isempty(loc_fft)
    loc_d=find(abs(sig_fclean_cut)==max(abs(sig_fclean_cut)));
elseif length(loc_fft)==2
    % bpm verification
    for k=1:length(loc_fft)
        bpm_estim(k)=(loc_fft(k)*(1/(length(sig_fft)*T_frame)))*60;
    end
    
    % T determination
    loc_d=loc_fft(find(bpm_estim>40 & bpm_estim<130));

    if isempty(loc_d)
        loc_d=find(abs(sig_fclean_cut)==max(abs(sig_fclean_cut)));
        warning('MAYBE SOMETHING WENT WRONG, PLEASE CHECK THE DATA!')
    elseif length(loc_d)==2
        find_locd=[abs(bpm_estim(1)-40),abs(bpm_estim(2)-130)];
        loc_d=loc_fft(find(max(find_locd)));
    end
else
    tolerance=100;
    peak_found=false;
    for i=1:length(loc_fft)
        pks=loc_fft(i);
        % check if there is a peak close to 2*candidate peak
        if any(abs(loc_fft-2*pks)<tolerance)
            loc_cantidate(i)=pks;
            peak_found=true;
        end
    end

    if ~peak_found
        [~,max_idx]=max(amp_fft);
        loc_d=loc_fft(max_idx);
        bpm_estim=(loc_d*(1/(length(sig_fft)*T_frame)))*60;
        if bpm_estim>130
            loc_d=loc_fft(1);
        end
    else
        if length(loc_cantidate)==1
            bpm_estim=(loc_cantidate*(1/(length(sig_fft)*T_frame)))*60;
            if bpm_estim<44
                loc_d=find(abs(sig_fclean_cut)==max(abs(sig_fclean_cut)));
            else
                loc_d=loc_cantidate;
            end
        else
            loc_cantidate(loc_cantidate==0)=[];
            loc_d=loc_cantidate(find(SIG0(loc_cantidate)==max(SIG0(loc_cantidate))));
        end
    end
end
end
