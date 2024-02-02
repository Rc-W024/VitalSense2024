# VitalSense2024
Vital sensing based on 120 GHz FMCW RSoC for biometrics and situation awareness.

Paper: On the Feasibility of Vital Sensing with Radar System-on-Chip for Novel Modality Biometrics (*In Preparation*)

## Radar System-on-Chip (RSoC)
### Terahertz FMCW Radar by CommSensLab-UPC
<p>
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/3beb8c87-0072-419f-b07b-6c7b5c18d968" width=300 />
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/ca2eb4d2-b0ea-477c-aa1b-ac01321f8663" width=320 />
</p>

### Files for hardware...
**Radar measurement:** `AlazarTech`

ATS-SDK is a Windows and Linux compatible software development kit created by *AlazarTech* to allow users to programmatically control and acquire data from its line of waveform digitizers, which fully supports for C/C++ and C# (Visual Studio or GCC), MATLAB, LabVIEW and Python environments. In this case, we complete the project based on **MATLAB**.

## Algorithm
**MAIN FILE:** [`main_wu.m`](https://github.com/Rc-W024/VitalSense2024/blob/main/main_wu.m)

### 1. Signal Preprocessing
- Vital signal obtaintion with phase unwrapping
- Signal separation: respiratory signal $s_{b}$ extraction with FIR linear-phase filter; cardiac signal -> $s_{h}=s_{vital}−s_{b}$

### 2. Real-time Repetitive Waveform Adaptive Matched Filter (RWAMF)
- **Phase A:** Iterative pulse period estimation
- **Phase B:** Pulse waveform reconstruction -> AMF
- **Phase C:** Final heart waveform parameters extraction

### 3. Main Outcomes
- Pulse repetition interval, heartbeat rate, abnormalities detection
- Peaks and periods estimation, blood pressure waveform reconstruction

## Overall Result
![res_RW](https://github.com/Rc-W024/VitalSense2024/assets/97808991/a2a44f71-5296-4cbf-9087-9ff5fb01cbea)

![image](https://github.com/Rc-W024/VitalSense2024/assets/97808991/1929f887-c017-4c2f-9f9b-bc1a33455a5a)
