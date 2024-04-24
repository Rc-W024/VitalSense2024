# VitalSense2024 - Radio biometrics with RADAR
![](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=flat&color=BC4E99)
![](https://img.shields.io/github/license/Rc-W024/VitalSense2024.svg)

Vital signal processing and identification based on 120 GHz FMCW Radar System-on-Chip (RSoC) for biometrics and situation awareness.

Paper: On the Feasibility of Vital Sensing with Radar System-on-Chip for Novel Modality Biometrics (*In Preparation - Final internol revision*)

## RSoC for Wireless Sensing & Mobile Computing
### Terahertz Radar Sensor by CommSensLab-UPC
<p>
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/3beb8c87-0072-419f-b07b-6c7b5c18d968" width=300 />
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/ca2eb4d2-b0ea-477c-aa1b-ac01321f8663" width=320 />
</p>

| Parameter                             | Value                                                                   |
| :----------:                          | :---------------:                                                       |
| Center Frequency ($f_{0}$)            | 122.5 GHz                                                               |
| Wavelength ($\lambda$)                | $\frac{c}{f_{0}}=$ 0.0025 m                                             |
| Pulse Repetition Period ($T_{frame}$) | 3 ms                                                                    |
| Chirp Slope Time ($T_{m}$)            | 1.5 ms                                                                  |
| Chirp Slope Bandwidth ($\Delta f$)    | 1 GHz (in the [ISM band](https://en.wikipedia.org/wiki/ISM_radio_band)) |

FYI: [EuJRS](https://www.tandfonline.com/doi/abs/10.5721/EuJRS20164937), [IEEE TAP](https://ieeexplore.ieee.org/document/8586968)

### Files for hardware...
**Radar measurement:** `AlazarTech`

ATS-SDK is a Windows and Linux compatible software development kit created by *AlazarTech* to allow users to programmatically control and acquire data from its line of waveform digitizers, which fully supports for C/C++ and C# (Visual Studio or GCC), MATLAB, LabVIEW and Python environments. In this case, we complete the project based on **MATLAB**.

## Dataset
Vital Signals Database - *acquired by CommSensLab (Dept. of Signal Theory and Communications)* (Non-public)

### Sample data
Several sets of sample vital signal data in the `data` are used for testing, familiarization and studying of the algorithm.

Data file naming rules: "*SUBJECT* + *MEASUREMENT POSITION* + *STATE* + *with ECG* (optional) *.mat*"

## Intelligent Signal Processing Algorithm
**MAIN FILE:** [`main_wu`](https://github.com/Rc-W024/VitalSense2024/blob/main/main_wu.m)

⚠ *Be sure to check the parameter settings and read the relevant comments before running!* ⚠

### Achievements
Automated intelligent signal processing multiphase algorithm design to deliver for each monitored subject three complementary types of information:

- An adapted filter perfectly matched to the monitored subject radar cardiac pulse waveform, providing the best possible Signal to Noise Ratio and interference rejection.

- The repetitive radar blood pressure waveform estimation, which is not only an additional ideal biologicalcharacteristic for biometrics, but also an alternative to conventional invasive/contact sensors in determining the condition of the cardiovascular system.

- The robust detection and precise temporal alignment of the cardiac pulses allowing to accurately measure heart-rate and to detect anomalies, resulting in more precise biometric parameters.

- The acquired vital signals and characteristic parameters can be integrated with cryptographic technologies to generate secure keys for encrypted communications, thereby ensuring the safety and privacy of the data exchange process between the communicating parties. Moreover, it is feasible to study and develop radar-based identity authentication system suitable for security-sensitive scenarios such as surveillance of confidential areas to effectively preventing identity theft or session hijacking.

### Workflow
**1. Signal Preprocessing**
- Vital signal $s_{vital}$ obtaintion by phase unwrapping
- Signal separation: respiratory signal $s_{b}$ extraction with FIR linear-phase filter; cardiac signal -> $s_{h}=s_{vital}−s_{b}$

**2. Real-time Repetitive Waveform Adaptive Matched Filter (RWAMF)**
- **Phase A:** Iterative pulse period estimation <- $FFT$ -> $FilA$
- **Phase B:** Pulse waveform reconstruction -> $FilB$ -> **AMF**
- **Phase C:** Final heart waveform parameters extraction <- $FilC$

**3. Main Outcomes**
- Pulse repetition interval, heartbeat rate (bpm), abnormalities detection
- Peaks and periods estimation, blood pressure waveform reconstruction
- Extracted feature parameters could be studied for biometric authentication and encryption

## Overall Result
### Case 1: with oximeter
![resRW](https://github.com/Rc-W024/VitalSense2024/assets/97808991/a2a44f71-5296-4cbf-9087-9ff5fb01cbea)

![resText1](https://github.com/Rc-W024/VitalSense2024/assets/97808991/f34fafae-a686-434a-b56d-eab5f2407198)

### Case 2: with ECG signal
![resECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/be2ec882-2bf9-4d91-b165-e9b1a48230a1)

![resTextECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/11fc1da0-28bb-4e03-8b32-86662be440a2)

## FYI
### Citation
🚧 *Under Construction...* 🚧

### Similar project...
[**IEEE Spectrum** - Millimeter-wave radar device makes electrode-less cardiovascular health tech possible](https://spectrum.ieee.org/contactless-ecg)

Paper: [IEEE TMC](https://ieeexplore.ieee.org/document/9919401/)

News (In Chinese): [中国科学技术大学网络空间安全学院：中国科大实现非接触心电图实时监测](https://cybersec.ustc.edu.cn/2022/1201/c23831a582956/page.htm)
