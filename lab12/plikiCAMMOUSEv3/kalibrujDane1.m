%% Kalibracja - skrypt pomocniczy do camera mouse
% 
% UWAGI:
%
% WERSJA: 25.11.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
% 
clear all;close all;clc

%% Import danych do kalibracji zapisanych przez "myExportDataCAMMOUSE.m"
CDATA = readtable('calibdata_1.txt');
x0     = CDATA.facex;       % współrzędna x środka twarzy (lub -1)
y0     = CDATA.facey;       % współrzędna y środka twarzy (lub -1)
t2     = CDATA.t2;          % czas przetwarzania poprzedniej ramki (lub NaN)
iter   = CDATA.iter;        % numer ramki

% pominiecie danych x,y gdy brak detekcji twarzy (x,y==-1)
x      = x0(x0>=0&y0>=0);
y      = y0(x0>=0&y0>=0);

% pominięcie danych t2 gdy NaN
t2     = t2(~isnan(t2));
iter   = iter(~isnan(t2));

%% Wizualizacja czasu przetwarzania ramek video
% - zamieść wykres w sprawozdaniu
% - oblicz średnią szybkość przetwarzania video (FPS - frames per second)
% - Q1: czy błędne wartości czasów akwizycji (np na początku) wpływają w
%   znaczący spósób na obliczoną średnią?
figure;
plot(iter, t2)
xlabel('nr ramki')
ylabel('czas [s]')
title('Czas przetwarzania kolejnych ramek')

FPS = mean(1./t2);% UZUPEŁNIJ obliczanie średniego FPS
disp(['FPS = ' num2str(FPS)])


%% Wizualizacja trajektorii xy
% - zamieść wykres w sprawozdaniu
figure;
plot(x,y,'-b.')
xlabel('face X')
ylabel('face Y')
title('trajektoria xy')

%% Wizualizacja trajektorii - osobno x i y
% - zamieść wykres w sprawozdaniu
figure;
subplot(2,1,1)
plot(x,'-b.')
xlabel('face X')
title('trajektoria ')
subplot(2,1,2)
plot(y,'-b.')
xlabel('face Y')

%% Prosta kalibracja współczynniki CD dla osi x oraz y 
% - uzupełnij kod aby wyznaczyć współczynnki wzmocnienia CD dla osi x i y
% - zamieść wyniki (CDx, CDy, offset_x, offset_y) i wykresy w sprawozdaniu
CDx     = ( max(x) - min(x) )/( 1 - 0 );
CDy     = ( max(y) - min(y) )/( 1 - 0 );

offset_x = min(x);
offset_y = min(y);

% normalizacja sygnałów x i y do zakresu <0-1>
% Q2: wyjaśnij dlaczego potrzebny jest offset
x_cursor = (x-offset_x)/CDx;
y_cursor = (y-offset_y)/CDy;

% dodatkowo - korekta ew wychyleń głowy większych niż na etapie kalibracji
% (w trakcie działania systemu może się zdarzyć że użytkownik poruszy głową
% bardziej niż podczas kalibracji)
x_cursor(x_cursor<0) = 0;
x_cursor(x_cursor>1) = 1;
y_cursor(y_cursor<0) = 0;
y_cursor(y_cursor>1) = 1;

% wyznaczenie środka (centralne położenie twarzy - średnia ze współrzędnych)
x_mean = mean(x_cursor);
y_mean = mean(y_cursor);

% wykres trajektorii - osobno x i y po kalibracji
figure;
subplot(2,1,1)
plot(x_cursor,'-b.')
xlabel('cursor X')
title('trajektoria po kalibracji')
subplot(2,1,2)
plot(y_cursor,'-b.')
xlabel('cursor Y')

%% Eksport rezultatów kalibracji do pliku MAT uzywanego przez myAlgorithmCAMMOUSE.m
save calib1data CDx CDy offset_x offset_y x_mean y_mean

