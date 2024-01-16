function [retCode, dspHandle, pBackgroundRecord] = AlazarFFTBackgroundSubtractionGetRecordS16(dspHandle, pBackgroundRecord, size_samples)
[retCode, dspHandle, pBackgroundRecord] = calllib('ATSApi', 'AlazarFFTBackgroundSubtractionGetRecordS16', dspHandle, pBackgroundRecord, size_samples);
