import T_Display   # biblioteca principal do display, botões, ADC e email
import time        # pausas e controlo temporal
import math
import gc

DISPLAY_W = 240               # Dimensões do display e da grelha
DISPLAY_H = 135
TOP_H = 16
TOP_Y = DISPLAY_H - TOP_H

GRID_X = 0
GRID_Y = 0
GRID_W = DISPLAY_W
GRID_H = DISPLAY_H - TOP_H

V_SCALES = [1, 2, 5, 10]          # V/div na vista temporal
T_SCALES = [5, 10, 20, 50]        # ms/div na vista temporal
FV_SCALES = [0.5, 1, 2.5, 5]      # V/div na vista de Fourier
FH_SCALES = [240, 120, 60, 24]    # Hz/div na vista de Fourier

MODE_TIME = 0                     # modos de operação
MODE_FREQ = 1

# Valores de arranque pedidos no enunciado
v_scale_idx = 2   # 5 V/div
t_scale_idx = 1   # 10 ms/div
mode = MODE_TIME

# Optional email address used by button 12. Keep empty in source control.
MAIL_ADDRESS = ""

# =========================================================
# Calibration values measured on laboratory Module 14.
# Recalibrate whenever the module or analogue input circuit changes.
# Conversion model:
# v_adc = ADC_SLOPE * adc + ADC_OFFSET
# vin   = (v_adc - ADC_REF) / DIV_FACTOR
# =========================================================
ADC_SLOPE = 0.00042690008827948
ADC_OFFSET = 0.0984245182816639
ADC_REF = 1.0
DIV_FACTOR = 1 / 29.3

# Buffers da última aquisição
pontos_adc = [0] * 240
pontos_volt = [0.0] * 240
last_stats = {
    "vmax": 0.0,
    "vmin": 0.0,
    "vav": 0.0,
    "vrms": 0.0,
}

# Set this only when the laboratory deployment requires a module identifier.
# The repository does not include a laboratory-specific identifier.
DEVICE_ID = ""
tft = T_Display.TFT(DEVICE_ID) if DEVICE_ID else T_Display.TFT()

def fmt_scale(value):            # Formata números das escalas
    if int(value) == value:
        return "%d" % int(value)
    return "%.1f" % value


def adc_to_volt(adc_value):      # Converte um valor bruto do ADC em tensão de entrada
    v_adc = ADC_SLOPE * adc_value + ADC_OFFSET
    return (v_adc - ADC_REF) / DIV_FACTOR


def compute_stats(values):       # Calculo de Vmax, Vmin, Vav, Vrms
    vmax = values[0]
    vmin = values[0]
    soma = 0.0
    soma2 = 0.0

    for v in values:
        soma += v
        soma2 += v * v
        if v > vmax:
            vmax = v
        if v < vmin:
            vmin = v

    n = len(values)
    vav = soma / n
    vrms = math.sqrt(soma2 / n)
    return vmax, vmin, vav, vrms


def top_text():                  # Decide o texto da barra superior consoante o modo
    if mode == MODE_TIME:
        return "%sV/ %dms/" % (fmt_scale(V_SCALES[v_scale_idx]), T_SCALES[t_scale_idx])
    return "%sV/ %dHz/" % (fmt_scale(FV_SCALES[v_scale_idx]), FH_SCALES[t_scale_idx])


def draw_top_bar():              # Desenha a faixa superior
    tft.display_set(tft.BLACK, 0, TOP_Y, DISPLAY_W, TOP_H)
    tft.display_write_str(tft.Arial16, top_text(), 0, TOP_Y, tft.WHITE, tft.BLACK)
    tft.set_wifi_icon(DISPLAY_W - 16, TOP_Y)


def draw_grid():
    tft.display_write_grid(
        GRID_X, GRID_Y, GRID_W, GRID_H,
        10, 6,
        mode == MODE_TIME,       # True na forma de onda, False na Fourier
        tft.GREY1, tft.GREY2
    )


def draw_base_interface():       # reset visual antes de desenhar sinal ou espetro
    tft.display_set(tft.BLACK, 0, 0, DISPLAY_W, DISPLAY_H)
    draw_top_bar()
    draw_grid()


def volt_to_pixel(v):            # Tensão -> píxel no modo temporal
    v_per_div = V_SCALES[v_scale_idx]
    v_top = 3.0 * v_per_div
    pix_per_volt = (GRID_H - 1) / (2.0 * v_top)

    # y=0 em baixo e y crescente para cima -> tensão positiva sobe
    y = GRID_Y + (GRID_H - 1) / 2.0 + v * pix_per_volt

    if y < GRID_Y:
        y = GRID_Y
    if y > GRID_Y + GRID_H - 1:
        y = GRID_Y + GRID_H - 1

    return int(round(y))


