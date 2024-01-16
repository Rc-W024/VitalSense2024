function [retCode, boardHandle] = AlazarSetParameter(boardHandle, channelId, parameterId, value)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetParameterUL', boardHandle, channelId, parameterId, value);
