function [retCode, boardHandle, pBuffer] = AlazarWaitAsyncBufferComplete(boardHandle, pBuffer, timeout_ms)
[retCode, boardHandle, pBuffer] = calllib('ATSApi', 'AlazarWaitAsyncBufferComplete', boardHandle, pBuffer, timeout_ms);
