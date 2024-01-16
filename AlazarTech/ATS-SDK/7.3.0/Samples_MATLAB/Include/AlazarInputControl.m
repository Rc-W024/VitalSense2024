function [retCode, boardHandle] = AlazarInputControl(boardHandle, channelId, couplingId, rangeId, impedanceId)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarInputControl', boardHandle, channelId, couplingId, rangeId, impedanceId);
