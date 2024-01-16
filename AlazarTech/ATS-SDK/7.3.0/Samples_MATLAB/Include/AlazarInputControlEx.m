function [retCode, boardHandle] = AlazarInputControlEx(boardHandle, channelId, couplingId, rangeId, impedanceId)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarInputControlEx', boardHandle, channelId, couplingId, rangeId, impedanceId);
