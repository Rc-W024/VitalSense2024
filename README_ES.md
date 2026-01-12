<div align="center">
<img src="https://github.com/user-attachments/assets/e60cada1-b487-44fa-8247-cfc7b7e7df9e" alt="VitalSense2024"/>

# VitalSense - Detección Biométrica Basada en Radios de Onda Milimétrica
[**Robust Biometric Information Sensing With mmWave Radar System-on-Chip**](https://doi.org/10.1109/TMC.2025.3640267) *(Awaiting proof version)*

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

[English](README.md) | [中文](README_CN.md) | Español
</div>

---

Solución de teledetección por radar y detección de mmWave basada en un Sistema en Chip de Radar (RSoC) de Onda Continua Modulada en Frecuencia (FMCW) de 120 GHz para la monitorización sanitaria inteligente, el Internet de las Cosas Médicas (IoMT) y la extracción biométrica.

> [!NOTE]
> Actualmente estamos colaborando con el [**Hospital Universitari Germans Trias i Pujol (HUGTiP)**](https://hospitalgermanstrias.cat/) ([**Institut de Recerca Germans Trias i Pujol, IGTP**](https://www.germanstrias.org/)) de Barcelona para llevar a cabo una validación experimental del Radar mmWave desarrollado para la Detección de Signos Vitales en pacientes del Servicio de Cardiología.

<details> <summary><b>Vídeo de introducción del proyecto colaborativo anterior (con el <a href="https://www.sjdhospitalbarcelona.org/" target="_blank">Hospital Sant Joan de Déu Barcelona</a>)</b></summary>
  
https://github.com/Rc-W024/VitalSense2024/assets/97808991/8e9a442d-c9d5-4b0a-b27b-ba11a036f8c3

</details>

## RSoC para Detección Inalámbrica
### Prototipo de sensor de radar mmWave
El radar no comercial utilizado ha sido concebido, diseñado y construido en nuestro laboratorio (CommSensLab-UPC) específicamente para las aplicaciones previstas.

<p>
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/3beb8c87-0072-419f-b07b-6c7b5c18d968" width=300 />
<img src="https://github.com/Rc-W024/VitalSense2024/assets/97808991/ca2eb4d2-b0ea-477c-aa1b-ac01321f8663" width=320 />
</p>

| Parámetro                                           | Valor                                                                |
| :----------:                                        | :---------------:                                                    |
| Frecuencia Central ($f_{0}$)                        | 122.5 GHz                                                            |
| Ancho de Banda de Radar ($B$)                       | 1 GHz (en las [bandas ISM](https://es.wikipedia.org/wiki/Banda_ISM)) |
| Ancho de Haz de la Antena ($\theta_{\text{3dB}}$)   | $2^{\circ}$                                                          |
| Resolución de Alcance de Radar ($\Delta r$)         | $\frac{c}{2B}=$ 150 mm                                               |
| Longitud de Onda ($\lambda$)                        | $\frac{c}{f_{0}}=$ 2.449 mm                                          |
| Período de Repetición de Pulso ($T_{\text{frame}}$) | 3 ms                                                                 |
| Tiempo de la Pendiente de Frecuencia ($T$)          | 1.5 ms                                                               |

> [!IMPORTANT]
> El ancho de banda del radar puede programarse hasta 4 GHz. En nuestra configuración experimental, se ajustó un ancho de banda del radar de 3 GHz.

### Archivos para hardware...
**Medición por radar:** `AlazarTech`

ATS-SDK es un kit de desarrollo de software compatible con Windows y Linux, creado por *AlazarTech* para permitir a los usuarios el control programático y la adquisición de datos de su línea de digitalizadores de forma de onda. Este kit ofrece soporte completo para los entornos C/C++ y C# (Visual Studio o GCC), MATLAB, LabVIEW y Python. En este caso, completamos el proyecto basándonos en **MATLAB**.

## Conjunto de datos
Base de Datos de Señales Vitales - *adquiridos por CommSensLab (Depto. de Teoría de la Señal y Comunicaciones)* (Datos experimentales internos)

> [!TIP]
> 📣 ¡Se ha publicado un nuevo [CONJUNTO DE DATOS](https://github.com/Rc-W024/VS_DATASET) de señales vitales de radar que comprende 24 sujetos sanos! 🎉

### Datos de ejemplo
Varios datos de señales vitales de ejemplo en `data` se utilizan para la prueba, la familiarización y el estudio del algoritmo.

Reglas de nomenclatura de archivos de datos: "*SUJETO* + *POSICIÓN DE MEDICIÓN* + *ESTADO* + *con ECG* (opcional) *.mat*"

## Algoritmo de Procesamiento de Señales
**FICHERO PRINCIPAL:** [`main`](https://github.com/Rc-W024/VitalSense2024/blob/main/main.m)

> [!IMPORTANT]
> *¡Asegúrese de verificar la configuración de los parámetros y leer los comentarios pertinentes antes de la ejecución!*

### Avances
Radar de detección de constantes vitales con cadena de procesamiento de señales multifase adaptativa inteligente para proporcionar, a cada sujeto monitorizado, tres tipos de información complementaria:

- Un filtro adaptado perfectamente ajustado a la forma de onda del pulso cardíaco de radar del sujeto monitorizado, proporcionando la mejor relación señal/ruido e interferencia posible.

- La estimación repetitiva de la forma de onda de la presión arterial mediante radar, la cual no solo es una característica biológica adicional para la biometría, sino también una alternativa a los sensores invasivos/de contacto convencionales para determinar la condición del sistema cardiovascular.

- La detección robusta y la alineación temporal precisa de los pulsos cardíacos permiten medir con exactitud la frecuencia cardíaca y detectar anomalías, lo que se traduce en parámetros biométricos más precisos.

- En el futuro, la información biométrica adquirida podrá integrarse con tecnologías criptográficas para generar claves seguras destinadas a comunicaciones cifradas, asegurando así la seguridad y la privacidad del proceso de intercambio de datos entre las partes comunicantes. Además, es viable estudiar y desarrollar sistemas de autenticación de identidad basados en radar que sean adecuados para escenarios sensibles a la seguridad, como la vigilancia de áreas de acceso restringido.

---

### Flujo de trabajo
**1. Preprocesamiento de la Señal**
- Obtención de la señal vital $s_{vital}$ mediante desenvolvimiento de fase
- Separación de señales: extracción de la señal respiratoria $s_{b}$ mediante un filtro FIR de fase lineal; señal cardíaca -> $s_{h}=s_{vital}−s_{b}$

**2. Filtro Adaptativo Acoplado para Forma de Onda Repetitiva (RWAMF) en Tiempo Real**
- **Fase A:** Estimación l período de pulso iterativo <- $FFT$ -> $FilA$
- **Fase B:** Filtro genérico para señales cardíacas & RWAMF -> $FilB$ <- $FilC$
- **Fase C:** Extracción de información vital -> $bpm$, $s_{BP}$, ...

**3. Resultados Principales**
- Intervalo de repetición de pulso, tasa de frecuencia cardíaca, detección de anormalidades
- Identificación de picos, onda de presión arterial
- Monitorización de respiración
- Los parámetros de características vitales extraídos podrían estudiarse para la autenticación y el cifrado biométricos.

> [!WARNING]
> La estimación de la frecuencia cardíaca basada en el espectro en entornos de señal complejos sigue siendo un desafío abierto significativo en el campo. Es importante destacar que, en la actualidad, ningún algoritmo ofrece una aplicabilidad universal en todos los escenarios. El rendimiento del algoritmo depende en gran medida de las condiciones específicas durante la recopilación de la señal, especialmente de la orientación de la antena. Estamos investigando continuamente soluciones para mejorar esta fase y agradecemos los comentarios de la comunidad para optimizarla aún más.

## Resultados de la Fase
### Separación de señales
- Extraer la señal de respiración $s_{b}$ con un filtro FIR de fase lineal
- Señal cardíaca -> $s_{h}=s_{vital}-s_{b}$

![separation](https://github.com/Rc-W024/VitalSense2024/assets/97808991/99f80104-2506-492c-bf97-6378139acfd9)

---

### Diseño de RWAMF
- Calcular la forma de onda promedio basada en la señal cardíaca extraída para usarla como la señal de plantilla del filtro

![RWAMF](https://github.com/Rc-W024/VitalSense2024/assets/97808991/770a43d4-da7e-4ea4-8777-4c2f2db7d3a0)

---

### Reconocimiento de pulso cardíaco
- Función principal: [*findpeaks*](https://es.mathworks.com/help/signal/ref/findpeaks.html) en MATLAB

![recognition](https://github.com/Rc-W024/VitalSense2024/assets/97808991/c6ea274f-4217-4cae-b98d-9dc7fd058da4)

---

### Reproducción de la forma de onda de la presión arterial
![BPW](https://github.com/user-attachments/assets/33a864c5-07d2-4cc0-b2d7-383cf9f3cea6)

## Resultado General
### Caso 1: con oxímetro
![resRW](https://github.com/Rc-W024/VitalSense2024/assets/97808991/a2a44f71-5296-4cbf-9087-9ff5fb01cbea)

![resText1](https://github.com/Rc-W024/VitalSense2024/assets/97808991/f34fafae-a686-434a-b56d-eab5f2407198)

---

### Caso 2: con señales de ECG
![resECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/be2ec882-2bf9-4d91-b165-e9b1a48230a1)

![resTextECG](https://github.com/Rc-W024/VitalSense2024/assets/97808991/11fc1da0-28bb-4e03-8b32-86662be440a2)

## FYI
### Citación
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

### Contribución
<div align="center">

⭐️ **¡Gracias por su interés!** ⭐️

[![](https://img.shields.io/badge/Issues-Informar_Bug-red?style=for-the-badge&logo=github)](https://github.com/Rc-W024/VitalSense2024/issues)

[![](https://img.shields.io/github/stars/Rc-W024/VitalSense2024?style=social)](https://github.com/Rc-W024/VitalSense2024/stargazers)
[![](https://img.shields.io/github/forks/Rc-W024/VitalSense2024?style=social)](https://github.com/Rc-W024/VitalSense2024/network/members)

</div>
