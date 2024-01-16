function [retCode, boardHandle, pModules, pNumModules] = AlazarDSPGetModules(boardHandle, numEntries, pModules, pNumModules)
[retCode, boardHandle, pModules, pNumModules] = calllib('ATSApi', 'AlazarDSPGetModules', boardHandle, numEntries, pModules, pNumModules);
