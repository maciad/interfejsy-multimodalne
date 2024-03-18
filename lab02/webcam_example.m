%% Przykład akwizycji obrazu z kamery przy użyciu interfejsy WebCam
% 
% UWAGI:
% > przykład wymaga zainstalowania dodatku (AddOn):
%   MATLAB Support Package for USB Webcams
% WERSJA: 17.09.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
% 
clear all;close all;clc

%% Inicjalizacja
camera       = webcam(1);           % ustawic odpowiedni nr kamery

% preview(cam); % podgląd obrazu z kamery
camera.AvailableResolutions

camera.Resolution = '1280x720';      % ustawić rozdzielczosć obsługiwaną przez kamerę

%% Akwizycja obrazów
figure

keepRolling = true;
iter =1;
ile_ramek = 100;
set(gcf,'CloseRequestFcn','keepRolling = false; closereq');
elapsedTime=zeros(1,ile_ramek);

while keepRolling & iter<ile_ramek
    tic;
    im = snapshot(camera);
    elapsedTime(1, iter) = toc;
    if ~isempty(im)        
        image(im)              
        title(['ramka ' num2str(iter)]);
        xlabel('aby zakończyć przykład zamknij okno lub poczekaj')
        drawnow
    end
    iter=iter+1;    
end
disp(['FPS = ' num2str(1/mean(elapsedTime))])
% Usuniecie obiektu kamery 
% (wymagane bo innaczej MATLAB nie zwolni zasobow sprzetowych)
clear camera

close all
