function [retCode, pWindow] = AlazarDSPGenerateWindowFunction(windowType, pWindow, windowLength_samples, paddingLength_samples)
[retCode, pWindow] = calllib('ATSApi', 'AlazarDSPGenerateWindowFunction', windowType, pWindow, windowLength_samples, paddingLength_samples);
