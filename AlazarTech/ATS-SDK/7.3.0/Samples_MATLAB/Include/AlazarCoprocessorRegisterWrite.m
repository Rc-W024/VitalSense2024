function [retCode, boardHandle] = AlazarCoprocessorRegisterWrite(boardHandle, offset, value)
[retCode, boardHandle] = calllib('ATSApi', 'AlazarCoprocessorRegisterWrite', boardHandle, offset, value);
