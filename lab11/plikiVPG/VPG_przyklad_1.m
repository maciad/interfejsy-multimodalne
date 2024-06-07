%% Videopletyzmografia 
% 
% WERSJA: 03.12.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
% 
clear all;close all;clc

%% (1) Wczytanie danych 
% - dane zawierają strukturę o następujących polach
%   .pixelsum       - suma pixeli w ROI twarzy dla danej ramki i każdego
%                     kanału RGB, tablica [N x 3], kolejne kolumny: R,G,B
%   .timestamp      - wektor próbek czasu [ms]
%   .HR             - wektor danych pulsu (heart rate) zmierzonych przy
%                     pomocy pulsometru (dostosowany do wektora czasu
%                     timestamp)
%   .FPS            - wartość FPS kamery zbierającej dane (liczba)
load daneVPG
%
pixelsum        = DANE.pixelsum;
t1              = DANE.timestamp;
HR              = DANE.HR;
FPS             = DANE.FPS;


%% (2) Wizualizacja sygnału VPG
% - powiększ fragment sygnału każdej składowej - czy widoczna jest
%   okresowość sygnału?
figure;
plot(t1, pixelsum)
title('VPG')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')
legend({'R','G','B'})

%% (3) Wybór fragmentu sygnału 
% - do analizy wybieramy fragment sygnału o określonej długości 
%   (większej lub równej niż długość FFT = 1024)
% - przy pomocy funkcji isnan usuwane są ew fragmenty sygnału które nie
%   były poprawnie wyznaczone (np na takiej ramce nie wykryto twarzy)
% - Q: zastanów się co w przypadku gdy wystąpi sytuacja gdy więcej niż
%      kilka kilejnych elementów sygnału będzie równe NaN?

idx1        = 800:800+1024-1;% indeksy fragmentu sygnału
%-
t2      = t1(idx1);
vpg     = pixelsum(idx1, :);
HR2     = HR(idx1);
vpg(isnan(vpg))=0;% zastępowanie ew NaN zerami

figure;
plot(t2, vpg)
title('VPG, fragment')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')
legend({'R','G','B'})

figure;
subplot(3,1,1)
plot(t2, vpg(:,1))
title('VPG R, fragment')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')
subplot(3,1,2)
plot(t2, vpg(:,2))
title('VPG G, fragment')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')
subplot(3,1,3)
plot(t2, vpg(:,3))
title('VPG B, fragment')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')

%% (4) Preprocessing sygnału VPG - usuwanie trendu
% [1] de Haan G, Jeanne V (2013). 
%     Robust pulse rate from chrominance-based rPPG,
%     IEEE Transactions on Biomedical Engineering 60(10): 2878-2886.
% - Q: Na czym polega metoda MCwS (Mean-Centering-And-Scaling [1])?

% - parametry
detrendingP     = 1;    % wielkość okna analizy dla algorytmu usuwania trendu [s]

