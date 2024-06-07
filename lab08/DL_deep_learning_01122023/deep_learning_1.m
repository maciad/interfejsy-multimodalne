%% Wykorzystanie gotowej sieci AlexNet
%  WERSJA: 16.11.2020, Jaromir Przybylo (przybylo@agh.edu.pl), R2020a
%  UPDATE: 30.11.2021, Jaromir Przybylo (przybylo@agh.edu.pl), R2021b
%  UPDATE: 04.05.2023, Jaromir Przybylo (przybylo@agh.edu.pl), R2023a
%  UPDATE: 01.12.2023, Jaromir Przybylo (przybylo@agh.edu.pl), R2023b
%
clear all;close all;clc

%% (1) Wczytanie gotowej sieci AlexNet
% - siec AlexNet zostala wytrenowana do rozpoznawania obiektow nalezacych
%   do jednej z 1000 kategorii, do trenowania uzyto ponad 1 milion obrazow
net = alexnet;

% - wizualizacja sieci
analyzeNetwork(net)

% Siec byla uczona obrazami przeskalowanymi do mniejszego rozmiaru, tutaj
% pobieramy ten rozmiar do zmienne "inputSize"
inputSize = net.Layers(1).InputSize

%% (2) Uzycie domyslnej sieci Alexnet do rozpoznawania
% - pobierz kilka obrazow roznych obiektow i zanotuj wyniki rozpoznawania
%   - zmodyfikuj odpowiednio kod ponizej aby wczytac swoje obrazy
%   - wyeksportuj do sprawozdania utworzone wykresy (odkomentuj odpowienia
%     czesc kodu w tej sekcji)

imFileName = 'przykladowyObiekt1.PNG';      % nazwa obrazu (POBIERZ GO WCZESNIEJ - IMAGEACQUISITIONEXPLORER)

%- wczytanie obrazu i dostosowanie jego rozmiaru
IM0 = imread(imFileName);               % wczytanie obrazu z pliku
IM1 = imresize(IM0, inputSize(1:2));    % dostosowanie rozmiaru pliku do wejscia sieci

%- rozpoznawanie - funkcja "classify"
[YPred,scores] = classify(net, IM1);

%- wizualizacja
nazwyKlas       = net.Layers(end).Classes;    % pobranie nazw klas z ostatniej warstwy
idKlasy         = find( YPred == nazwyKlas);  % id rozpoznanej klasy
Pklasy          = scores(idKlasy);            % prawdopodobienstwo rozpoznanej klasy
[topTen, id10]  = sort(scores,'descend');     % 10 najbardziej prawdopodobnych klas
topTen          = topTen(1:10);
id10            = id10(1:10);

fh=figure;
ah1=subplot(2,1,1);
imshow(IM0)
title(['Rozpoznano: ' char(YPred) ', P = ' num2str(Pklasy)])
ah2=subplot(2,1,2);
bar(topTen)
ylim([0 1.1])
xticklabels(cellstr(nazwyKlas(id10)))
ah2.XTickLabelRotation=90;
title('Top 10')

%-eksport wykresu do pliku (nazwa ustawiana automatycznie wg nazwy pliku
% wejsciowego)
% - mozna to takze zrobic "recznie" - w oknie Figure, Manu, Plik>Save As... wybrac PNG
%{
[~,fname1,~]=fileparts(imFileName);
saveas(fh,[fname1 '_output.png'])
%}

%% (3) Wizualizacja dzialania sieci (wagi, aktywacje) dla wybranego obrazu
%% --- Wagi dla warstw ---
% Kazda warstwa sieci konwolucyjnej sklada sie z wielu filtrow w postaci
% wag. W procesie uczenia, siec "wyksztalca" filtry/wagi.
% - zanotuj w sprawozdaniu:
%   - rozmiar kazdego filtru warstwy nr.2 (CONV1)
%     Co oznaczaja parametry: FilterSize, NumChannels, Stride
%   - liczbe filtrow dla warstwy nr.2 (CONV1, NumFilters)
%   - zwroc uwage na wizualizacje wag - jakie cechy Twoim zdaniem bedzie
%     wykrywal dany filtr?
net.Layers(2)
net.Layers(2).NumFilters
w1=net.Layers(2).Weights;
size(w1)
figure;
montage(rescale(w1))
title('tablica filtrow/wag warstwy CONV1)')
%-ponizszy kod pozwala zwizualizowac wybrany filtr w IMTOOL
filtrNr = 50;
imtool(w1(:,:,:,filtrNr),[]);


