%% Jarzmo testowe - detekcja ruchu MHI
% 
% UWAGI:
%
% WERSJA: 12.10.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
% 
clear all;close all;clc

%% PARAMETRY
parametryImportu            = [];
parametryImportu.filename   = 'testVideo1.avi';    % nazwa TWOJEGO pliku wejściowego video

parametryAlg         = [];                  % struktura parametrów algorytmu przetwarzania video
% -------------------------------------------------------
    % UZUPEŁNIJ_1 - dobierz parametry algorytmu weryfikacji atrybutów
    % twarzy (weryfikacja1.m)
    parametryAlg.proporcjaObszaruTwarzyiNosa = 0.09;
    parametryAlg.odlegloscUstaSrodekTwarzy   = 35;
% -------------------------------------------------------

parametryEksportu  = [];                    % struktura parametrów funkcji eksportu danych
parametryEksportu.nazwapliku = 'tmp.txt';   % - nazwa pliku wyjściowego txt

%% Inicjalizacja 
%-źródła danych
vidObj          = myDataSourceVid(parametryImportu);

%-algorytm przetwarzania video i jego parametry
processVideoObj = myAlgorithmTRACK(parametryAlg);

%-eksport danych
exportObj        = myExportData(parametryEksportu);

%-wizualizacja danych
showObj          = myVisualizationTRACK();

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


