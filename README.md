# VitalSense2024
Vital signal processing based on 120 GHz FMCW Radar System-on-Chip (RSoC) for biometrics and situation awareness.

Paper: On the Feasibility of Vital Sensing with Radar System-on-Chip for Novel Modality Biometrics (*In Preparation*)

## RSoC
### Terahertz Radar Sensor by CommSensLab-UPC
<p>
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/3beb8c87-0072-419f-b07b-6c7b5c18d968" width=300 />
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/ca2eb4d2-b0ea-477c-aa1b-ac01321f8663" width=320 />
</p>

For more info: [Micrometric deformation imaging at W-Band with GBSAR](https://www.tandfonline.com/doi/abs/10.5721/EuJRS20164937), [Collimated Beam FMCW Radar for Vital Sign Patient Monitoring](https://ieeexplore.ieee.org/document/8586968)

### Files for hardware...
**Radar measurement:** `AlazarTech`

ATS-SDK is a Windows and Linux compatible software development kit created by *AlazarTech* to allow users to programmatically control and acquire data from its line of waveform digitizers, which fully supports for C/C++ and C# (Visual Studio or GCC), MATLAB, LabVIEW and Python environments. In this case, we complete the project based on **MATLAB**.

## Algorithm
**MAIN FILE:** [`main_wu.m`](https://github.com/Rc-W024/VitalSense2024/blob/main/main_wu.m) (**KEEP UPDATING...**)

Be sure to check the parameter settings and read the relevant comments before running!

**Available dataset:** Vital Signals Database - *acquired by CommSensLab (Dept. of Signal Theory and Communications)* (Non-public)

### 1. Signal Preprocessing
- Vital signal $s_{vital}$ obtaintion by phase unwrapping
- Signal separation: respiratory signal $s_{b}$ extraction with FIR linear-phase filter; cardiac signal -> $s_{h}=s_{vital}−s_{b}$

### 2. Real-time Repetitive Waveform Adaptive Matched Filter (RWAMF)
- **Phase A:** Iterative pulse period estimation
- **Phase B:** Pulse waveform reconstruction -> AMF
- **Phase C:** Final heart waveform parameters extraction

### 3. Main Outcomes
- Pulse repetition interval, heartbeat rate, abnormalities detection
- Peaks and periods estimation, blood pressure waveform reconstruction

## Overall Result
### Case 1:
![resRW](https://github.com/Rc-W024/VitalSense2024/assets/97808991/a2a44f71-5296-4cbf-9087-9ff5fb01cbea)

![resText1](https://github.com/Rc-W024/VitalSense2024/assets/97808991/f34fafae-a686-434a-b56d-eab5f2407198)

### Case 2: with ECG signal
![resECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/3c7970f4-7c09-45ab-824e-5003c21c4699)

![resText2](https://github.com/Rc-W024/VitalSense2024/assets/97808991/e021cc33-615b-4abf-9f9b-39b862ce1224)
