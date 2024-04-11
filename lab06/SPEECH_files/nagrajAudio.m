%% Akwizycja audio z mikrofonu
% WERSJA: 12.10.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
%
clear all;close all;clc

%% Nagrywanie 
%{
% Sprawdzenie numeru urządzeń audio
info = audiodevinfo
openvar info.input
%}
   
Fs=44100;     % częstotliwość próbkowania
NBit=16;      % liczba bitów
NumCh=1;      % 1 kanał
chID = -1;    % wpisz numer ID urządzenia (-1 domyślne urządzenie)

% uwaga - może występować opóźnienie audio
recObj = audiorecorder(Fs, NBit, NumCh,chID);
disp('Start nagrywania')
recordblocking(recObj, 8);% 8 sekund nagrania
y = getaudiodata(recObj);

plot(y)
disp('Koniec nagrywania')

% odtworzenie audio ( w celu sprawdzenia poprawności nagrania)
% player = audioplayer(y,Fs); play(player)

%% Wytnij fragment sygnału zawierający samogłoskę
% - z wykresu plot odczytaj indeksy początku i końca sygnału samogłoski
% - użyj tych indeksów do wyboru fragmentu sygnału
% - upewnij się że wycięty sygnał jest w przybliżeniu 1s długi
OUTPUTSIG = y(82770:110500, :);

n = size(OUTPUTSIG,1);
disp(['Czas fragmentu = ' num2str(n/Fs) ' [s]'])

figure;
plot(OUTPUTSIG)

%{
% opcjonalnie do detekcji fragmentu mowy można użyć funkcji:
detectSpeech(y,Fs);
idx = detectSpeech(y,Fs)
%}

%% Eksport audio do pliku
AUDIOPATH='audioFiles\';            % katalog bazy plików audio
filename = 'a_1_men3.wav';          % USTAW nazwę pliku audio

audiowrite(fullfile(AUDIOPATH,filename), OUTPUTSIG, Fs);

