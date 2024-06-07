%% Jarzmo testowe - jarzmo testowe - detekcja pulsu
% 
% UWAGI:
%
% WERSJA: 03.12.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
% 
clear all;close all;clc

%% PARAMETRY
parametryImportu            = [];
%VIDEO: parametryImportu.filename   = 'testVideo1.avi';    % nazwa TWOJEGO pliku wejściowego video
% -------------------------------------------------------
% UZUPEŁNIJ_1 - ustaw parametry akwizycji aby uzyskac stabline FPS > 10
parametryImportu.nr         = 1;                    % numer kamery
parametryImportu.resolution = '320x240';            % rozdzielczość akwizycji (dozwolne rozdzielczości wyświetlane w oknie poleceń po uruchomieniu skryptu)
parametryImportu.skalowanie = [120 160];            % skalowanie obrazu (uwaga: najpierw oś y później x)
% -------------------------------------------------------
         
parametryAlg         = [];                          % struktura parametrów algorytmu przetwarzania video
%parametryAlg.calibfilename   = 'calib1data.mat';    % nazwa pliku z danymi kalibracji 
%parametryAlg.funkcjasterowania = @sterowanie1;      % nazwa funkcji obliczającej sterowanie kursorem

parametryEksportu  = [];                        % struktura parametrów funkcji eksportu danych
parametryEksportu.nazwapliku = 'dane_puls.txt';      % - nazwa pliku wyjściowego txt

%% Inicjalizacja 
%-źródła danych
%VIDEO: vidObj          = myDataSourceVid(parametryImportu);
vidObj          = myDataSourceCamMouse(parametryImportu);

%-algorytm przetwarzania video i jego parametry
processVideoObj = myAlgorithmPULS(parametryAlg);

%-eksport danych
exportObj        = myExportDataPULS(parametryEksportu);

%-wizualizacja danych
showObj          = myVisualizationPULS();

% ------------------------------------------------------------------------
% poniżej tej linii nie powinno się zmieniać kodu
% ------------------------------------------------------------------------
%% PĘTLA PRZETWARZANIA
disp('Początek przetwarzania')
%-pętla przetwarzania
iter        = 1;                % zmienna zawierająca numer iteracji pętli 
t2          = NaN;
while (iter<vidObj.nFrames & showObj.stopCond)    
    if showObj.pauseCond==0
        tic;
        
        % Wczytanie i skalowanie ramki obrazu    
        vidFrame    = vidObj.pobierzDane;
        vidFrame    = imresize(vidFrame,parametryImportu.skalowanie);        
        
        % Uruchomienie algorytmu analizy obrazu 
        outVidData      = processVideoObj.process(vidFrame);
        
        % Eksport rezultatów
        dane_do_eksportu                    = [];
        dane_do_eksportu.iter               = iter;        
        dane_do_eksportu.t2                 = t2;
        dane_do_eksportu.outVidData         = outVidData;  
        exportObj.eksportujDane(dane_do_eksportu);
        
        % Wizualizacja danych
        dane_do_wizualizacji                = [];
        dane_do_wizualizacji.iter           = iter;        
        dane_do_wizualizacji.outVidData     = outVidData;  
        showObj.wyswietlDane(dane_do_wizualizacji);
                
        % ---
        t2   = toc;
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


