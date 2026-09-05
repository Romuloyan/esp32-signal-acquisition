# Micro-oscilloscope experimental results

This page retains the technical visual evidence and complete calibration table from the Lab 3 report. It excludes only course handouts, library source supplied for the laboratory environment, raw files and material containing personal data.

## Simulator validation

The following captures show time-domain and DFT views for sine and square-wave inputs in the laboratory simulator.

![Simulator sine-wave time view](../assets/micro-oscilloscope/simulator/sine-time.png)
![Simulator sine-wave DFT view](../assets/micro-oscilloscope/simulator/sine-dft.png)
![Simulator square-wave time view](../assets/micro-oscilloscope/simulator/square-time.png)
![Simulator square-wave DFT view](../assets/micro-oscilloscope/simulator/square-dft.png)

## Before calibration

These four captures document the waveform and spectral views before the final ADC calibration was applied.

![Before calibration capture 1](../assets/micro-oscilloscope/before-calibration/capture-1.jpeg)
![Before calibration capture 2](../assets/micro-oscilloscope/before-calibration/capture-2.jpeg)
![Before calibration capture 3](../assets/micro-oscilloscope/before-calibration/capture-3.jpeg)
![Before calibration capture 4](../assets/micro-oscilloscope/before-calibration/capture-4.jpeg)

## Complete calibration record - Module 14

Each calibration point used 10,000 ADC samples. The regression uses the measured input voltage transformed by the laboratory input-divider factor, `V_adc = 1 + V_in × (1 / 29.3)`.

| Nominal input (V) | Multimeter input (V) | Mean ADC count | ADC min | ADC max | Sample count | Check | V_adc target (V) |
| ---: | ---: | ---: | ---: | ---: | ---: | :---: | ---: |
| -10 | -10.830 | 1247.58 | 1222 | 1275 | 10000 | OK | 0.63037542662116 |
| -5 | -5.430 | 1676.91 | 1650 | 1712 | 10000 | OK | 0.814675767918089 |
| 0 | 0.001 | 2111.35 | 2087 | 2139 | 10000 | OK | 1.00003412969283 |
| 5 | 5.433 | 2544.23 | 2510 | 2573 | 10000 | OK | 1.18542662116041 |
| 10 | 10.840 | 2980.61 | 2945 | 3011 | 10000 | OK | 1.36996587030717 |

![Linear regression from ADC mean to target ADC voltage](../assets/micro-oscilloscope/calibration/regression.png)

![Calibration run at -10.830 V](../assets/micro-oscilloscope/calibration/run-1.jpeg)
![Calibration run at -5.430 V](../assets/micro-oscilloscope/calibration/run-2.jpeg)
![Calibration run at 0.001 V](../assets/micro-oscilloscope/calibration/run-3.jpeg)
![Calibration run at 5.433 V](../assets/micro-oscilloscope/calibration/run-4.jpeg)
![Calibration run at 10.840 V](../assets/micro-oscilloscope/calibration/run-5.jpeg)

## Development components

This table preserves the component summary from the report. Only the application source belongs in this repository; the calibration utility and laboratory interface library remain excluded because they were not part of the portable portfolio application or were supplied for the course environment.

| File | Function |
| --- | --- |
| `main.py` | Main micro-oscilloscope application: acquisition, processing, visualisation and email export. |
| `main_calib.py` | Dedicated ADC-calibration utility that obtains mean, minimum and maximum values from repeated readings. |
| `T_Display.py` | Laboratory hardware-interface library: ADC, display, buttons and network communication. |

## Post-calibration captures

All retained post-calibration captures are included below, without selecting only the visually strongest examples. They show sine and square-wave acquisitions at different time and voltage scales.

![Post-calibration capture 1](../assets/micro-oscilloscope/post-calibration/capture-01.jpeg)
![Post-calibration capture 2](../assets/micro-oscilloscope/post-calibration/capture-02.jpeg)
![Post-calibration capture 3](../assets/micro-oscilloscope/post-calibration/capture-03.jpeg)
![Post-calibration capture 4](../assets/micro-oscilloscope/post-calibration/capture-04.jpeg)
![Post-calibration capture 5](../assets/micro-oscilloscope/post-calibration/capture-05.jpeg)
![Post-calibration capture 6](../assets/micro-oscilloscope/post-calibration/capture-06.jpeg)
![Post-calibration capture 7](../assets/micro-oscilloscope/post-calibration/capture-07.jpeg)
![Post-calibration capture 8](../assets/micro-oscilloscope/post-calibration/capture-08.jpeg)
![Post-calibration capture 9](../assets/micro-oscilloscope/post-calibration/capture-09.jpeg)
![Post-calibration capture 10](../assets/micro-oscilloscope/post-calibration/capture-10.jpeg)
![Post-calibration capture 11](../assets/micro-oscilloscope/post-calibration/capture-11.jpeg)
![Post-calibration capture 12](../assets/micro-oscilloscope/post-calibration/capture-12.jpeg)
![Post-calibration capture 13](../assets/micro-oscilloscope/post-calibration/capture-13.jpeg)
![Post-calibration capture 14](../assets/micro-oscilloscope/post-calibration/capture-14.jpeg)
![Post-calibration capture 15](../assets/micro-oscilloscope/post-calibration/capture-15.jpeg)
![Post-calibration capture 16](../assets/micro-oscilloscope/post-calibration/capture-16.jpeg)
![Post-calibration capture 17](../assets/micro-oscilloscope/post-calibration/capture-17.jpeg)
![Post-calibration capture 18](../assets/micro-oscilloscope/post-calibration/capture-18.jpeg)
![Post-calibration capture 19](../assets/micro-oscilloscope/post-calibration/capture-19.jpeg)
