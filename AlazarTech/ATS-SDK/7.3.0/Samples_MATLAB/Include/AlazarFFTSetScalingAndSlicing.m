function [retCode, dspHandle] = AlazarFFTSetScalingAndSlicing(dspHandle, slice_pos, loge_ampl_mult)
[retCode, dspHandle] = calllib('ATSApi', 'AlazarFFTSetScalingAndSlicing', dspHandle, slice_pos, loge_ampl_mult);
