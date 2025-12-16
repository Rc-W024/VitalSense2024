<div align="center">
<img src="https://github.com/user-attachments/assets/e60cada1-b487-44fa-8247-cfc7b7e7df9e" alt="VitalSense2024"/>

# VitalSense - mmWave Radios-Based Biometric Sensing
[**Robust Biometric Information Sensing With mmWave Radar System-on-Chip**](https://doi.org/10.1109/TMC.2025.3640267)

![](https://skillicons.dev/icons?i=matlab)

![](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=flat-square&color=BC4E99)
![](https://img.shields.io/github/license/Rc-W024/VitalSense2024?style=flat-square)
![](https://img.shields.io/badge/GitHub-Rc--W024%2FVitalSense2024-24292F?logo=github&style=flat-square)
![](https://img.shields.io/github/stars/Rc-W024/VitalSense2024?logo=github&label=Stars&color=F2C94C&style=flat-square)

[**Ruochen Wu**](https://futur.upc.edu/32247005) <sup>✉</sup>
<img src="https://github.com/user-attachments/assets/cacf370a-b89f-454b-a7b8-55c6d49d3ce8" alt="Logo" height="15"/>
<img src="https://github.com/user-attachments/assets/42faadef-7999-4130-a4fc-84a467b37e95" alt="Logo" height="15"/> &nbsp; &nbsp;
[Laura Miro](https://futur.upc.edu/37088913)
<img src="https://github.com/user-attachments/assets/cacf370a-b89f-454b-a7b8-55c6d49d3ce8" alt="Logo" height="15"/>,
<img src="https://github.com/user-attachments/assets/f4d75b89-1ad1-4081-a95a-a768955ab762" alt="Logo" height="15"/>
<img src="https://github.com/user-attachments/assets/77f263af-ecbc-4806-a5b4-7b3c8a94fd11" alt="Logo" height="15"/> &nbsp; &nbsp;
[Albert Aguasca](https://futur.upc.edu/179522)
<img src="https://github.com/user-attachments/assets/cacf370a-b89f-454b-a7b8-55c6d49d3ce8" alt="Logo" height="15"/>
<img src="https://github.com/user-attachments/assets/42faadef-7999-4130-a4fc-84a467b37e95" alt="Logo" height="15"/>

[Montse Najar](https://futur.upc.edu/180118)
<img src="https://github.com/user-attachments/assets/cacf370a-b89f-454b-a7b8-55c6d49d3ce8" alt="Logo" height="15"/> &nbsp; &nbsp;
[Antoni Broquetas](https://futur.upc.edu/178234) <sup>✉</sup>
<img src="https://github.com/user-attachments/assets/cacf370a-b89f-454b-a7b8-55c6d49d3ce8" alt="Logo" height="15"/>
<img src="https://github.com/user-attachments/assets/42faadef-7999-4130-a4fc-84a467b37e95" alt="Logo" height="15"/>

<img width="400" alt="MICIU" src="https://github.com/user-attachments/assets/4d84b669-d7b8-443b-8c18-0168e14cce47"/>

English | [中文](README_CN.md) | [Español](README_ES.md)
</div>

---

Radio remote sensing and millimeter-wave (mmWave) sensing solution based on 120 GHz Frequency-Modulated Continuous Wave (FMCW) Radar System-on-Chip (RSoC) for smart healthcare monitoring, Internet of Medical Things (IoMT), and biometric extraction.

> [!NOTE]
> We are currently collaborating with the [**Hospital Universitari Germans Trias i Pujol (HUGTiP)**](https://hospitalgermanstrias.cat/) ([**Institut de Recerca Germans Trias i Pujol, IGTP**](https://www.germanstrias.org/)) of Barcelona to carry out an experimental validation of the developed mmWave Radar for Vital Sensing on patients of the Cardiology Service.

<details> <summary><b>Previous Collaborative Project (with <a href="https://www.sjdhospitalbarcelona.org/" target="_blank">Hospital Sant Joan de Déu Barcelona</a>) Introduction Video</b></summary>
  
https://github.com/Rc-W024/VitalSense2024/assets/97808991/8e9a442d-c9d5-4b0a-b27b-ba11a036f8c3

</details>

## RSoC for Wireless Sensing
### mmWave Radar Sensor Prototype
The used non-commercial RADAR has been conceived, designed and built in our laboratory (CommSensLab-UPC) specifically for the intended applications.

<p>
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/3beb8c87-0072-419f-b07b-6c7b5c18d968" width=300 />
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/ca2eb4d2-b0ea-477c-aa1b-ac01321f8663" width=320 />
</p>

| Parameter                                    | Value                                                                   |
| :----------:                                 | :---------------:                                                       |
| Center Frequency ($f_{0}$)                   | 122.5 GHz                                                               |
| Radar Bandwidth ($B$)                        | 1 GHz (in the [ISM band](https://en.wikipedia.org/wiki/ISM_radio_band)) |
| Antenna Beamwidth ($\theta_{\text{3dB}}$)    | $2^{\circ}$                                                             |
| Radar Range Resolution ($\Delta r$)          | $\frac{c}{2B}=$ 150 mm                                                  |
| Wavelength ($\lambda$)                       | $\frac{c}{f_{0}}=$ 2.449 mm                                             |
| Pulse Repetition Period ($T_{\text{frame}}$) | 3 ms                                                                    |
| Chirp Slope Time ($T$)                       | 1.5 ms                                                                  |

> [!IMPORTANT]
> The radar bandwidth can be programmed up to 4 GHz. In our experimental setup, a radar bandwidth of 3 GHz was configured.

### Files for hardware...
**Radar measurement:** `AlazarTech`

ATS-SDK is a Windows and Linux compatible software development kit created by *AlazarTech* to allow users to programmatically control and acquire data from its line of waveform digitizers, which fully supports for C/C++ and C# (Visual Studio or GCC), MATLAB, LabVIEW and Python environments. In this case, we complete the project based on **MATLAB**.

## Dataset
Vital Signals Database - *acquired by CommSensLab (Dept. of Signal Theory and Communications)* (Internal experimental data)

> [!TIP]
> 📣 A new radar vital signals [DATASET](https://github.com/Rc-W024/VS_DATASET) comprising 24 healthy subjects has been published! 🎉

### Sample data
Several sets of sample vital signal data in the `data` are used for testing, familiarization and studying of the algorithm.

Data file naming rules: "*SUBJECT* + *MEASUREMENT POSITION* + *STATE* + *with ECG* (optional) *.mat*"

## Signal Processing Algorithm
**MAIN FILE:** [`main`](https://github.com/Rc-W024/VitalSense2024/blob/main/main.m)

> [!IMPORTANT]
> *Be sure to check the parameter settings and read the relevant comments before running!*

### Achievements
Vital sensing radar with intelligent adaptive multi-phase signal processing chain to deliver for each monitored subject three complementary types of information:

- An adapted filter perfectly matched to the monitored subject radar cardiac pulse waveform, providing the best possible Signal to Noise Ratio and interference rejection.

- The repetitive radar blood pressure waveform estimation, which is not only an additional biologicalcharacteristic for biometrics, but also an alternative to conventional invasive/contact sensors in determining the condition of the cardiovascular system.

- The robust detection and precise temporal alignment of the cardiac pulses allowing to accurately measure heart-rate and to detect anomalies, resulting in more precise biometric parameters.

- In the future, the acquired biometric information can be integrated with cryptographic technologies to generate secure keys for encrypted communications, thereby ensuring the safety and privacy of the data exchange process between the communicating parties. Moreover, it is feasible to study and develop radar-based identity authentication system suitable for security-sensitive scenarios such as surveillance of confidential areas.

---

### Workflow
**1. Signal Preprocessing**
- Vital signal $s_{vital}$ obtaintion by phase unwrapping
- Signal separation: respiratory signal $s_{b}$ extraction with FIR linear-phase filter; cardiac signal -> $s_{h}=s_{vital}−s_{b}$

**2. Real-time Repetitive Waveform Adaptive Matched Filter (RWAMF)**
- **Phase A:** Iterative pulse period estimation <- $FFT$ -> $FilA$
- **Phase B:** Generic cardic signal filter & RWAMF -> $FilB$ <- $FilC$
- **Phase C:** Vital information extraction -> $bpm$, $s_{BP}$, ...

**3. Main Outcomes**
- Pulse repetition interval, heartbeat rate, abnormalities detection
- Peaks identification, Blood Pressure Waveform
- Respiratory monitoring
- Extracted vital feature parameters could be studied for biometric authentication and encryption

> [!WARNING]
> Spectrum-based HR estimation in complex signal environments remains a significant open challenge in the field. Please be aware that no single algorithm currently offers universal applicability across all scenarios. The performance of the algorithm heavily relies on the specific conditions during signal collection, especially antenna pointing. We are continuously researching solutions to improve this phase and welcome community feedback for further optimization.

## Phase Results
### Signal separation
- Extract breathing signal $s_{b}$ with FIR linear-phase filter
- Heartbeat signal -> $s_{h}=s_{vital}-s_{b}$

![separation](https://github.com/Rc-W024/VitalSense2024/assets/97808991/99f80104-2506-492c-bf97-6378139acfd9)

---

### RWAMF design
- Calculate the average waveform based on the extracted cardiac signal as the tmplate signal of the filter

![RWAMF](https://github.com/Rc-W024/VitalSense2024/assets/97808991/770a43d4-da7e-4ea4-8777-4c2f2db7d3a0)

---

### Cardiac pulse recognition
- Main function: [*findpeaks*](https://www.mathworks.com/help/signal/ref/findpeaks.html) in MATLAB

![recognition](https://github.com/Rc-W024/VitalSense2024/assets/97808991/c6ea274f-4217-4cae-b98d-9dc7fd058da4)

---

### Blood pressure waveform extraction
![BPW](https://github.com/user-attachments/assets/6348f9dc-ab2a-432a-b5db-986f3ebb9278)

## Overall Result
### Case 1: with oximeter
![resRW](https://github.com/Rc-W024/VitalSense2024/assets/97808991/a2a44f71-5296-4cbf-9087-9ff5fb01cbea)

![resText1](https://github.com/Rc-W024/VitalSense2024/assets/97808991/f34fafae-a686-434a-b56d-eab5f2407198)

---

### Case 2: with ECG signal
![resECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/be2ec882-2bf9-4d91-b165-e9b1a48230a1)

![resTextECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/11fc1da0-28bb-4e03-8b32-86662be440a2)

## FYI
### Citation
```bibtex
@ARTICLE{wu2025vs,
  author={Wu, Ruochen and Miro, Laura and Aguasca, Albert and Najar, Montse and Broquetas, Antoni},
  journal={IEEE Transactions on Mobile Computing}, 
  title={Robust Biometric Information Sensing With Mmwave Radar System-on-Chip}, 
  year={2025},
  volume={},
  number={},
  pages={1-15},
  doi={10.1109/TMC.2025.3640267}
}
```

---

### Contribution
<div align="center">

⭐️ **Thank you for your interest!** ⭐️

[![](https://img.shields.io/badge/Issues-Report_Bug-red?style=for-the-badge&logo=github)](https://github.com/Rc-W024/VitalSense2024/issues)

[![](https://img.shields.io/github/stars/Rc-W024/VitalSense2024?style=social)](https://github.com/Rc-W024/VitalSense2024/stargazers)
[![](https://img.shields.io/github/forks/Rc-W024/VitalSense2024?style=social)](https://github.com/Rc-W024/VitalSense2024/network/members)

</div>
