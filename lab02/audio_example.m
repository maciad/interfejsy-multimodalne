%% Przykład akwizycji audio z mikrofonu
% 
% UWAGI:
% > na podstawie przykładu z dokumentacji: Real-Time Audio in MATLAB
% > więcej informacji w dokumentacji:
%   >> doc 'Audio I/O: Buffering, Latency, and Throughput'
% WERSJA: 09.03.2023, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2022b
% 
clear all;close all;clc

%% Tworzenie obiektów do obsługi wejść i wyjść audio
frameLength = 1024;         % długość bufora audio w próbkach
fs          = 16000;        % częstotliwość próbkowania w Hz

% obiekt obsługujący wejście audio (mikrofon)
% Uwaga: w przypadku błędów "audioDeviceReader" lub "audioDeviceWriter"
%        może być konieczne wyspecyfikowanie odpowiedniego sterownika
%        (parametr "driver") oraz urządzenia (parametr "device")
%        dla linuxa "driver" powinno być równe "ALSA"
%        Można to sprawdzić np.:
%{
info = audiodevinfo 
info.input
info.input(1)
%}
%
audioReader = audioDeviceReader('SampleRate',fs,...
    'SamplesPerFrame',frameLength);
%        pomocnicza funkcja: 
%            devices = getAudioDevices(audioReader)

% obiekt obsługujący wyjście audio (głośnik)
deviceWriter = audioDeviceWriter( ...
    'SampleRate',audioReader.SampleRate);

% obiekt wizualizacji sygnału
scope = timescope( ...
    'SampleRate',audioReader.SampleRate, ...
    'TimeSpan',2, ...
    'BufferLength',audioReader.SampleRate*2*2, ...
    'YLimits',[-1,1], ...
    'TimeSpanOverrunAction',"Scroll");

% obiekt przetwarzania sygnału
reverb = reverberator( ...
    'SampleRate',audioReader.SampleRate, ...
    'PreDelay',0.5, ...
    'WetDryMix',0.4);


%% Pętla akwizycji audio
disp('początek akwizycji audio')
czasAkwizycji = 25;          % [s]
tic
while toc < czasAkwizycji
    signal = audioReader();
    reverbSignal = reverb(signal);
    deviceWriter(reverbSignal);
    scope([signal,mean(reverbSignal,2)])
end
disp('koniec akwizycji audio')

% zwolnienie zasobów
release(audioReader)
release(deviceWriter)
release(reverb)
release(scope)

