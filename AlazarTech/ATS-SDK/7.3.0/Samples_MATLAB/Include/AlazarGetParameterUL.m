function [retCode, boardHandle, pValue] = AlazarGetParameterUL(boardHandle, channel, parameter, pValue)
[retCode, boardHandle, pValue] = calllib('ATSApi', 'AlazarGetParameterUL', boardHandle, channel, parameter, pValue);