def freq_to_pixel(mag):         # Magnitude -> píxel na vista de Fourier
    v_per_div = FV_SCALES[v_scale_idx]
    mag_top = 6.0 * v_per_div
    pix_per_volt = (GRID_H - 1) / mag_top

    # no espectro, 0 fica na base e magnitudes maiores sobem
    y = GRID_Y + mag * pix_per_volt

    if y < GRID_Y:
        y = GRID_Y
    if y > GRID_Y + GRID_H - 1:
        y = GRID_Y + GRID_H - 1

    return int(round(y))


def read_and_draw_wave():      # modo temporal
    global pontos_adc, pontos_volt, last_stats, mode

    mode = MODE_TIME
    total_ms = 10 * T_SCALES[t_scale_idx]
    pontos_adc = tft.read_adc(240, total_ms)

    x = []
    y = []

    for n in range(240):
        v = adc_to_volt(pontos_adc[n])
        pontos_volt[n] = v
        x.append(n)
        y.append(volt_to_pixel(v))

    vmax, vmin, vav, vrms = compute_stats(pontos_volt)
    last_stats["vmax"] = vmax
    last_stats["vmin"] = vmin
    last_stats["vav"] = vav
    last_stats["vrms"] = vrms

    draw_base_interface()
    tft.display_nline(tft.YELLOW, x, y)

    print(
        "Escalas:",
        "%sV/div" % fmt_scale(V_SCALES[v_scale_idx]),
        "%dms/div" % T_SCALES[t_scale_idx],
        "| total_ms =", total_ms,
        "| Vmax = %.2f" % vmax,
        "| Vmin = %.2f" % vmin,
        "| Vav = %.2f" % vav,
        "| Vrms = %.2f" % vrms,
    )


def compute_spectrum(values):  # DFT manual
    npoints = len(values)
    half = npoints // 2
    xss = [0.0] * (half + 1)

    for k in range(half + 1):
        re = 0.0
        im = 0.0

        for n in range(npoints):
            ang = 2.0 * math.pi * k * n / npoints
            re += values[n] * math.cos(ang)
            im -= values[n] * math.sin(ang)

        mag = math.sqrt(re * re + im * im)

        if k == 0 or k == half:
            xss[k] = mag / npoints
        else:
            xss[k] = 2.0 * mag / npoints

    return xss


def draw_spectrum():         # modo frequência
    global mode

    mode = MODE_FREQ
    xss = compute_spectrum(pontos_volt)

    x = []
    y = []

    # P0=P1=XSS0, P2=P3=XSS1, ... ignorando Nyquist
    for p in range(240):
        k = p // 2
        mag = xss[k]
        x.append(p)
        y.append(freq_to_pixel(mag))

    draw_base_interface()
    tft.display_nline(tft.YELLOW, x, y)

    total_ms = 10 * T_SCALES[t_scale_idx]
    total_s = total_ms / 1000.0

    kmax = 1
    for k in range(2, len(xss) - 1):
        if xss[k] > xss[kmax]:
            kmax = k

    fmax = kmax / total_s

    print(
        "DFT manual:",
        "%sV/div" % fmt_scale(FV_SCALES[v_scale_idx]),
        "%dHz/div" % FH_SCALES[t_scale_idx],
        "| Pico principal = %.1f Hz" % fmax,
        "| Modulo = %.2f V" % xss[kmax],
    )

    del xss
    gc.collect()


def send_last_points_mail():       # email
    if MAIL_ADDRESS == "":
        print("MAIL_ADDRESS vazio: coloca o teu email antes de testar o botao 12.")
        return

    total_ms = 10 * T_SCALES[t_scale_idx]
    delta_t = (total_ms / 1000.0) / 240.0

    body = (
        "Dados da ultima aquisicao\n"
        "Escala vertical = %s V/div\n"
        "Escala horizontal = %d ms/div\n"
        "Vmax = %.3f V\n"
        "Vmin = %.3f V\n"
        "Vav = %.3f V\n"
        "Vrms = %.3f V\n"
    ) % (
        fmt_scale(V_SCALES[v_scale_idx]),
        T_SCALES[t_scale_idx],
        last_stats["vmax"],
        last_stats["vmin"],
        last_stats["vav"],
        last_stats["vrms"],
    )

    tft.send_mail(delta_t, pontos_volt, body, MAIL_ADDRESS)


def next_v_scale():
    global v_scale_idx
    v_scale_idx = (v_scale_idx + 1) % len(V_SCALES)


def next_t_scale():
    global t_scale_idx
    t_scale_idx = (t_scale_idx + 1) % len(T_SCALES)


# Primeira leitura ao arrancar
read_and_draw_wave()

# Ciclo principal
while tft.working():
    but = tft.readButton()

    if but != tft.NOTHING:
        print("Button pressed:", but)

        if but == 11:          # Botao 1 click rapido
            read_and_draw_wave()

        elif but == 12:        # Botao 1 click lento
            send_last_points_mail()

        elif but == 21:        # Botao 2 click rapido
            next_v_scale()
            read_and_draw_wave()

        elif but == 22:        # Botao 2 click lento
            next_t_scale()
            read_and_draw_wave()

        elif but == 23:        # Botao 2 duplo click
            draw_spectrum()

        time.sleep(0.05)
