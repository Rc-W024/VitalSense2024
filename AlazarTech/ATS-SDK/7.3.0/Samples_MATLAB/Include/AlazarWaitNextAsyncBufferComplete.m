function [retCode, boardHandle, pBuffer] = AlazarWaitNextAsyncBufferComplete(boardHandle, pBuffer, bytesToCopy, timeout_ms)
[retCode, boardHandle, pBuffer] = calllib('ATSApi', 'AlazarWaitNextAsyncBufferComplete', boardHandle, pBuffer, bytesToCopy, timeout_ms);
