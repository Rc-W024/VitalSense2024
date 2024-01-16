function [retCode, boardHandle] = AlazarConfigureAuxIO(boardHandle, mode, parameter)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarConfigureAuxIO', boardHandle, mode, parameter);
