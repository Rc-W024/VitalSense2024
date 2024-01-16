function [retCode, dspHandle] = AlazarFFTBackgroundSubtractionSetRecordS16(dspHandle, pRecord, size_samples)
[retCode, dspHandle] = calllib('ATSApi', 'AlazarFFTBackgroundSubtractionSetRecordS16', dspHandle, pRecord, size_samples);
