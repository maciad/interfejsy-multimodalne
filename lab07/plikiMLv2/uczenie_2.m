%% Uczenie maszynowe: uczenie i testowanie klasyfikatorów
%
% WERSJA: 12.11.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
%
clear all;close all;clc

%% (0) Uruchom narzędzie "classificationLearner" i postępuj wg instrukcji do ćwiczenia
% - przetestuj różne klasyfikatory
% - wygeneruj kod dla nalepszego klasyfikatora
classificationLearner

%% (1) Wczytanie danych uczących i testowych
load trainingAndTestData

%% (2) Uruchom wygenerowany kod tworzący klasyfikator dla danych uczących
% - tworzenie klasyfikatora przy pomocy wygenerowanej funkcji
[trainedClassifier, validationAccuracy] = trainClassifier(formantsTableTraining);
% - sprawdzenie klasyfikatora na danych uczących (cały zbiór)
trainResults = trainedClassifier.predictFcn(formantsTableTraining);

% macierz pomylek
CTrain = confusionmat(formantsTableTraining.vowel,trainResults)

% dokładność klasyfikatora dla CAŁEGO zbioru uczącego
accuracyTrain = mean(cellfun(@eq, trainResults, formantsTableTraining.vowel))
%   Zwróć uwagę że "validationAccuracy" zwracana podczas uczenia
%   klasyfikatora "trainClassifier" to nie to samo co "accuracyTrain"
%   Wyjaśnij dlaczego tak jest?

%% (3) Sprawdź klasyfikator na danych testowych
% - sprawdzenie klasyfikatora na danych testowych
testResults = trainedClassifier.predictFcn(formantsTableTest);

% macierz pomylek
CTst = confusionmat(formantsTableTest.vowel,testResults)

% dokładność klasyfikatora
accuracy1 = mean(cellfun(@eq,testResults, formantsTableTest.vowel))
