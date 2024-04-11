%% Analiza sygnału mowy, cz1
% - utworzony: 23.10.2020, R2020a, J.Przybyło, AGH
%
clear all;close all;clc

%% (1) Wczytanie pliku audio
AUDIOPATH='audioFiles/';            % katalog bazy plików audio
filename = 'a_1_men1.wav';          % nazwa pliku audio

[y,Fs] = audioread(fullfile(AUDIOPATH, filename));% wczytani audio

if size(y, 2)>1
    y = y(:,1); % wybierz tylko jeden kanał
end

% wektor czasu (na podstawie częstotliwości próbkowania)
t1 = linspace((1/Fs),(numel(y)/Fs),numel(y));

figure;
plot(t1, y)
ylabel('Amplituda')
xlabel('Czas (s)')

%% (2) Preprocessing sygnału
% - okno czasowe Hamminga
% - filtr preemfazy
y1 = y.*hamming(length(y));
preemph = [1 0.63];
y2 = filter(1,preemph,y1);

figure;
plot(t1, y2)
ylabel('Amplituda')
xlabel('Czas (s)')
title('Sygnał po preprocessingu')

%% (2) Obliczenie i wizualizacja widma sygnału
% Zapoznaj się z funkcją FFT (doc fft)
n = length(y2);
Y3  = fft(y2);
P3a = abs(Y3/n);
P3  = P3a(1:floor(n/2)+1);
P3(2:end-1) = 2*P3(2:end-1);

f = Fs*(0:(n/2))/n;
figure;
plot(f,P3) 
title('Widmo sygnału')
xlabel('f (Hz)')
ylabel('|P3(f)|')
xlim([0 5000])

%% (3) Wyznaczenie tonu podstawowego
% Zapoznaj się z funkcją pitch (doc pitch)
windowLength    = round(0.03*Fs);  % parametr funkcji "pitch"
overlapLength   = round(0.025*Fs); % parametr funkcji "pitch"
f0              = pitch(y2, Fs, 'WindowLength', windowLength,...
                    'OverlapLength', overlapLength, 'Range', [50,250]);
timeVectorPitch = linspace((1/Fs),(n/Fs),numel(f0));

figure;
subplot(2,1,1)
plot(t1, y2)
ylabel('Amplituda')
xlabel('Czas (s)')
title('Sygnał')
subplot(2,1,2)
plot(timeVectorPitch,f0,'-*')
ylabel('Ton podstawowy (Hz)')
xlabel('Czas (s)')
title('Kontur tonu podstawowego')

disp(['Średnia wartość tonu podstawowego dla całego sygnału = ' num2str(mean(f0)) ' [Hz]'])

%% (4) Estymacja formantów LPC
% Zapoznaj się z funkcją w pliku "estimate_formants.m"
formants = estimate_formants(y2, Fs); 
% wybór 3 pierwszych formantów
sprintf('Formanty : F1=%5.2f Hz, F2=%5.2f Hz,  F3=%5.2f Hz', formants(1:3))

