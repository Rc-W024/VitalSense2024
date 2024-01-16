function handle = AlazarGetSystemHandle(systemId)
handle = calllib('ATSApi', 'AlazarGetSystemHandle', systemId);
