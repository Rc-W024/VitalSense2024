<div align="center">
<img src="https://github.com/user-attachments/assets/e60cada1-b487-44fa-8247-cfc7b7e7df9e" alt="VitalSense2024"/>

# VitalSense - 毫米波无线电生物特征感知
[**Robust Biometric Information Sensing With mmWave Radar System-on-Chip**](https://doi.org/10.1109/TMC.2025.3640267)

![](https://skillicons.dev/icons?i=matlab) &nbsp; &nbsp; &nbsp;
[![](https://github.com/user-attachments/assets/6698ee9e-baaf-4a71-a6d4-0b8a85f8f42c)](https://hdl.handle.net/2117/450720)

![](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=flat-square&color=BC4E99)
![](https://img.shields.io/github/license/Rc-W024/VitalSense2024?style=flat-square)
![](https://img.shields.io/badge/GitHub-Rc--W024%2FVitalSense2024-24292F?logo=github&style=flat-square)
![](https://img.shields.io/github/stars/Rc-W024/VitalSense2024?logo=github&label=Stars&color=F2C94C&style=flat-square)

[**Ruochen Wu**](https://futur.upc.edu/32247005) <sup>✉</sup>
<img src="https://github.com/user-attachments/assets/cacf370a-b89f-454b-a7b8-55c6d49d3ce8" alt="UPC" height="15"/>
<img src="https://github.com/user-attachments/assets/42faadef-7999-4130-a4fc-84a467b37e95" alt="CommSensLab" height="15"/> &nbsp; &nbsp;
[Laura Miro](https://futur.upc.edu/37088913)
<img src="https://github.com/user-attachments/assets/cacf370a-b89f-454b-a7b8-55c6d49d3ce8" alt="UPC" height="15"/>,
<img src="https://github.com/user-attachments/assets/f4d75b89-1ad1-4081-a95a-a768955ab762" alt="HUGTiP" height="15"/>
<img src="https://www.germanstrias.org/media/img/igtp-logo-cap-es.svg" alt="IGTP" height="15"/> &nbsp; &nbsp;
[Albert Aguasca](https://futur.upc.edu/179522)
<img src="https://github.com/user-attachments/assets/cacf370a-b89f-454b-a7b8-55c6d49d3ce8" alt="UPC" height="15"/>
<img src="https://github.com/user-attachments/assets/42faadef-7999-4130-a4fc-84a467b37e95" alt="CommSensLab" height="15"/>

[Montse Najar](https://futur.upc.edu/180118)
<img src="https://github.com/user-attachments/assets/cacf370a-b89f-454b-a7b8-55c6d49d3ce8" alt="UPC" height="15"/>
<img src="https://github.com/user-attachments/assets/37327f0d-9aaf-4dbf-b161-d12715e94521" alt="SPCOM" height="15"/> &nbsp; &nbsp;
[Antoni Broquetas](https://futur.upc.edu/178234) <sup>✉</sup>
<img src="https://github.com/user-attachments/assets/cacf370a-b89f-454b-a7b8-55c6d49d3ce8" alt="UPC" height="15"/>
<img src="https://github.com/user-attachments/assets/42faadef-7999-4130-a4fc-84a467b37e95" alt="CommSensLab" height="15"/>

<img width="400" alt="MICIU" src="https://github.com/user-attachments/assets/4d84b669-d7b8-443b-8c18-0168e14cce47"/>

[English](README.md) | 中文 | [Español](README_ES.md)
</div>

---

用于智慧医学监测、医疗物联网（IoMT）和生物特征提取的120 GHz调频连续波（FMCW）片上雷达（RSoC）无线电遥感与毫米波感知解决方案。

> [!NOTE]
> 我们目前正在与巴塞罗那[**Hospital Universitari Germans Trias i Pujol (HUGTiP)**](https://hospitalgermanstrias.cat/web/guest/home) ([**Institut de Recerca Germans Trias i Pujol, IGTP**](https://www.germanstrias.org/en/)) 开展合作研究，针对心脏病科患者进行所开发用于生命感知的毫米波雷达的实验验证。

<details> <summary><b>前序合作项目（与<a href="https://www.sjdhospitalbarcelona.org/zh" target="_blank">SJD巴塞罗那儿童医院</a>）介绍短片</b></summary>
  
https://github.com/Rc-W024/VitalSense2024/assets/97808991/8e9a442d-c9d5-4b0a-b27b-ba11a036f8c3

</details>

## 基于RSoC的无线感知
### 毫米波雷达传感器原型
所使用的非商业雷达为在我实验室（CommSensLab-UPC）中构思、设计和制造的，专用于有关预期应用。

<p>
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/3beb8c87-0072-419f-b07b-6c7b5c18d968" width=300 />
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/ca2eb4d2-b0ea-477c-aa1b-ac01321f8663" width=320 />
</p>

| 参数                               | 数值                                                                              |
| :----------:                       | :---------------:                                                                 |
| 中心频率 $f_{0}$                   | 122.5 GHz                                                                         |
| 雷达带宽 $B$                       | 1 GHz（在[ISM频段](https://baike.baidu.com/item/ISM%E9%A2%91%E6%AE%B5/2114556)内）|
| 天线波束宽度 $\theta_{\text{3dB}}$ | $2^{\circ}$                                                                       |
| 雷达距离分辨率 $\Delta r$          | $\frac{c}{2B}=$ 150 mm                                                            |
| 波长 $\lambda$                     | $\frac{c}{f_{0}}=$ 2.449 mm                                                       |
| 脉冲重复周期 $T_{\text{frame}}$    | 3 ms                                                                              |
| 线性调频斜坡时间 $T$               | 1.5 ms                                                                            |

> [!IMPORTANT]
> 雷达带宽可编程扩展至4 GHz。在我们的实验中，雷达带宽配置为3 GHz。

### 硬件文件...
**雷达测量任务：** `AlazarTech`

ATS-SDK是*AlazarTech*创建的兼容Windows和Linux系统的软件开发套件，允许用户以编程方式控制其波形数字化仪并采集数据。其完全支持C/C++和C#（Visual Studio或GCC）、MATLAB、LabVIEW和Python环境。在本项目中，我们全程基于**MATLAB**开发并完成了任务。

## 数据集
生命信号数据库 - *由CommSensLab（信号理论与通信系）采集和管理* （内部实验数据）

> [!TIP]
> 📣 一个包含24名健康受试者的全新雷达生命信号[数据集](https://github.com/Rc-W024/VS_DATASET)现已上线！🎉

### 样例数据
`data`中包含了几组样本生命信号数据，用于算法的测试、熟悉和学习。

数据文件命名规则：“*受试者* + *测量部位* + *生理状态* + *ECG参考信号*（可选）*.mat*”

## 信号处理算法
**主文件：** [`main`](https://github.com/Rc-W024/VitalSense2024/blob/main/main.m)

> [!IMPORTANT]
> *运行前请务必检查参数设置并阅读相关注释！*

### 算法成就
生命感知雷达智能自适应多相信号处理链设计，可为每个监测对象提供三种互补类型的信息：

- 优化并改进的滤波器与监测对象雷达心脏脉冲波形实现完美匹配，提供最佳的信噪比和干扰抑制。

- 重复雷达血压波形估计。不仅是生物识别的额外理想生物特征，也是传统侵入式/接触式传感器确定心血管系统状况的替代方案。

- 心脏脉冲的稳健检测和精确时间对准，能够准确测量心率并检测异常，从而获得更精确的生物特征参数。

- 开发的创新“白盒”技术取代了需大量数据训练的AI黑盒模型，实现了隐私保护的无线感知。这一突破能够安全可靠地进行片上生物特征信息获取，赋能医疗物联网中下一代机密边缘计算。

---

### 算法流程
**1、信号预处理**
- 通过相位展开获取生命信号$s_{vital}$
- 信号分离：使用有限脉冲响应（FIR）滤波器提取呼吸信号$s_{b}$；心跳信号 -> $s_{h}=s_{vital}−s_{b}$

**2、实时重复波形自适应匹配滤波（RWAMF）**
- **Phase A:** 迭代脉冲周期估计 <- $FFT$ -> $FilA$
- **Phase B:** 通用心动信号滤波器 & RWAMF -> $FilB$ <- $FilC$
- **Phase C:** 生命信息提取 -> $bpm$， $s_{BP}$，......

**3、主要成果**
- 脉冲重复间隔，心率，异常检测
- 心跳峰识别，血压波形
- 呼吸监测
- 提取的生命特征参数可用于生物特征认证和加密研究

> [!WARNING]
> 在复杂信号条件下，基于频谱的心率估计仍是该领域面临的一项重大挑战。请注意： 目前尚无任何单一算法能够通用于所有场景。该算法的性能在很大程度上取决于信号采集期间的具体条件，尤其是天线的指向。我们正在持续研究解决方案以改进这一环节，并欢迎社区反馈以便进一步优化。

## 阶段成果
### 信号分离
- 利用有限长单位冲激响应（FIR）线性相位滤波器提取呼吸信号 $s_{b}$
- 心跳信号 -> $s_{h}=s_{vital}-s_{b}$

![separation](https://github.com/Rc-W024/VitalSense2024/assets/97808991/99f80104-2506-492c-bf97-6378139acfd9)

---

### RWAMF设计
- 根据提取的心脏信号计算平均波形作为滤波器的模板信号

![RWAMF](https://github.com/Rc-W024/VitalSense2024/assets/97808991/770a43d4-da7e-4ea4-8777-4c2f2db7d3a0)

---

### 心动脉冲识别
- 主要函数：MATLAB中所提供的[*findpeaks*](https://www.mathworks.com/help/signal/ref/findpeaks.html)

![recognition](https://github.com/Rc-W024/VitalSense2024/assets/97808991/c6ea274f-4217-4cae-b98d-9dc7fd058da4)

---

### 血压波形复现
![BPW](https://github.com/user-attachments/assets/33a864c5-07d2-4cc0-b2d7-383cf9f3cea6)

## 总体结果
### 案例1：血氧计
![resRW](https://github.com/Rc-W024/VitalSense2024/assets/97808991/a2a44f71-5296-4cbf-9087-9ff5fb01cbea)

![resText1](https://github.com/Rc-W024/VitalSense2024/assets/97808991/f34fafae-a686-434a-b56d-eab5f2407198)

---

### 案例2：ECG信号
![resECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/be2ec882-2bf9-4d91-b165-e9b1a48230a1)

![resTextECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/11fc1da0-28bb-4e03-8b32-86662be440a2)

## 参考信息
### 引用
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

### 贡献
<div align="center">

⭐️ **感谢您的关注！** ⭐️

[![](https://img.shields.io/badge/Issues-报告Bug-red?style=for-the-badge&logo=github)](https://github.com/Rc-W024/VitalSense2024/issues)

[![](https://img.shields.io/github/stars/Rc-W024/VitalSense2024?style=social)](https://github.com/Rc-W024/VitalSense2024/stargazers)
[![](https://img.shields.io/github/forks/Rc-W024/VitalSense2024?style=social)](https://github.com/Rc-W024/VitalSense2024/network/members)

</div>
