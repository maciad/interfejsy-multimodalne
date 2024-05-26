%% Jarzmo testowe - AR
%  - 
% UWAGI:
%
% WERSJA: 01.12.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
% 
clear all;close all;clc

%% PARAMETRY
parametryImportu            = [];
%VIDEO: parametryImportu.filename   = 'testVideo1.avi';    % nazwa TWOJEGO pliku wejściowego video
% -------------------------------------------------------
% UZUPEŁNIJ_1 - dobierz parametry akwizycji
parametryImportu.nr         = 1;                    % numer kamery
parametryImportu.resolution = '640x480';            % rozdzielczość akwizycji (dozwolne rozdzielczości wyświetlane w oknie poleceń po uruchomieniu skryptu)
                                                    % uwaga - musi być taka
                                                    % sama jak podczas
                                                    % kalibracji!
% -------------------------------------------------------

parametryAlg         = [];                  % przykładowa struktura parametrów algorytmu przetwarzania video
parametryAlg.calibfilename  = 'parametryKalibracji.mat';% nazwa pliku z danymi kalibracji kamery
parametryAlg.pointsfilename = 'mojePunkty.mat';         % nazwa pliku z wybranymi punktami planszy
parametryAlg.skalaZ         = 25;                       % skala w osi Z obiektu

%parametryEksportu    = [];                  % struktura parametrów funkcji eksportu danych

%% Inicjalizacja 
%-źródła danych
%VIDEO: vidObj          = myDataSourceVid(parametryImportu);
vidObj          = myDataSourceCamMouse(parametryImportu);

%-algorytm przetwarzania video i jego parametry
processVideoObj = myAlgorithmAR(parametryAlg);

%-eksport danych
%exportObj        = myExportDataVidSolution(parametryEksportu);

%-wizualizacja danych
showObj          = myVisualizationAR();

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
        %dane_do_eksportu                    = [];
        %dane_do_eksportu.iter               = iter;        
        %dane_do_eksportu.outVidData         = outVidData;  
        %exportObj.eksportujDane(dane_do_eksportu);
        
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
%delete(exportObj);
delete(showObj);
disp('Zakończenie przetwarzania - obiekty usunięte')


