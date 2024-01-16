function [retCode, boardHandle, pBuffer] = AlazarDSPGetNextBuffer(boardHandle, pBuffer, bytesToCopy, timeout_ms)
[retCode, boardHandle, pBuffer] = calllib('ATSApi', 'AlazarDSPGetNextBuffer', boardHandle, pBuffer, bytesToCopy, timeout_ms);
