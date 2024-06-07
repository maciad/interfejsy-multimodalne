%% Transfer Learning
%  WERSJA: 16.11.2020, Jaromir Przybylo (przybylo@agh.edu.pl), R2020a
%  UPDATE: 01.12.2023, Jaromir Przybylo (przybylo@agh.edu.pl), R2023b
%
clear all;close all;clc

%% (1) Przygotowanie danych do uczenia sieci - zbior uczacy
% - obiekt imageDatastore (poszczegolne klasy obiektow w podkatalogach)
% - podzial na zbior uczacy i walidujacy (70%/30%)
images = imageDatastore('daneUczace',...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');
[trainingImages,validationImages] = splitEachLabel(images,0.7,'randomized');

%% (2) Wizualizacja przykladowych danych uczacych
numTrainImages = numel(trainingImages.Labels);
idx = randperm(numTrainImages,16);
figure
for i = 1:16
    subplot(4,4,i)
    [I, finfo] = readimage(trainingImages,idx(i));
    imshow(I)
    title(char(finfo.Label))
end

%% (3) Wczytanie gotowej sieci AlexNet
net = alexnet;
% Siec byla uczona obrazami przeskalowanymi do mniejszego rozmiaru
inputSize = net.Layers(1).InputSize

%% (4) Dostosowanie sieci do nowego uczenia
% Ostatnie warstwy sieci konwolycyjnych realizuja klasyfikacje (sa to
% klasyczne warstwy sieci neuronowej - polaczenia kazdy-z-kazdym).
% Daje to mozliwosc latwego dostosowania juz nauczonej sieci do realizacji
% nowego zadania. 
% Poprzez zastapienie ostatnich 3 warstw nowymi warstwami i przeprowadzenie
% uczenia na nowym zbiorze obrazow uczacych, mamy mozliwosc "douczenia"
% sieci aby rozpoznawala nowy zbior klas. 
% Poniewaz nowy zbior uczacy zazwyczaj zawiera niewielka liczbe obrazow,
% poczatkowe warstwy sieci (konwolucyjne...) zmieniaja swoje wagi w
% niewielkim stopniu. Mozna tez ew zablokowac uczenie poczatkowych warstw.
% Dzieki temu, wyksztalcone detektory cech pozostaja niezmienione.
% "Douczamy" tylko ostatnie warstwy realizujace klasyfikacje.
layersTransfer = net.Layers(1:end-3);                  % wybieramy wszystkie warstwy oprócz 3 ostatnich
numClasses = numel(categories(trainingImages.Labels)); % liczba nowych klas ze zbioru uczacego
% nowa struktura sieci - poprzednie warstwy + 3 nowe, ostatnie
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

%% (5) Przygotowanie danych do uczenia sieci - data augmentation, resize...
% Ze wzgledu na niewielka liczbe obrazow uczacych, moga wystapic negatywne
% efekty uczenia sieci (np. uczenie "na pamiec"). Dlatego stosuje sie
% technike "data augmentation", ktora sztucznie zwieksza liczbe obrazow
% uczacych poprzez dodanie niewielkich translacji, rotacji...
pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),trainingImages, ...
    'DataAugmentation',imageAugmenter);

augimdsValidation = augmentedImageDatastore(inputSize(1:2),validationImages);

%% (6) Uczenie sieci
% - sprawozdaniu zamieść wykres "Accuracy" oraz "Loss" z procesu uczenia.

% - w procesie uczenia wykorzystujemy zarowno zbior uczacy jak i walidujacy

% - parametry uczenia
miniBatchSize = 10;
numIterationsPerEpoch = floor(numel(trainingImages.Labels)/miniBatchSize);
options = trainingOptions('sgdm',...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',4,...
    'InitialLearnRate',1e-4,...
    'Verbose',false,...
    'Plots','training-progress',...
    'ValidationData',augimdsValidation,...
    'ValidationFrequency',numIterationsPerEpoch);

% - uczenie (proces ten moze potrwac dlugo - w zaleznosci od ilosci danych)
netTransfer = trainNetwork(augimdsTrain,layers,options);

%- eksport sieci do pliku MAT
save nauczonaSiec netTransfer

%% (7) Testowanie sieci na danych walidacyjnych
%- zanotuj dokladnosc klasyfikacji
[YPred,scores] = classify(netTransfer,augimdsValidation);

YValidation = validationImages.Labels;
accuracy = 100*mean(YPred == YValidation);
disp(['Dokladnosc (zbior walidujacy) = ' num2str(accuracy,'%2.1f'), '%'])

%% (8) Testowanie sieci - osobny zbior testowy
% - zanotuj dokladnosc klasyfikacji i macierz pomyłek
% - które obiekty są źle rozpoznawane i dlaczego
testImages = imageDatastore('daneTestowe',...
    'IncludeSubfolders',true,...
    'LabelSource','foldernames');
augTest = augmentedImageDatastore(inputSize(1:2),testImages);% resize

[YPredT,scoresT] = classify(netTransfer,augTest);
YValidationT = testImages.Labels;
accuracyT = 100*mean(YPredT == YValidationT);
disp(['Dokladnosc (zbior testowy) = ' num2str(accuracyT,'%2.1f'), '%'])

%-macierz pomylek (wyeksportuj do sprawozdania)
% - ktore klasy sa ze soba mylone najczeciej?
fh=figure;
confusionchart(YValidationT,YPredT)
%{
saveas(fh,['macierz_pomylek.png'])
%}