%% (4) --- Wizualizacja aktywacji dla warstwy CONV1 --- 
%  Obraz wejsciowy takiej warstwy, podlega filtracji dajac wiele obrazow
%  wyjsciowych (aktywacji). 
%  Na wizualizacji, jasne obszary odpowiadaja silnym pozytywnym odpowiedziom
%  danego filtru, ciemne - silnym negatywnym. rezultaty w kolorze szarym
%  odpowiadaja slabym aktywacjom.
%  Warstwy konwolucyjne mozna traktowac wiec jak detektory cech obrazu. 
% - zamieść w sprawozdaniu poniższe dwa wykresy  dla przykładowych obrazów

act1 = activations(net, IM1,'conv1');%pobranie aktywacji z wybranej warstwy
sz = size(act1);
act1 = reshape(act1,[sz(1) sz(2) 1 sz(3)]);
I = imtile(rescale(act1),'GridSize',[8 12]);
figure;
imshow(I)
title('aktywacje warstwy CONV1')

% --- Najsilniejsza aktywacja dlawarstwy CONV1 --- 
% - zwroc uwage na to jakie cechy obrazu sa wykrywane przez ten filtr
%   (krawedzie, plamy... jasne, ciemne...)
imgSize = size(IM1);
imgSize = imgSize(1:2);
[maxValue,maxValueIndex] = max(max(max(act1)));
act1chMax = act1(:,:,:,maxValueIndex);
act1chMax = rescale(act1chMax);
act1chMax = imresize(act1chMax,imgSize);
figure;
I = imtile({IM1,act1chMax});
imshow(I)
title('najsilniejsza aktywacja warstwy CONV1')

%% (5) --- Wizualizacja aktywacji dla "glebszej" warstwy CONV5 --- 
act5 = activations(net,IM1,'conv5');
sz = size(act5);
act5 = reshape(act5,[sz(1) sz(2) 1 sz(3)]);
I = imtile(imresize(rescale(act5),[48 48]));
figure;
imshow(I)
title('aktywacje wartstwy CONV5')

% --- Najsilniejsza aktywacja dlawarstwy CONV5 --- 
% - zwroc uwage na to jakie cechy obrazu sa wykrywane przez ten filtr
%   (krawedzie, plamy... jasne, ciemne...)
[maxValue5,maxValueIndex5] = max(max(max(act5)));
act5chMax = act5(:,:,:,maxValueIndex5);
figure;
imshow(imresize(rescale(act5chMax),imgSize))
title('najsilniejsza aktywacja wartstwy CONV5')

%% (6) Wizualizacja "co widzi siec neuronowa"
% Do diagnozowania dzialania sieci glebokich mozna wykorzystac technike
% nazywana "Deep Dream Visualization". Technika ta pozwala na synteze
% obrazu, ktory wywoluje najwieksza aktywacje wybranej warstwy. Dzieki temu
% mozna zwizualizowac cechy obrazu, ktorych "nauczyla sie" siec. 
% - zanotuj w sprawozdaniu rezultaty dla przykładowych obrazów
layer = 23;         % wybor warstwy, dla ktorej bedzie realizowana wizualizacja
channels = [100 2 23 40]; % wybor klas, dla ktorych bedzie realizowana wizualizacja
net.Layers(end).Classes(channels)

% ustawić 'ExecutionEnvironment' na 'cpu' w przypadku błędów cuDNN
I = deepDreamImage(net,layer,channels,'ExecutionEnvironment','cpu');
I1 = imtile(I);
figure
imshow(I1)


%% (7) Które regiony obrazu najbardziej wpływają na klasyfikację?
% - zanotuj w sprawozdaniu rezultaty dla przykładowych obrazów

%- wczytanie obrazu i dostosowanie jego rozmiaru
IM0 = imread(imFileName);               % wczytanie obrazu z pliku
IM1 = imresize(IM0, inputSize(1:2));    % dostosowanie rozmiaru pliku do wejscia sieci

%- rozpoznawanie - funkcja "classify"
[YPred,scores] = classify(net, IM1);

% na co sieć zwraca uwagę
% - zapoznaj się z dokumentacją funkcji "occlusionSensitivity"
map = occlusionSensitivity(net,IM1,YPred);

figure;
imagesc(map)
colormap jet
colorbar

figure;
imshowpair(IM1, map)


