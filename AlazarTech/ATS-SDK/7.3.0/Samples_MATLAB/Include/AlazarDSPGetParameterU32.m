function [retCode, dspHandle, pResult] = AlazarDSPGetParameterU32(dspHandle, parameter, pResult)
[retCode, dspHandle, pResult] = calllib('ATSApi', 'AlazarDSPGetParameterU32', dspHandle, parameter, pResult);
