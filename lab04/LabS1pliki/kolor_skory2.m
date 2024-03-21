%% Przygotowanie danych do tworzenia modelu skory
% CREATED: Jaromir Przybylo, 26.10.2015, R2015a
%
addpath('BazaObrazow')

%% Wczytanie przykladowego obrazu
testowy = imread('testowy_0_0000.jpeg');

%% Wybor z obrazu fragmentu zawierajacego wycinek skory
figure;
imshow(testowy)
bw = roipoly;
% Zaznacz interaktywnie jak najwiekszy fragment twarzy,
% zawierajacy kolor skory
% (aby zaakceptowac zaznaczenie, dwukrotnie kliknij 
%  na zaznaczonym obszarze)

%-zapis do pliku MAT utworzonej maski
save testowy_0_0000_roibw bw

%% Tworzenie drugiego modelu skory
model2 = createSkinModel('testowy_0_0000.jpeg',bw);


