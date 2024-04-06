# VitalSense2024 - Radio biometrics with RADAR
![](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=flat&color=BC4E99)
![](https://img.shields.io/github/license/Rc-W024/VitalSense2024.svg)

Vital signal processing and identification based on 120 GHz FMCW Radar System-on-Chip (RSoC) for biometrics and situation awareness.

Paper: On the Feasibility of Vital Sensing with Radar System-on-Chip for Novel Modality Biometrics (*In Preparation - Final internol revision*)

## RSoC
### Terahertz Radar Sensor by CommSensLab-UPC
<p>
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/3beb8c87-0072-419f-b07b-6c7b5c18d968" width=300 />
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/ca2eb4d2-b0ea-477c-aa1b-ac01321f8663" width=320 />
</p>

| Parameter                             | Value                        |
| :----------:                          | :---------------:            |
| Center Frequency ($f_{0}$)            | 122 GHz                      |
| Wavelength ($\lambda$)                | $\frac{c}{f_{0}}=$ 0.0025 m  |
| Pulse Repetition Period ($T_{frame}$) | 3 ms                         |
| Chirp Slope Time ($T_{m}$)            | 1.5 ms                       |
| Chirp Slope Bandwidth ($\Delta f$)    | 3 GHz                        |

FYI: [EuJRS](https://www.tandfonline.com/doi/abs/10.5721/EuJRS20164937), [IEEE TAP](https://ieeexplore.ieee.org/document/8586968)

### Files for hardware...
**Radar measurement:** `AlazarTech`

ATS-SDK is a Windows and Linux compatible software development kit created by *AlazarTech* to allow users to programmatically control and acquire data from its line of waveform digitizers, which fully supports for C/C++ and C# (Visual Studio or GCC), MATLAB, LabVIEW and Python environments. In this case, we complete the project based on **MATLAB**.

## Dataset
Vital Signals Database - *acquired by CommSensLab (Dept. of Signal Theory and Communications)* (Non-public)

### Sample data
Several sets of sample vital signal data in the `data` are used for testing, familiarization and studying of the algorithm.

Data file naming rules: "*SUBJECT* + *MEASUREMENT POSITION* + *STATE* + *with ECG* (optional) *.mat*"

🚧 *Under Construction...* 🚧

## Intelligent algorithm
**MAIN FILE:** [`main_wu`](https://github.com/Rc-W024/VitalSense2024/blob/main/main_wu.m)

Be sure to check the parameter settings and read the relevant comments before running!

### 1. Signal Preprocessing
- Vital signal $s_{vital}$ obtaintion by phase unwrapping
- Signal separation: respiratory signal $s_{b}$ extraction with FIR linear-phase filter; cardiac signal -> $s_{h}=s_{vital}−s_{b}$

### 2. Real-time Repetitive Waveform Adaptive Matched Filter (RWAMF)
- **Phase A:** Iterative pulse period estimation <- $FFT$ -> $FilA$
- **Phase B:** Pulse waveform reconstruction -> $FilB$ -> **AMF**
- **Phase C:** Final heart waveform parameters extraction <- $FilC$

### 3. Main Outcomes
- Pulse repetition interval, heartbeat rate (bpm), abnormalities detection
- Peaks and periods estimation, blood pressure waveform reconstruction
- Extracted feature parameters could be studied for biometric authentication and encryption

## Overall Result
### Case 1:
![resRW](https://github.com/Rc-W024/VitalSense2024/assets/97808991/a2a44f71-5296-4cbf-9087-9ff5fb01cbea)

![resText1](https://github.com/Rc-W024/VitalSense2024/assets/97808991/f34fafae-a686-434a-b56d-eab5f2407198)

### Case 2: with ECG signal
![resECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/38c0dcd1-2393-4ff8-b9c5-1650c12c0ddf)

![resTextECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/11fc1da0-28bb-4e03-8b32-86662be440a2)

