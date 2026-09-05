%% LAB 3 - Design and simulation of digital filters

clear; close all; clc;

%% =========================
% 1) Parâmetros e sinal de entrada
% ==========================
fs = 8000;                 % frequência de amostragem [Hz]
Ts = 1/fs;                 % período de amostragem [s]
N  = 16000;                % número total de amostras
n  = 0:N-1;                % índice discreto
t  = n/fs;                 % tempo [s]

% x(t) = 0.5*[1 + sin(2*pi*200*t) + sin(2*pi*1000*t) + sin(2*pi*3000*t)]
x = 0.5 + 0.5*sin(2*pi*200*t) + 0.5*sin(2*pi*1000*t) + 0.5*sin(2*pi*3000*t);

% FFT unilateral
X_fft = fft(x)/N;
f_fft = (0:N-1)*(fs/N);
X_mag_1s = 2*abs(X_fft(1:N/2+1));
X_mag_1s(1) = abs(X_fft(1));   % não duplicar DC

figure(1);
subplot(2,1,1);
plot(t, x, 'LineWidth', 1.2);
title('Sinal de entrada x(t)');
xlabel('Tempo [s]');
ylabel('Amplitude [V]');
grid on;
axis([0 0.02 -1 2]);

subplot(2,1,2);
plot(f_fft(1:N/2+1), X_mag_1s, 'LineWidth', 1.2);
title('Espectro de magnitude de x[n]');
xlabel('Frequência [Hz]');
ylabel('|X(f)|');
grid on;
axis([0 4000 0 1]);

%% =========================
% 2) Filtro IIR
% ==========================
% Especificações
fo = 1000;                 % frequência central desejada [Hz]
Q  = 10;                   % fator de qualidade
ko = 1;                    % ganho em fo
wo = 2*pi*fo;              % pulsação [rad/s]

% Ta(s) = [ko*(wo/Q)*s] / [s^2 + (wo/Q)*s + wo^2]
num_s = [ko*(wo/Q), 0];
den_s = [1, (wo/Q), wo^2];

% Conversão bilinear
[b_iir, a_iir] = bilinear(num_s, den_s, fs);

fprintf('\n================ IIR =================\n');
fprintf('Coeficientes do filtro IIR digital:\n');
fprintf('b = [%.9f  %.9f  %.9f]\n', b_iir(1), b_iir(2), b_iir(3));
fprintf('a = [%.9f  %.9f  %.9f]\n', a_iir(1), a_iir(2), a_iir(3));

% ---- Resposta em frequência analógica e digital entre 0 e 8 kHz ----
% Nota:
% No digital, acima de fs/2 = 4 kHz já não há banda "nova"; a resposta é periódica.
% Ainda assim, para seguir o guia, mostramos 0-8 kHz.

f_iir = linspace(0, 8000, 8001);     % 0 a 8 kHz
w_iir = 2*pi*f_iir;

% Analógico
Ha = freqs(num_s, den_s, w_iir);

% Digital avaliado em z = exp(j*w*T)
Omega = 2*pi*f_iir/fs;               % frequência digital [rad/amostra]
z = exp(1j*Omega);
Hd = (b_iir(1) + b_iir(2)./z + b_iir(3)./(z.^2)) ./ ...
     (a_iir(1) + a_iir(2)./z + a_iir(3)./(z.^2));

% Frequências centrais reais (pico da magnitude)
[~, idx_foa] = max(abs(Ha));
[~, idx_fod] = max(abs(Hd));
foa = f_iir(idx_foa);
fod = f_iir(idx_fod);

fprintf('\nQuestão 1:\n');
fprintf('foa (analógico) = %.3f Hz\n', foa);
fprintf('fod (digital)   = %.3f Hz\n', fod);
fprintf('Desvio          = %.3f Hz\n', fod - foa);

figure(2);
subplot(2,1,1);
plot(f_iir, 20*log10(abs(Ha)+eps), 'b', 'LineWidth', 1.8); hold on;
plot(f_iir, 20*log10(abs(Hd)+eps), 'r--', 'LineWidth', 1.4);
xline(foa, 'b:', 'foa');
xline(fod, 'r:', 'fod');
title('IIR - Magnitude: Analógico vs Digital (0 a 8 kHz)');
xlabel('Frequência [Hz]');
ylabel('Ganho [dB]');
legend('Analógico', 'Digital', 'Location', 'best');
grid on;
axis([0 8000 -60 5]);

subplot(2,1,2);
plot(f_iir, unwrap(angle(Ha))*180/pi, 'b', 'LineWidth', 1.8); hold on;
plot(f_iir, unwrap(angle(Hd))*180/pi, 'r--', 'LineWidth', 1.4);
title('IIR - Fase: Analógico vs Digital (0 a 8 kHz)');
xlabel('Frequência [Hz]');
ylabel('Fase [graus]');
legend('Analógico', 'Digital', 'Location', 'best');
grid on;
axis([0 8000 -600 200]);

% ---- Filtragem IIR ----
y_iir = filter(b_iir, a_iir, x);

