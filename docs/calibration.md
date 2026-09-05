# ADC calibration - Module 14

The application uses a linear conversion from raw ADC counts to the voltage at the ADC input:

```text
V_adc = 0.00042690008827948 × ADC + 0.0984245182816639
```

The laboratory analogue input used a divider factor of `1 / 29.3`, with `ADC_REF = 1.0 V`. The voltage displayed by the micro-oscilloscope is therefore:

```text
V_in = (V_adc - 1.0) / (1 / 29.3)
```

## Bench measurement summary

Each point used 10,000 ADC samples.

| Nominal input (V) | Multimeter input (V) | Mean ADC count | ADC min | ADC max |
| ---: | ---: | ---: | ---: | ---: |
| -10 | -10.830 | 1247.58 | 1222 | 1275 |
| -5 | -5.430 | 1676.91 | 1650 | 1712 |
| 0 | 0.001 | 2111.35 | 2087 | 2139 |
| 5 | 5.433 | 2544.23 | 2510 | 2573 |
| 10 | 10.840 | 2980.61 | 2945 | 3011 |

These coefficients apply to **laboratory Module 14** and its measured analogue input arrangement only. They are not a universal ESP32 calibration and must be derived again for a different device or front end.
