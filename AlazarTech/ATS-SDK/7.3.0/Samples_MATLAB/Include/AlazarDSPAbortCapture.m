function [retCode, boardHandle] = AlazarDSPAbortCapture(boardHandle)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarDSPAbortCapture', boardHandle);
