function [retCode, boardHandle] = AlazarStartCapture(boardHandle)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarStartCapture', boardHandle);
