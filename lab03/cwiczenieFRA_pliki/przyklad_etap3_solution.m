%% Przykład - podstawowy framework aplikacji, cz.3 
%
% UWAGI: zmiany w stosunku do "przyklad_etap1.m" oznaczone "SOLUTION"
% 
% WERSJA: 01.02.2023, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2022b
% 
clear all;close all;clc

%% Parametry
% - parametry umieszczone w strukturze (pomoc: doc struct)
parametry            = [];
parametry.filename   = 'testVideo1.avi';      % nazwa pliku wejściowego video
parametry.nr         = 1;                     % numer ramki dla której pobierany będzie zrzut ekranu

parametryExportu     = [];                    % SOLUTION
parametryExportu.nazwapliku = 'test3.txt';    % SOLUTION nazwa pliku wyjściowego TXT


%% Inicjalizacja 
%-źródło danych
vidObj          = VideoReader(parametry.filename);% pomoc: doc VideoReader

%-wizualizacja
% - okno figure zawierające 2 przyciski
%   - przycisk stop: kończy przetwarzanie danych
%   - przycisk pause: wstrzymuje przetwarzanie danych 
%   - każdy przycisk ma zdefiniowany uchwyt do funkcji, która jest
%     wywoływana po jego naciśnięciu, więcej informacji w kodzie funkcji 
%     "handleButtons_0.m"
stopCond = 1;
pauseCond= 0;
videoPlayer  = figure;      % uchwyt do okna GUI
przyciskStop=uicontrol(videoPlayer,'units','normalized','position',[0 0 0.2 0.05],...
                        'string','stop','UserData',stopCond,...
                        'callback',@(src, event) handleButtons_0(src, event));  
przyciskPause=uicontrol(videoPlayer,'units','normalized','position',[0.3 0 0.2 0.05],...
                        'string','pause','UserData',pauseCond,...
                        'callback',@(src, event) handleButtons_0(src, event));  

                    
% SOLUTION inicjalizacja obiektu klasy "eksportPrzyklad"
exportObj = eksportPrzyklad(parametryExportu);

%% PĘTLA PRZETWARZANIA
disp('Początek przetwarzania')
%-pętla przetwarzania
iter        = 1;                % zmienna zawierająca numer iteracji pętli  
framedbg    = [];
while (iter<vidObj.NumFrames & stopCond)   
    stopCond =przyciskStop.UserData; %pobranie stanu przycisku
    pauseCond=przyciskPause.UserData;%pobranie stanu przycisku

    if pauseCond==0
        
        % Wczytanie danych
        vidFrame    = readFrame(vidObj);% wczytanie ramki obrazu z pliku video  
                
        % Wywołanie algorytmu wanalizy obrazu 
        % (konwersja rgb2gray)
        obrazwy      = rgb2gray(vidFrame);           %SOLUTION
        pixelsum     = sum(sum(obrazwy));            %SOLUTION

        % Wizualizacja rezultatów
        subplot(1,2,1);
        imshow(obrazwy)
        title(['Ramka nr ' num2str(iter)])
             
        % Zapis rezultatów
        dane_do_eksportu      = [];                         % SOLUTION
        dane_do_eksportu.iter = iter;                       % SOLUTION   
        dane_do_eksportu.result = pixelsum;                 % SOLUTION   
        status = exportObj.eksportujDane(dane_do_eksportu); % SOLUTION        
        
        % ---
        iter = iter + 1;   

        % kod pomocniczy do sprawozdania
        if (iter-1)==parametry.nr
            title('Rezultat algorytmu (solution)')
            framedbg = getframe(videoPlayer);            
        end          
    end
    pause(0.01)
    drawnow
end

% Terminacja - zamknięcie okna i usunięcie obiektów
close(videoPlayer);
clear exportObj                                             % SOLUTION
disp('Zakończenie przetwarzania - obiekty usunięte')
%-dla VideoReader nie ma potrzeby usuwania obiektu    

% Zrzut ekranu - zapis do pliku
if ~isempty(framedbg)
    framedbgRGB = frame2im(framedbg);
    imwrite(framedbgRGB, 'przyklad_etap3_printscreen.jpg')
else
    warning('Problem z zapisem zrzutu ekranu do pliku - pusty obraz')
end
