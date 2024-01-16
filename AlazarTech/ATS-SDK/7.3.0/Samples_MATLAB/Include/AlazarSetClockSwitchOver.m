function [retCode, boardHandle] = AlazarSetClockSwitchOver(boardHandle, mode, dummyClockOnTime_ns)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarSetClockSwitchOver', boardHandle, mode, dummyClockOnTime_ns, 0);
