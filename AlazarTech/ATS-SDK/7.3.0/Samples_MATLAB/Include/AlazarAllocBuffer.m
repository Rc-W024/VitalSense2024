function [buffer, boardHandle] = AlazarAllocBuffer(boardHandle, size_bytes)
[buffer, boardHandle] = calllib('ATSApi', 'AlazarAllocBufferU8', boardHandle, size_bytes);
