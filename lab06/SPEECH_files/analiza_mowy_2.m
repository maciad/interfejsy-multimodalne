%% Analiza sygnału mowy, cz2
% - utworzony: 30.10.2020, R2020a, J.Przybyło, AGH
% - zmodyfikowany: 06.11.2020
%
clear all;close all;clc

%% (0) Parametry
N = 3;                              % liczba formantów brana pod uwagę
AUDIOPATH='audioFiles';            % katalog bazy plików audio

%% (1)  Przetwarzanie wsadowe plików - obiekt audioDatastore 
% - zapoznaj sie w dokumentacji z obiektem "audioDatastore"
fds = audioDatastore(AUDIOPATH,'FileExtensions','.wav');% obiekt datastore

% inicjalizacja tablic
formants  =zeros(length(fds.Files),N);  % tablica formantów
vowelClass=cell(length(fds.Files),1);   % tablica etykiet
personID  =cell(length(fds.Files),1);   % tablica id osób
sampleName=cell(length(fds.Files),1);   % tablica nazw plików
fsTab     =zeros(length(fds.Files),1);  % tablica częstotliwości próbkowania
i = 1;
while hasdata(fds)
    % wczytanie kolejnego pliku audio
    [y,info]      = read(fds);
    fs            = info.SampleRate;
    if size(y, 2)>1
        y = y(:,1); % wybierz tylko jeden kanał
    end
    
    % preprocessing sygnału
    % - okno czasowe Hamminga
    % - filtr preemfazy
    y1           = y.*hamming(length(y));
    preemph      = [1 0.63];
    y2           = filter(1,preemph,y1);
    
    % parsing nazwy pliku
    % Uwagi: identyfikator zbioru danych zakłada następującą strukturę
    % nazwy plików: <nazwasamogłoski>_<nr>_<kodOsoby>.wav np. 'o_1_mjk.wav'
    [~,fname1,~] = fileparts(info.FileName);
    fname2       = split(fname1,'_');
    vowelName    = fname2{1};
    personId     = fname2{3};        

    % wyznaczanie formantów
    ff           = estimate_formants(y2, fs);
    
    % zapamiętanie danych w tablicach
    formants(i,:) = ff(1:N);
    vowelClass{i} = vowelName;
    personID{i}   = personId; 
    sampleName{i} = fname1;
    fsTab(i)      = fs;
    i = i + 1;
end
formantsTable = table(vowelClass, personID, formants(:,1), formants(:,2), formants(:,3),...
            'VariableNames',{'vowel','person','F1','F2','F3'},'RowNames', sampleName);
disp(formantsTable) 


%% (2) Analiza i wizualizacja danych
uWovels = unique(vowelClass);           % unikalne nazwy samogłosek
nrOfVowels = length(uWovels);           % liczba samogłosek


colors1='rgbcmky';
figure;
hold on
% pętla po kolejnych samogłoskach
legendstr={};k=1;
for i=1:nrOfVowels
    % wybór elementów, wektor logiczny
    select1 = strcmp(vowelClass,uWovels(i));            
    
    % UZUPELNIJ_1
    % wybór elementów (formanty dla samogłoski)
    F1      = formants(select1,1);
    F2      = formants(select1,2);
    F3      = formants(select1,3);
    
    % UZUPELNIJ_2
    % obliczenie średniej wartości formantu dla danej samogłoski
    meanF1  = mean(F1);
    meanF2  = mean(F2);
    meanF3  = mean(F3);
    
    % Wizualizacja kolejnych samogłosek i ich średnich
    plot3(F1, F2, F3, ['o' colors1(i)]);
    plot3(meanF1, meanF2, meanF3, ['x' colors1(i)]);
    legendstr{k}=uWovels{i};k=k+1;
    legendstr{k}=['mean: ' uWovels{i}];k=k+1;
end
hold off
legend(legendstr)
grid on
view(45, 45);
xlabel('f1')
ylabel('f2')
zlabel('f3')

%% opc. (3) Analiza i wizualizacja danych (pod kątem osób)
uPerson = unique(personID);           % unikalne id osób
nrOfPersons = length(uPerson);        % liczba osob

colors1='rgbcmky';
figure;
hold on
% pętla po kolejnych osobach
legendstr={};k=1;
for i=1:nrOfPersons
    % UZUPELNIJ_3
    % wybór elementów, wektor logiczny
    select1 = strcmp(personID, uPerson(i));
    
    % wybór elementów (formanty dla osoby)
    F1      = formants(select1,1);
    F2      = formants(select1,2);
    F3      = formants(select1,3);
    
    % obliczenie średniej wartości formantu dla danej osoby
    meanF1  = mean(F1);
    meanF2  = mean(F2);
    meanF3  = mean(F3);
    
    % Wizualizacja kolejnych samogłosek i ich średnich
    plot3(F1, F2, F3, ['o' colors1(i)]);
    plot3(meanF1, meanF2, meanF3, ['x' colors1(i)]);
    legendstr{k}=uPerson{i};k=k+1;
    legendstr{k}=['mean: ' uPerson{i}];k=k+1;
end
hold off
legend(legendstr)
grid on
view(45, 45);
xlabel('f1')
ylabel('f2')
zlabel('f3')
