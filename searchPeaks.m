function [LocFinder,x] = searchPeaks(Spec_abs_dB,Sampling,decimationOfBandwidth)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
searchInMeasure = 300; % CHANGED

LocFinder = cell(1, decimationOfBandwidth);

%IMPORTANT Sampling.f remains the same BUT OTHERS???
for k=1:decimationOfBandwidth
    [LocFinder{k}.pks,LocFinder{k}.locs] = findpeaks(Spec_abs_dB{k}(:,searchInMeasure),Sampling.f,'SortStr','descend','MinPeakDistance',5,'MinPeakHeight',-20,'NPeaks',5);
    LocFinder{k}.locs_positive = LocFinder{k}.locs(LocFinder{k}.locs>0 & LocFinder{k}.locs<=5e4);
    text(LocFinder{k}.locs+.02,LocFinder{k}.pks,num2str((1:numel(LocFinder{k}.pks))')) %???
end
x=5;
end