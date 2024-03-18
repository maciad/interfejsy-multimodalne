%% Jarzmo testowe - szablon do uzupelnienia
%  - akwizycja obrazu z kamery: myDataSourceCamSolution.m
%  - 
% UWAGI:
%
% WERSJA: 01.02.2023, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2022b
% 
clear all;close all;clc

%% PARAMETRY
parametryImportu            = [];
% -------------------------------------------------------
% UZUPEŁNIJ_1a - uzupełnij parametry importu (nr kamery)
parametryImportu.nr = 1 ;    % numer kamery
% -------------------------------------------------------

parametryAlg         = [];                  % przykładowa struktura parametrów algorytmu przetwarzania video
parametryAlg.nr      = 1;                   % - numer komponentu obrazu (1-3)

parametryEksportu  = [];                    % struktura parametrów funkcji eksportu danych
% -------------------------------------------------------
% UZUPEŁNIJ_1b - uzupełnij parametry eksportu (nazwa pliku AVI)
% -------------------------------------------------------
parametryEksportu.nazwapliku = 'test_harness_1.avi' ;   % - nazwa pliku wyjściowego AVI

%% Inicjalizacja 
%-źródła danych
% -------------------------------------------------------
% UZUPEŁNIJ_2a - zainicjalizuj obiekt pobierający dane z kamery (klasa myDataSourceCam)
vidObj = myDataSourceCam(parametryImportu);
% -------------------------------------------------------

%-algorytm przetwarzania video i jego parametry
processVideoObj = myAlgorithmTemplate(parametryAlg);

%-eksport danych
% -------------------------------------------------------
% UZUPEŁNIJ_2b - zainicjalizuj obiekt eksportujący dane do pliku AVI (klasa myExportDataVid)
exportObj = myExportDataVid(parametryEksportu);
% -------------------------------------------------------

%-wizualizacja danych
showObj          = myVisualization0();

% ------------------------------------------------------------------------
% poniżej tej linii nie powinno się zmieniać kodu
% ------------------------------------------------------------------------
%% PĘTLA PRZETWARZANIA
disp('Początek przetwarzania')
%-pętla przetwarzania
iter        = 1;                % zmienna zawierająca numer iteracji pętli  
while (iter<vidObj.nFrames & showObj.stopCond)    
    if showObj.pauseCond==0
        
        % Wczytanie ramki obrazu    
        vidFrame    = vidObj.pobierzDane;
                
        % Uruchomienie algorytmu analizy obrazu 
        outVidData      = processVideoObj.process(vidFrame);
        
        % Eksport rezultatów
        dane_do_eksportu                    = [];
        dane_do_eksportu.iter               = iter;        
        dane_do_eksportu.outVidData         = outVidData;  
        exportObj.eksportujDane(dane_do_eksportu);
        
        % Wizualizacja danych
        dane_do_wizualizacji                = [];
        dane_do_wizualizacji.iter           = iter;        
        dane_do_wizualizacji.outVidData     = outVidData;  
        showObj.wyswietlDane(dane_do_wizualizacji);
                
        % ---
        iter = iter + 1;         
    end
    pause(0.01)
    drawnow
end
%-zamknięcie okna i usunięcie obiektów
delete(vidObj);
delete(processVideoObj);
delete(exportObj);
delete(showObj);
disp('Zakończenie przetwarzania - obiekty usunięte')

T     = readtable('test_harness_1.txt'); % wczytanie pliku TXT jako tabela - zamiast out.txt podaj swoją nazwę pliku
ts    = T.timestamp;           % wybór z tabeli T kolumny zwierającej timestamp
dts = diff(ts);                       % wyznaczenie różnicy czasu między ramkami
FPS = median(dts)
