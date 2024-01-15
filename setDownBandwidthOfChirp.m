function beatingTone_timeNEW_interpol = setDownBandwidthOfChirp(beatingTone_time,decimationOfBandwidth)
%Sets down the transmitted bandwidth artificially for comparison
%   Detailed explanation goes here

[sizeTime,sizeOverChirps] = size(beatingTone_time);
beatingTone_timeNEW = cell(1, decimationOfBandwidth);
for k=1:decimationOfBandwidth
    beatingTone_timeNEW{k} = zeros(round(sizeTime/decimationOfBandwidth),sizeOverChirps);
    beatingTone_timeNEW{k} = beatingTone_time(((k-1)*sizeTime/decimationOfBandwidth +1):(k*sizeTime/decimationOfBandwidth),1:sizeOverChirps);
end

samples = 1:(sizeTime/decimationOfBandwidth);
samplesInterp = 0:(1/decimationOfBandwidth):(sizeTime/decimationOfBandwidth);
samplesInterp(1)=[];
beatingTone_timeNEW_interpol = cell(1, decimationOfBandwidth);
for k=1:decimationOfBandwidth
    beatingTone_timeNEW_interpol{k} = zeros(sizeTime,sizeOverChirps);
    for l=1:sizeOverChirps
        beatingTone_timeNEW_interpol{k}(:,l) = interp1(samples,beatingTone_timeNEW{k}(:,l),samplesInterp);
    end
    beatingTone_timeNEW_interpol{k}(1,:)=0;
end
clear beatingTone_timeNew;


end