Y_iir_fft = fft(y_iir)/N;
Y_iir_mag_1s = 2*abs(Y_iir_fft(1:N/2+1));
Y_iir_mag_1s(1) = abs(Y_iir_fft(1));

% amplitude a 1 kHz obtida da FFT
[~, idx_1k] = min(abs(f_fft(1:N/2+1) - 1000));
Aout_1k_iir = Y_iir_mag_1s(idx_1k);

fprintf('\nQuestão 2:\n');
fprintf('Amplitude de saída em 1 kHz (FFT de y[n]) = %.6f V\n', Aout_1k_iir);

figure(3);
subplot(2,1,1);
plot(t, x, 'Color', [0.75 0.75 0.75], 'LineWidth', 1.0); hold on;
plot(t, y_iir, 'b', 'LineWidth', 1.3);
title('IIR - Sinal de entrada e saída no domínio do tempo');
xlabel('Tempo [s]');
ylabel('Amplitude [V]');
legend('x[n]', 'y[n]', 'Location', 'best');
grid on;
axis([0.005 0.015 -1 2]);

subplot(2,1,2);
plot(f_fft(1:N/2+1), X_mag_1s, 'Color', [0.75 0.75 0.75], 'LineWidth', 1.0); hold on;
plot(f_fft(1:N/2+1), Y_iir_mag_1s, 'r', 'LineWidth', 1.3);
xline(1000, 'k:', '1 kHz');
title('IIR - Espectro de magnitude: entrada vs saída');
xlabel('Frequência [Hz]');
ylabel('Magnitude');
legend('X(f)', 'Y(f)', 'Location', 'best');
grid on;
axis([0 4000 0 1]);

%% =========================
% 3) Filtro FIR
% ==========================
fc_fir = 1000;                % frequência de passagem/corte [Hz]
N_fir  = 41;                  % número de coeficientes
ord_fir = N_fir - 1;          % ordem
Wn_fir = fc_fir/(fs/2);       % frequência normalizada

% Projeto dos FIR
b_rect = fir1(ord_fir, Wn_fir, 'low', rectwin(N_fir));
b_hann = fir1(ord_fir, Wn_fir, 'low', hann(N_fir));

fprintf('\n================ FIR =================\n');
fprintf('Número de coeficientes N = %d\n', N_fir);
fprintf('Atraso teórico tau = (N-1)/(2*fs) = %.6f s = %.3f ms\n', ...
    (N_fir-1)/(2*fs), 1000*(N_fir-1)/(2*fs));

% ---- Coeficientes FIR (pedido pelo guia) ----
figure(4);
subplot(2,1,1);
stem(0:ord_fir, b_rect, 'filled');
title('Coeficientes do FIR - Janela Retangular');
xlabel('n');
ylabel('h_{rect}[n]');
grid on;

subplot(2,1,2);
stem(0:ord_fir, b_hann, 'filled');
title('Coeficientes do FIR - Janela de Hanning');
xlabel('n');
ylabel('h_{hann}[n]');
grid on;

% ---- Bode dos FIR entre 0 e 4 kHz ----
[H_rect, f_fir] = freqz(b_rect, 1, 4096, fs);
[H_hann, ~]     = freqz(b_hann, 1, 4096, fs);

figure(5);
subplot(2,1,1);
plot(f_fir, 20*log10(abs(H_rect)+eps), 'b', 'LineWidth', 1.5); hold on;
plot(f_fir, 20*log10(abs(H_hann)+eps), 'r', 'LineWidth', 1.5);
title('FIR - Magnitude: Retangular vs Hanning');
xlabel('Frequência [Hz]');
ylabel('Ganho [dB]');
legend('Retangular', 'Hanning', 'Location', 'best');
grid on;
axis([0 4000 -100 5]);

subplot(2,1,2);
plot(f_fir, unwrap(angle(H_rect))*180/pi, 'b', 'LineWidth', 1.5); hold on;
plot(f_fir, unwrap(angle(H_hann))*180/pi, 'r', 'LineWidth', 1.5);
title('FIR - Fase: Retangular vs Hanning');
xlabel('Frequência [Hz]');
ylabel('Fase [graus]');
legend('Retangular', 'Hanning', 'Location', 'best');
grid on;
axis([0 4000 min(unwrap(angle(H_hann))*180/pi)-50 50]);

% ---- Estimativa de As e Delta f ----
mag_rect_db = 20*log10(abs(H_rect)+eps);
mag_hann_db = 20*log10(abs(H_hann)+eps);

idx_stop = find(f_fir >= 1500);
As_rect_est = -max(mag_rect_db(idx_stop));
As_hann_est = -max(mag_hann_db(idx_stop));

idx_rect_m3  = find(mag_rect_db <= -3, 1, 'first');
idx_rect_m40 = find(mag_rect_db <= -40, 1, 'first');
idx_hann_m3  = find(mag_hann_db <= -3, 1, 'first');
idx_hann_m40 = find(mag_hann_db <= -40, 1, 'first');

if ~isempty(idx_rect_m3) && ~isempty(idx_rect_m40)
    Deltaf_rect_est = f_fir(idx_rect_m40) - f_fir(idx_rect_m3);
else
    Deltaf_rect_est = NaN;
