function [triggered, boardHandle] = AlazarTriggered(boardHandle)
[triggered, boardHandle] = calllib('ATSApi', 'AlazarTriggered', boardHandle);
