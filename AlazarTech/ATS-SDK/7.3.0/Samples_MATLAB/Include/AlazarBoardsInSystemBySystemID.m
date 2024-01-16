function boardCount = AlazarBoardsInSystemBySystemID(systemId)
boardCount = calllib('ATSApi', 'AlazarBoardsInSystemBySystemID', systemId);