end

if ~isempty(idx_hann_m3) && ~isempty(idx_hann_m40)
    Deltaf_hann_est = f_fir(idx_hann_m40) - f_fir(idx_hann_m3);
else
    Deltaf_hann_est = NaN;
end

Deltaf_rect_theo = (0.9/N_fir)*(fs/2);
Deltaf_hann_theo = (3.1/N_fir)*(fs/2);
As_rect_theo = 21;
As_hann_theo = 44;

fprintf('\nEstimativas FIR a partir das respostas em frequência:\n');
fprintf('Retangular: As_est ~= %.2f dB | Deltaf_est ~= %.2f Hz\n', As_rect_est, Deltaf_rect_est);
fprintf('Hanning   : As_est ~= %.2f dB | Deltaf_est ~= %.2f Hz\n', As_hann_est, Deltaf_hann_est);

fprintf('\nValores teóricos de referência (Tabela 1):\n');
fprintf('Retangular: As_theo ~= %.2f dB | Deltaf_theo ~= %.2f Hz\n', As_rect_theo, Deltaf_rect_theo);
fprintf('Hanning   : As_theo ~= %.2f dB | Deltaf_theo ~= %.2f Hz\n', As_hann_theo, Deltaf_hann_theo);

% ---- Filtragem FIR com Hanning ----
y_fir = filter(b_hann, 1, x);

Y_fir_fft = fft(y_fir)/N;
Y_fir_mag_1s = 2*abs(Y_fir_fft(1:N/2+1));
Y_fir_mag_1s(1) = abs(Y_fir_fft(1));

tau_theory = (N_fir - 1)/(2*fs);

[cxy, lags] = xcorr(y_fir, x);
[~, idx_maxcorr] = max(cxy);
delay_samples_sim = lags(idx_maxcorr);
tau_sim = delay_samples_sim/fs;

fprintf('\nQuestão 3:\n');
fprintf('Atraso teórico   = %.6f s = %.3f ms\n', tau_theory, 1000*tau_theory);
fprintf('Atraso simulado  = %.6f s = %.3f ms (%d amostras)\n', ...
    tau_sim, 1000*tau_sim, delay_samples_sim);

figure(6);
subplot(2,1,1);
plot(t, x, 'Color', [0.75 0.75 0.75], 'LineWidth', 1.0); hold on;
plot(t, y_fir, 'r', 'LineWidth', 1.2);
title('FIR (Hanning) - Sinal de entrada e saída');
xlabel('Tempo [s]');
ylabel('Amplitude [V]');
legend('x[n]', 'y[n]', 'Location', 'best');
grid on;
axis([0.005 0.020 -1 2]);

subplot(2,1,2);
plot(f_fft(1:N/2+1), X_mag_1s, 'Color', [0.75 0.75 0.75], 'LineWidth', 1.0); hold on;
plot(f_fft(1:N/2+1), Y_fir_mag_1s, 'r', 'LineWidth', 1.3);
title('FIR (Hanning) - Espectro de magnitude: entrada vs saída');
xlabel('Frequência [Hz]');
ylabel('Magnitude');
legend('X(f)', 'Y(f)', 'Location', 'best');
grid on;
axis([0 4000 0 1]);

figure(7);
plot(t, x, 'Color', [0.75 0.75 0.75], 'LineWidth', 1.0); hold on;
plot(t, y_fir, 'r', 'LineWidth', 1.3);
xline(0.0100, 'k--', 't_{in} exemplo');
xline(0.0100 + tau_theory, 'b--', 't_{in} + \tau_{theory}');
title('FIR (Hanning) - Visualização do atraso de grupo');
xlabel('Tempo [s]');
ylabel('Amplitude [V]');
legend('x[n]', 'y[n]', 'Location', 'best');
grid on;
axis([0.008 0.016 -1 2]);

%% =========================
% 4) Audição dos 3 sinais
% ==========================
fprintf('\nA reproduzir os 3 sinais: original -> IIR -> FIR\n');

player = audioplayer(x, fs);
playblocking(player);

pause(1);

player = audioplayer(y_iir, fs);
playblocking(player);

pause(1);

player = audioplayer(y_fir, fs);
playblocking(player);

%% =========================
% 5) Resumo final
% ==========================
fprintf('\n================ RESUMO FINAL =================\n');
fprintf('IIR:\n');
fprintf('foa = %.3f Hz\n', foa);
fprintf('fod = %.3f Hz\n', fod);
fprintf('Amplitude de y[n] em 1 kHz = %.6f V\n', Aout_1k_iir);

fprintf('\nFIR:\n');
fprintf('tau_theory = %.6f s = %.3f ms\n', tau_theory, 1000*tau_theory);
fprintf('tau_sim    = %.6f s = %.3f ms\n', tau_sim, 1000*tau_sim);
fprintf('Rectangular -> As_est ~= %.2f dB | Deltaf_est ~= %.2f Hz\n', As_rect_est, Deltaf_rect_est);
fprintf('Hanning     -> As_est ~= %.2f dB | Deltaf_est ~= %.2f Hz\n', As_hann_est, Deltaf_hann_est);
