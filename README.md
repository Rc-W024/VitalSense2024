# VitalSense2024
Vital sensing based on 120 GHz FMCW RSoC for biometrics and situation awareness.

## Files for Hardware...
**Radar measurement:** `AlazarTech`

ATS-SDK is a Windows and Linux compatible software development kit created by *AlazarTech* to allow users to programmatically control and acquire data from its line of waveform digitizers, which fully supports for C/C++ and C# (Visual Studio or GCC), MATLAB, LabVIEW and Python environments. In this case, we complete the project based on **MATLAB**.

## Main File
**Processing algorithm:** [`main_wu.m`](https://github.com/Rc-W024/VitalSense2024/blob/main/main_wu.m)

### 1. Signal Preprocessing
- Vital signal obtaintion with phase unwrapping
- Signal separation: respiratory signal $s_{b}$ extraction with FIR linear-phase filter; cardiac signal -> $s_{h}=s_{vital}−s_{b}$

### 2. Real-time Repetitive Waveform Adaptive Matched Filter (RWAMF)
- **Phase A:** Iterative pulse period estimation
- **Phase B:** Pulse waveform reconstruction -> AMF
- **Phase C:** Final heart waveform parameters extraction

### 3. Main Outcomes
- Pulse repetition interval, Heartbeat rate, Detection of abnormalities
- Blood pressure waveform
