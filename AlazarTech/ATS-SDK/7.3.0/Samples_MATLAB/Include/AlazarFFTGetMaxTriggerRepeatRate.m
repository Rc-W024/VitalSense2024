function [retCode, dspHandle, pMaxTriggerRepeatRate] = AlazarFFTGetMaxTriggerRepeatRate(dspHandle, fft_size, pMaxTriggerRepeatRate)
[retCode, dspHandle, pMaxTriggerRepeatRate] = calllib('ATSApi', 'AlazarFFTGetMaxTriggerRepeatRate', dspHandle, fft_size, pMaxTriggerRepeatRate);
