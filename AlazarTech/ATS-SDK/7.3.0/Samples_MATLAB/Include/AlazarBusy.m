function [busy, boardHandle] = AlazarBusy(boardHandle)
[busy, boardHandle] = calllib('ATSApi', 'AlazarBusy', boardHandle);
