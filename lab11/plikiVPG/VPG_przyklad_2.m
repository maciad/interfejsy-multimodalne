%% Videopletyzmografia  cz.2
% 
% WERSJA: 03.12.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
% 
clear all;close all;clc

%% (1) Wczytanie danych z pliku TXT i przygotowanie danych do obliczeń
% - zanotuj w sprawozdaniu średni FPS

T = readtable('dane_puls1.txt','ReadVariableNames',true);
pixelsum        = [T.sumr T.sumg T.sumb];
t1              = T.iter;       % dla uproszczenia nr ramki jako timestamp
t2              = T.t2;
t3              = t2(~isnan(t2));% wybor tylko tych danych czasu które są różne od NaN
FPS             = 1/mean(t3);    % wyznaczamy średnią wartość FPS

% weryfikacja czy na kazdej ramce wykryto poprawnie twarz (jesli nie to
% suma pikseli zawiera wartosci NaN)
idnan=find(isnan(pixelsum(:,1)));
if ~isempty(idnan)
    disp('Nie wykryto twarzy na ramkach:')
    disp(num2str(t1(idnan)'))
end

%% (2) Wizualizacja sygnału VPG
figure;
plot(t1, pixelsum)
title('VPG')
xlabel('czas [ms]')
ylabel('wartość sumy pikseli')
legend({'R','G','B'})

%% (3) Wybór fragmentu sygnału 
% - do analizy wybierz stabilny fragment sygnału o długości 1024 próbki
%--------------------------------------
% UZUPEŁNIJ_1
 starti      = 3; % numer próbki początkowej
%--------------------------------------

idx1        = starti:starti+1024-1;% indeksy fragmentu sygnału

%-
t2      = t1(idx1);
vpg     = pixelsum(idx1, :);
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
% - opcjonalnie dobierz parametry dla usuwania trendu
%--------------------------------------
% UZUPEŁNIJ_2
 detrendingP     = 5;    % wielkość okna analizy dla algorytmu usuwania trendu [s]
%--------------------------------------

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

%% (5) Preprocessing sygnału VPG - filtracja pasmowoprzepustowa
%--------------------------------------
% UZUPEŁNIJ_3
% - przy użyciu narzędzia "filterDesigner" zaprojektuj filtr pasmowoprzepustowy
%  i wygeneruj z niego funkcję "my_bandpass_filter_2.m"
%  UWAGA - ustaw dla filtru odpowiednią częstotliwość próbkowania FPS !!!
%   - parametry filtru: metoda FIR-window=hamming
%                       częstotliwość próbkowania = FPS
%                       częstotliwości odcięcia dla 50 i 150 BPM
%                       rząd filtru = 64             
% >> filterDesigner
% ----------------------------------------------------------------

% użycie wygenerowanego filtru
Hd = my_bandpass_filter_2;
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

%% (6) Analiza sygnału VPG - transformata Fouriera sygnału
% - zaobserwuj na której składowej występuje wyraźny "peak" dla
%   częstotliwości zbliżonej do referencyjnej wartości pulsu
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

minmaxHR_p          = [50 150]; % minimalna i maksymalna dopuszczalna wartość pulsu

f1      = f * 60;       % częstotliwość w bpm
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


%% (7) Analiza sygnału VPG - wyznaczenie wartości pulsu
% - wykrycie "peaks"
% - jeśli puls nie zostanie wykryty dobierz parametr dla funkcji "findpeaks"
% - Q: czy wyznaczona wartośc pulsu jest podobna do pulsu zmierzonego
%      pulsometrem  (lub ręcznie)?
%--------------------------------------
% UZUPEŁNIJ_4
p_MinPeakProminence         = 0.3;          % parametr f. findpeaks
%--------------------------------------


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
              
