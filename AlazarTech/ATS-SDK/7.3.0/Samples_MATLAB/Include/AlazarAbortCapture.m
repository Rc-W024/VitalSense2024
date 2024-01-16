function [retCode, boardHandle] = AlazarAbortCapture(boardHandle)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarAbortCapture', boardHandle);
