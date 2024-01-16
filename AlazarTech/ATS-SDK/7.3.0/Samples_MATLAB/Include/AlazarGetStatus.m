function [status, boardHandle] = AlazarGetStatus(boardHandle)
[status, boardHandle] = calllib('ATSApi', 'AlazarGetStatus', boardHandle);
