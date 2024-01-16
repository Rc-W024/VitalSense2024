function [retCode, boardHandle] = AlazarSetBWLimit(boardHandle, channelId, flag)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetBWLimit', boardHandle, channelId, flag);
