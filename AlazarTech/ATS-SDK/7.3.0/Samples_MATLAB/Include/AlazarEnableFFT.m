function [retCode, boardHandle] = AlazarEnableFFT(boardHandle, enable)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarEnableFFT', boardHandle, enable);
