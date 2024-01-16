function [retCode, boardHandle, buffer] = AlazarDSPGetBuffer(boardHandle, buffer, timeout_ms)
[retCode, boardHandle, buffer] = calllib('ATSApi', 'AlazarDSPGetBuffer', boardHandle, buffer, timeout_ms);
