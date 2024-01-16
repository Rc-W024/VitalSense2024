function [retCode, boardHandle] = AlazarSetExternalTrigger(boardHandle, couplingId, rangeId)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetExternalTrigger', boardHandle, couplingId, rangeId);
