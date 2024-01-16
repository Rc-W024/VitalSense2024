function [retCode, boardHandle, pValue] = AlazarGetParameter(boardHandle, channel, parameter, pValue)
[retCode, boardHandle, pValue] = calllib('ATSApi', 'AlazarGetParameter', boardHandle, channel, parameter, pValue);
