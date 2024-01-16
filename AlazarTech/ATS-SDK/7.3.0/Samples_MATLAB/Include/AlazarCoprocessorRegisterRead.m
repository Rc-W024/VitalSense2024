function [retCode, boardHandle, pValue] = AlazarCoprocessorRegisterRead(boardHandle, offset, pValue)
[retCode, boardHandle, pValue] = calllib('ATSApi', 'AlazarCoprocessorRegisterRead', boardHandle, offset, pValue);
