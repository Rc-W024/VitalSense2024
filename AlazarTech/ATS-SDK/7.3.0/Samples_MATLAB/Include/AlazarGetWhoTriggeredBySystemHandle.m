function [value, boardHandle] = AlazarGetWhoTriggeredBySystemHandle(boardHandle, boardId, recordNumber)
[value, boardHandle] = calllib('ATSApi', 'AlazarGetWhoTriggeredBySystemHandle', boardHandle, boardId, recordNumber);