% - usunięcie trendu z sygnału, metoda MCwS (Mean-Centering-And-Scaling [1])
w               = round(detrendingP * FPS);    
n               = conv2(ones(3, size(vpg,1)), ones(1, w), 'same');
meanIntensity   = conv2(vpg', ones(1, w), 'same')./n;
sig1            = (vpg' - meanIntensity)./meanIntensity;
vpg2            = sig1';

figure;
subplot(3,1,1)
plot(t2, vpg2(:,1))
title('VPG R, po detrending')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')
subplot(3,1,2)
plot(t2, vpg2(:,2))
title('VPG G, po detrending')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')
subplot(3,1,3)
plot(t2, vpg2(:,3))
title('VPG B, po detrending')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')

%% (5) Odczytanie wartości pulsu z wykresu
% ----------------------------------------------------------------
% UZUPEŁNIJ_1
% Q: Czy da się zauważyć na sygnale po usunięciu trendu okresowość?
%    Na jakiej składowej (R,G,B) okresowość jest najlepiej widoczna?
%
%    Na podstawie wykresu spróbuj odczytać okres sygnału. Podaj w
%    sprawozdaniu wartość okresu w [s] oraz częstotliwość sygnału w [Hz] i
%    w [BPM] (beats per minute - uderzenia serca na minutę)
%
%    Porównaj odczytaną z wykresu wartość pulsu ze średnią wartością tętna
%    z pulsometru

T       = 0.001/11;    % okres w [s]
fHz     = 1/T;                     % częstotliwość w [Hz]
fBPM    = 60*fHz;                    % częstotliwość w [BPM]

%----------------------------------------------------------------
meanBPM = mean(HR2);               % średnia wartoś pulsu z pulsometru

disp(['T            = ' num2str(T) ' [s]'])
disp(['f            = ' num2str(fHz) ' [Hz]'])
disp(['f            = ' num2str(fBPM) ' [BPM]'])
disp(['średni puls  = ' num2str(meanBPM) ' [BPM]'])

%% (6) Preprocessing sygnału VPG - filtracja pasmowoprzepustowa
% ----------------------------------------------------------------
% UZUPEŁNIJ_2
% - przy użyciu narzędzia "filterDesigner" zaprojektuj filtr pasmowoprzepustowy
%  i wygeneruj z niego funkcję "my_bandpass_filter.m"
%  (jeśli już to zostało zrobione wcześniej, wykorzystaj tutaj
%   wygenerowany kod filtru)
%   - parametry filtru: metoda FIR-window=hamming
%                       częstotliwość próbkowania = FPS
%                       częstotliwości odcięcia dla 50 i 150 BPM
%                       rząd filtru = 64             
% - zapoznaj się z dokumentacją funkcji: fir1, hamming 
% - zapoznaj się z dokumentacją funkcji: filtfilt
% >> filterDesigner
% ----------------------------------------------------------------

% użycie wygenerowanego filtru
Hd = my_bandpass_filter;
b  = Hd.Numerator;
a  = 1;

% filtracja poszczególnych składowych sygnału
vpg3 = [];
for iChannel = 1:size(vpg2,2)
    vpg3(:,iChannel) = filtfilt(b, a, vpg2(:,iChannel));
end
                    
figure;
subplot(3,1,1)
plot(t2, vpg3(:,1))
title('VPG R, po filtracji')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')
subplot(3,1,2)
plot(t2, vpg3(:,2))
title('VPG G, po filtracji')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')
subplot(3,1,3)
plot(t2, vpg3(:,3))
title('VPG B, po filtracji')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')

%% (7) Analiza sygnału VPG - transformata Fouriera sygnału
% - zapoznaj się z dokumentacją funkcji FFT
% - uzupełnij odpowiednie fragmenty kodu
% Q: z widma której składowej najlepiej odczytać wartość pulsu 
%    (najłatwiejsza do odróżnienia częstotliwosć)? 
%

Fs  = FPS;              % częstotliwość próbkowania                
Ts  = 1/Fs;             % okres próbkowania
L   = size(vpg3,1);     % długość sygnału

% Transformata Fouriera sygnału
f       = Fs*(0:(L/2))/L;   % wektor częstotliwości
Yr      = fft(vpg3(:,1));   % składowa R
Yg      = fft(vpg3(:,2));   % składowa G
Yb      = fft(vpg3(:,3));   % składowa B
% -
P2r     = abs(Yr/L);
P2g     = abs(Yg/L);
P2b     = abs(Yb/L);
P1r     = P2r(1:L/2+1);P1r(2:end-1) = 2*P1r(2:end-1);
P1g     = P2g(1:L/2+1);P1g(2:end-1) = 2*P1g(2:end-1);
P1b     = P2b(1:L/2+1);P1b(2:end-1) = 2*P1b(2:end-1);

figure;
subplot(3,1,1)
plot(f,P1r) 
title('jednostronne widmo amplitudowe, składowa R')
xlabel('f (Hz)')
ylabel('|P1r(f)|')
subplot(3,1,2)
plot(f,P1g) 
title('jednostronne widmo amplitudowe, składowa G')
xlabel('f (Hz)')
ylabel('|P1g(f)|')
subplot(3,1,3)
plot(f,P1b) 
title('jednostronne widmo amplitudowe, składowa B')
xlabel('f (Hz)')
ylabel('|P1b(f)|')

% ----------------------------------------------------------------
% UZUPEŁNIJ_3
% - uzupełnij tworzenie wykresu realizującego wizualizację widma sygnału w
% zakresie częstotliwości ale w jednoskach BPM (uderzeń na minutę) a nie Hz
minmaxHR_p          = [50 150]; % minimalna i maksymalna dopuszczalna wartość pulsu

f1      = f* 60;       % częstotliwość w bpm

wybor1  = f1>=minmaxHR_p(1) & f1<=minmaxHR_p(2);
f2      = f1(wybor1);
P1r_sel = P1r(wybor1);
P1g_sel = P1g(wybor1);
P1b_sel = P1b(wybor1);

figure;
subplot(3,1,1)
plot(f2,P1r_sel) 
title('jednostronne widmo amplitudowe (zakres 50-150bpm), składowa R')
xlabel('f2 (bpm)')
ylabel('|P1r_sel(f)|','Interpreter','none')
subplot(3,1,2)
plot(f2,P1g_sel) 
title('jednostronne widmo amplitudowe (zakres 50-150bpm), składowa G')
xlabel('f2 (bpm)')
ylabel('|P1g_sel(f)|','Interpreter','none')
subplot(3,1,3)
plot(f2,P1b_sel) 
title('jednostronne widmo amplitudowe (zakres 50-150bpm), składowa B')
xlabel('f2 (bpm)')
ylabel('|P1b_sel(f)|','Interpreter','none')


%% (8) Analiza sygnału VPG - wyznaczenie wartości pulsu
% - wykrycie "peaks"
% - zapoznaj się z dokumentacją funkcji "findpeaks"

p_MinPeakProminence         = 0.3;          % parametr f. findpeaks

[pksR,locsR] = findpeaks(10*log10(P1r_sel),'MinPeakProminence',p_MinPeakProminence);           
[pksG,locsG] = findpeaks(10*log10(P1g_sel),'MinPeakProminence',p_MinPeakProminence);           
[pksB,locsB] = findpeaks(10*log10(P1b_sel),'MinPeakProminence',p_MinPeakProminence);           


if length(pksR)>0
    [~,idsorted]    = sort(pksR,'descend');
    idhr            = idsorted(1);
    HRr             = single(f2(locsR(idhr)));
else
    HRr             = NaN;
    warning('Nie wykryto częstotliwości pulsu na sygnale R')
end
if length(pksG)>0
    [~,idsorted]    = sort(pksG,'descend');
    idhg            = idsorted(1);
    HRg             = single(f2(locsG(idhg)));    
else
    HRg             = NaN;
    warning('Nie wykryto częstotliwości pulsu na sygnale G')
end   
if length(pksB)>0
    [~,idsorted]    = sort(pksB,'descend');
    idhb            = idsorted(1);
    HRb             = single(f2(locsB(idhb)));
else
    HRb             = NaN;    
    warning('Nie wykryto częstotliwości pulsu na sygnale B')
end
                    
disp(['HRr            = ' num2str(HRr) ' [BPM]'])
disp(['HRg            = ' num2str(HRg) ' [BPM]'])
disp(['HRb            = ' num2str(HRb) ' [BPM]'])
disp(['średni puls    = ' num2str(meanBPM) ' [BPM]'])
              
