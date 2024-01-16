function [retCode, boardHandle, pBuffer] = AlazarRead(boardHandle, channelId, pBuffer, elementSize, record, transferOffset, transferLength)
[retCode, boardHandle, pBuffer] = calllib('ATSApi', 'AlazarRead', boardHandle, channelId, pBuffer, elementSize, record, transferOffset, transferLength);
