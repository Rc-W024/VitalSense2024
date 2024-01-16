function [retCode, boardHandle, buffer] = AlazarFreeBuffer(boardHandle, buffer)
[retCode, boardHandle, buffer] = calllib('ATSApi', 'AlazarFreeBufferU8', boardHandle, buffer);;
