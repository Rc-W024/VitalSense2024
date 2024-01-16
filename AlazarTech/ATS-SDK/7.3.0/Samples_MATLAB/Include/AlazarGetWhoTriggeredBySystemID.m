function value = AlazarGetWhoTriggeredBySystemID(systemId, boardId, recordNumber)
value = calllib('ATSApi', 'AlazarGetWhoTriggeredBySystemID', systemId, boardId, recordNumber);
