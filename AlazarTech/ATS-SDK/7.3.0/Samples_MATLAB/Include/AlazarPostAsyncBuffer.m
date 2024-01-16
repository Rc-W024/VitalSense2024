function [retCode, boardHandle, pBuffer] = AlazarPostAsyncBuffer(boardHandle, pBuffer, bufferLength)
[retCode, boardHandle, pBuffer] = calllib('ATSApi', 'AlazarPostAsyncBuffer', boardHandle, pBuffer, bufferLength);
