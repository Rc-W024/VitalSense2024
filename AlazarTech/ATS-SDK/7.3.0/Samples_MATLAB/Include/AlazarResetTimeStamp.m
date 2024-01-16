function [retCode, boardHandle] = AlazarResetTimeStamp(boardHandle, option)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarResetTimeStamp', boardHandle, option);
