function [retCode, boardHandle] = AlazarSleepDevice(boardHandle, sleepState)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSleepDevice', boardHandle, sleepState);
