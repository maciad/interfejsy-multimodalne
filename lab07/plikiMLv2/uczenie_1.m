%% Uczenie maszynowe: import i przygotowanie danych.
%
% WERSJA: 12.11.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
%
clear all;close all;clc

%% (0) Parametry
N = 3;                              % liczba formantów brana pod uwagę
AUDIOPATH='audioFiles';             % katalog bazy plików audio

%% (1)  Przetwarzanie wsadowe plików - obiekt audioDatastore 
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


%% (2) Liczebność elementów dla danej klasy
uWovels = unique(vowelClass);           % unikalne nazwy samogłosek
nrOfVowels = length(uWovels);           % liczba samogłosek
nrOfexamples = zeros(nrOfVowels,1);     % rezultat: liczba elementów danej klasy
for i=1:nrOfVowels                      % iteracja po kolejnych samogłoskach
    select1 = strcmp(vowelClass,uWovels(i));            % wybór elementów (określona samogłoska), wektor logiczny zwierający 0 i 1
    % UZUPELNIJ_1 (wykorzystaj sumowanie)
    %nrOfexamples(i) = ????;
end
table_nrOfexamples = table(uWovels, nrOfexamples);
disp(table_nrOfexamples)
% Czy liczebność dla każdej grupy jest podobna?

% Poniżej kod pokazujący w jaki sposób można uprościć wyznaczanie
% liczebności elementów danej klasy
% - zapoznaj się ze składnią funkcji "unique"
%   [C,ia,ic] = unique(___)
%   Co to jest "ia" i "ic"?
% - zapoznaj się z funkcją "accumarray"
[uWovels,~,idx]     = unique(vowelClass); 
nrOfexamples2       = accumarray(idx(:),1);
table_nrOfexamples2 = table(uWovels, nrOfexamples2);
disp(table_nrOfexamples2)


%% (3) Podział na zbiór uczący (70%) i testowy (30%)
zbiorUczacyP = 0.7;% proporcje podziału zbioru: 70%/30%
% Jak to działa:
% - dla każdej samogłoski wyznaczane są numery indeksów elementów z tablicy "vowelClass"
% - na podstawie liczby elementów danej samogłoski oraz parametru "zbiorUczacyP" 
%   wyznaczany jest podział na dwa zbiory (odpowiednie proporcje)
% - indeksy elementów są przydzielane do odpowiednich wektorów
%   "trainingDataId" i "testDataId" które później posłużą do wyboru danych
trainingDataId=[]; % indeksy elementów zbioru uczącego
testDataId=[];     % indeksy elementów zbioru testowego
for i=1:nrOfVowels
    idx1    = find(strcmp(vowelClass,uWovels(i)));         % indeksy elementów (określonej samogłoski), wektor
    id1     = floor(zbiorUczacyP * length(idx1));          % numer elementu odpowiadający podziałowi 70/30%
    trainingDataId = [trainingDataId idx1(1:id1)];         % indeksy zb. uczącego określonej samogłoski - indeksy elementów zb. uczącego zaczynają się od 1 do testid1
    testDataId     = [testDataId idx1(id1+1:end)];         % indeksy zb. testowego określonej samogłoski - indeksy elementów zb. testowego zaczynają się od testid1+1
end
% zbiór uczący i zbiór testowy
formantsTableTraining  = formantsTable(trainingDataId,:);
formantsTableTest      = formantsTable(testDataId,:);

% liczebności zbiorów (zanotuj w sprawozdaniu)
[uWovels,~,idx]       = unique(formantsTableTraining.vowel); 
nrOfexamplesTraining  = accumarray(idx(:),1);
[uWovels,~,idx]       = unique(formantsTableTest.vowel); 
nrOfexamplesTest      = accumarray(idx(:),1);
table_nrOfexamples3   = table(uWovels, nrOfexamplesTraining, nrOfexamplesTest);
disp(table_nrOfexamples3)

%% (4) Podział na zbiór uczący i testowy przy pomocy prostej walidacji 
%  (zbiór dzielony losowo na rozłączne zbiory)
% - Zapoznaj się z funkcją "cvpartition" w dokumentacji MATLABa

CV = cvpartition(formantsTable.vowel,'Holdout',1-zbiorUczacyP)
CV.training

% zbiór uczący i zbiór testowy 2
formantsTableTraining2  = formantsTable(CV.training,:);
formantsTableTest2      = formantsTable(CV.test,:);

% liczebności zbiorów (zanotuj w sprawozdaniu)
[uWovels,~,idx]       = unique(formantsTableTraining2.vowel); 
nrOfexamplesTraining2 = accumarray(idx(:),1);
[uWovels,~,idx]       = unique(formantsTableTest2.vowel); 
nrOfexamplesTest2     = accumarray(idx(:),1);
table_nrOfexamples4   = table(uWovels, nrOfexamplesTraining2, nrOfexamplesTest2);
disp(table_nrOfexamples4)


%% (5) Zapis do pliku MAT
save trainingAndTestData formantsTableTraining formantsTableTest
