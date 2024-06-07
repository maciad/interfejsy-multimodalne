%% Tworzenie bazy obrazów uczących - rejestracja obrazów z kamery
% WERSJA: 16.11.2020, Jaromir Przybylo (przybylo@agh.edu.pl), R2020a
%
clear all;close all;clc

%% Konfiguracja kamery i katalogow wyjsciowych
% - podkatalogi wyjsciowe sa automatycznie tworzone
% - w przypadku gdy podkatalog istnieje poprzednie pliki nie sa usuwane,
%   ale moga zostac nadpisane
% - nagrywanie odbywa się z opóźnieniem około 0.5 sec tak aby uchwycić
%   różne widoki obiektu
nazwaObiektu = 'obiektA';   % nazwa obiektu (ustaw odpowiednio - bez polskich znakow!)
typZbioru    = 0;           % typ zbioru: 0 - uczacy, 1 - testowy
liczbaZdjec  = 30;          % liczba obrazów dla danego obiektu                            
nrKamery     = 1;           % ustawic odpowiedni nr kamery


IMAQ         = 0; % w przypadku gdy interfejs webcam nie działa można użyć interfejsu imaq
                  % w tym celu należy ustawić zmienną IMAQ = 1 oraz
                  % odpowiednio zmienić parametry videoinput poniżej
if IMAQ==1
    camera       = videoinput('winvideo', nrKamery, 'RGB24_320x240');% ustawic odpowiedni nr kamery oraz rozdzielczosc
    %camera       = videoinput('linuxvideo', nrKamery, 'YUY2_320x240');% ustawic odpowiedni nr kamery oraz rozdzielczosc
else
    camera       = webcam(nrKamery);
end

% ===========================================================================
% nie zmieniaj kodu ponizej
% ===========================================================================
% preview(cam);                 % podgląd obrazu z kamery
% camera.AvailableResolutions   % obsługiwane rozdzielczosci dla webcam
% imaqhwinfo                    % dostępne żródła wideo dla videoinput
% dev_info = imaqhwinfo('winvideo',1).SupportedFormats  % obsługiwane rozdzielczosci dla videoinput

if IMAQ==1
    camera.FramesPerTrigger = 1;
    camera.TriggerRepeat = inf;
    camera.ReturnedColorspace = 'rgb';
else
    camera.Resolution = '320x240';
end

if typZbioru==0
    outputFolder = fullfile('daneUczace/', nazwaObiektu);  % nazwa podkatalogu do zapisu danych
else
    outputFolder = fullfile('daneTestowe/', nazwaObiektu); % nazwa podkatalogu do zapisu danych
end
if exist(outputFolder)~=7
    mkdir(outputFolder)
end

%% Rejestracja danych w trybie ciaglym (po kazdej ramce pauza ~0.5sec)
figure
keepRolling = true;
set(gcf,'CloseRequestFcn','keepRolling = false; closereq');
iter=1;maxIter = liczbaZdjec;

if IMAQ==1
    start(camera);
end
if typZbioru==0
    str1 = ['zbiór uczący, ' nazwaObiektu];
else
    str1 = ['zbiór testowy, ' nazwaObiektu];
end

while keepRolling & iter <= maxIter 
    if IMAQ==1
        im = peekdata(camera,1);
    else
        im = snapshot(camera);
    end
    if ~isempty(im)
        im1     = imresize(im, [240 320]);
        image(im1)

        title([str1 ', ramka ' num2str(iter) ' z ' num2str(maxIter)]);
        iter=iter+1;
        drawnow

        imwrite(im1, fullfile(outputFolder,[nazwaObiektu '_' num2str(iter) '.png']));
    end
    pause(0.5)
end
if IMAQ==1
    stop(camera)
end
% Usuniecie obiektu kamery 
% (wymagane bo innaczej MATLAB nie zwolni zasobow sprzetowych)
clear camera
close all
