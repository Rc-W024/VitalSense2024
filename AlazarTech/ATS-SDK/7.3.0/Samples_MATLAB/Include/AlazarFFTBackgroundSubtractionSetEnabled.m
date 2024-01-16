function [retCode, dspHandle] = AlazarFFTBackgroundSubtractionSetEnabled(dspHandle, enabled)
[retCode, dspHandle] = calllib('ATSApi', 'AlazarFFTBackgroundSubtractionSetEnabled', dspHandle, enabled);
