%% Uczenie maszynowe cz.3 - rozpoznawanie mówcy
%
% WERSJA: 03.12.2021, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2021b
% Na podstawie przykładu: Speaker Identification Using Pitch and MFCC
% Zależności: isVoicedSpeech.m
%
clear all;close all;clc

%% Zapoznaj się z przykładem w dokumentacji (opis algorytmu, wykrozystanych cech)
%  - W sprawozdaniu wyjaśnij co to są współczynniki MFCC?
doc Speaker Identification Using Pitch and MFCC

%% (0) Parametry
%N = 3;                              % liczba formantów brana pod uwagę
AUDIOPATH='audioFiles';             % katalog bazy plików audio

%% (1)  Przetwarzanie wsadowe plików - obiekt audioDatastore 
% - Zwróć uwagę, że zamiast formantów używamy tutaj współczynników pitch i MFCC
% - Wykorzystujemy sposób tworzenia bazy jak w poprzednich przykładach
%   ćwiczenia. 
%   W przykładzie w dokumentacji, skorzystano z innego sposobu - użyto
%   funkcjonalności "audioDatastore" pozwalającej automatycznie wyznaczyć
%   etykiety dla danych na podstawie nazwy katalogu w którym pliki danych
%   są umieszczone.
% - Zapoznaj się z dokumentacją funkcji:"mfcc", "pitch"
% - Zwróć uwagę, że wektor cech dla jednego przykładu zawiera wiele wierszy
%   danych (wynika to z przetwazania sygnału w oknie przesuwnym)
%   Dlatego, dla każdego takiego wiersza, jest powielana informacja o
%   etykiecie.
fds = audioDatastore(AUDIOPATH,'FileExtensions','.wav');% obiekt datastore

% tablice danych
features   = [];    % tablica cech
vowelClass = [];    % tablica etykiet
personID   = [];    % tablica id osób
i = 1;
while hasdata(fds)
    % wczytanie kolejnego pliku audio
    [y,info]      = read(fds);
    fs            = info.SampleRate;
    if size(y, 2)>1
        y = y(:,1); % wybierz tylko jeden kanał
    end
    
      
    % parsing nazwy pliku
    % Uwagi: identyfikator zbioru danych zakłada następującą strukturę
    % nazwy plików: <nazwasamogłoski>_<nr>_<kodOsoby>.wav np. 'o_1_mjk.wav'
    [~,fname1,~] = fileparts(info.FileName);
    fname2       = split(fname1,'_');
    vowelName    = cellstr(fname2{1});
    personId     = cellstr(fname2{3});        

    % wyznaczanie cech MFCC i pitch
    windowLength = round(0.03*fs);
    overlapLength = round(0.025*fs);
    melC = mfcc(y,fs,'Window',hamming(windowLength,'periodic'),'OverlapLength',overlapLength);
    f0 = pitch(y,fs,'WindowLength',windowLength,'OverlapLength',overlapLength);
    feat = [melC,f0];
    
    % pominięcie cech dla których nie wykryto mowy (f. pomocnicza)
    voicedSpeech = isVoicedSpeech(y,fs,windowLength,overlapLength);    
    feat(~voicedSpeech,:) = [];

    label = repelem(personId,size(feat,1));
    vowellabel = repelem(vowelName,size(feat,1));

    % zapamiętanie danych w tablicach
    features = [features;feat];
    personID = [personID,label];
    vowelClass = [vowelClass,vowellabel];

    i = i + 1;
end

%% (2) normalizacja cech 
% - konieczna ponieważ cechy MFCC i pitch mają różną skalę/zakres
M = mean(features,1);
S = std(features,[],1);
features = (features-M)./S;

%% (3) Podział na zbiór uczący i testowy przy pomocy prostej walidacji 
%  (zbiór dzielony losowo na rozłączne zbiory)
zbiorUczacyP = 0.7;% proporcje podziału zbioru: 70%/30%
CV = cvpartition(personID,'Holdout',1-zbiorUczacyP)
CV.training

% zbiór uczący i zbiór testowy 2
featuresTraining  = features(CV.training,:);
featuresTest      = features(CV.test,:);
personIDlabelTraining = personID(CV.training);
personIDlabelTest     = personID(CV.test);

% liczebności zbiorów (zanotuj w sprawozdaniu)
trainingNo = sum((CV.training)) 
testNo     = sum((CV.test)) 

%% (4) Uczenie klasyfikatora
% - opc. sprawdź inne klasyfikatory
trainedClassifier = fitcknn( ...
    featuresTraining, ...
    personIDlabelTraining, ...
    'Distance','euclidean', ...
    'NumNeighbors',5, ...
    'DistanceWeight','squaredinverse', ...
    'Standardize',false, ...
    'ClassNames',unique(personIDlabelTraining));

%% (5) Sprawdzenie klasyfikatora na danych uczących i testowych
trainResults = trainedClassifier.predict(featuresTraining);

% macierz pomylek
CTrain = confusionmat(personIDlabelTraining,trainResults)

% dokładność klasyfikatora dla CAŁEGO zbioru uczącego
accuracyTrain = mean(cellfun(@strcmp, trainResults, personIDlabelTraining'));
disp(['Dokładność - zbiór uczący: ' num2str(accuracyTrain*100) ' %'])


% Zbiór testowy
testResults = trainedClassifier.predict(featuresTest);

% macierz pomylek
CTest = confusionmat(personIDlabelTest,testResults)

% dokładność klasyfikatora dla CAŁEGO zbioru uczącego
accuracyTest = mean(cellfun(@strcmp, testResults, personIDlabelTest'));
disp(['Dokładność - zbiór testowy: ' num2str(accuracyTest*100) ' %'])

