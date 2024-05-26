%% Rozszerzona rzeczywistosc
% 
% WERSJA: 01.12.2020, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2020a
% ZMODYFIKOWANO: 18.12.2020, poprawka w sekcji 2
%
clear all;close all;clc

%% (1) Uruchomienie automatycznie wygenerowanego skryptu do kalibracji kamery
calibrationParams; % uwaga - wygeneruj wcześniej ten plik w narzędziu "Camera Calibrator"
% Zapis do pliku MAT parametrów kalibracyjnych
save parametryKalibracji cameraParams worldPoints squareSize


%% (2) Wyznaczanie parametrów rotacji i translacji kamery na podstawie 
%      wykrytych punktów planszy kalibracyjnej
%      - przy pomocy narzędzia imaqtool pobierz nową ramkę z widoczną
%      planszą kalibracyjną (uwaga - rozdzielczość akwizycji musi być taka
%      sama jak rozdzielczość obrazów kalibracyjnych)
%      - zapisz tą ramkę do pliku np. AR_example1.png

% - wczytanie parametrów kalibracyjnych
load parametryKalibracji

% - wczytanie przykładowego obrazu zawierającego planszę kalibracyjną:
%   (obraz powinien zawierać planszę widoczną pod kątem)
RGB = imread('snapshot5.png');

% - opc. korekta zniekształceń obiektywu kamery
[undistortedImage,newOrigin] = undistortImage(RGB, cameraParams);

% - wykrycie punktow wzorca
[imagePoints, boardSize] = detectCheckerboardPoints(undistortedImage);
%if isempty(imagePoints )                   %18.12.2020
if size(imagePoints,1)~=size(worldPoints,1) %18.12.2020
    error('Problem z wykryciem punktów planszy kalibracyjnej - zrób inne zdjęcie');
end

figure; 
imshow(RGB);
hold on
plot(imagePoints(:,1),imagePoints(:,2),'ro')
hold off
figure; 
imshowpair(RGB, undistortedImage,'falsecolor');
title('różnice - korekta zniekształceń')

% - opc. korekta wykrytych punktów "imagePoints" tak aby uwzględnić zniekształcenia
%   obiektywu kamery
imagePoints = imagePoints + newOrigin;

% - obliczenie rotacji i translacji kamery (na podstawie punktów obrazu i
%   ich współrzędnych w układzie świata)
%   - worldPoints: generowane na etapie kalibracji współrzędne planszy 
%     kalibracyjnej na płaszczyźnie w ukł. świata 
%   - imagePoints: odpowiadające im współrzędne punktów obrazu
[R, t] = extrinsics(imagePoints, worldPoints, cameraParams);

disp(worldPoints)

%% (3) Konwersja punktów obrazu do współrzędnych świata
myPoint1        = imagePoints(2,:);       % wspołrzędne punktu obrazu odpowiadające punktom planszy

% - konwersja wspólrzędnych - wykorzystujemy parametry wewnętrzne kamery oraz
%   obliczoną rotację i translację kamery
myWorldPoint1   = pointsToWorld(cameraParams, R, t, myPoint1);
disp(['(Xw,Yw,0) = (' num2str(myWorldPoint1(1),3) ', ' num2str(myWorldPoint1(2),3) ', 0)'])

figure;
imshow(undistortedImage)
hold on
plot(myPoint1(1),myPoint1(2),'ro','MarkerSize',10)
hold off
text(10,10, ...
    ['(Xw,Yw,0) = (' num2str(myWorldPoint1(1),3) ', ' num2str(myWorldPoint1(2),3) ', 0)'],...
    'Color','red')

%% (4) Rzutowanie 2 punktów 3D do współrzędnych obrazu
X1      = [3 5];    % współrzędne x
Y1      = [2 4];    % współrzędne y
Z1      = [0 -25];  % współrzędne z

projectedPoints1 = worldToImage(cameraParams, R, t, [X1(:) Y1(:) Z1(:)]);

figure; 
imshow(undistortedImage);
hold on
plot(projectedPoints1(:,1), projectedPoints1(:,2),'r.','MarkerSize',15);
plot([projectedPoints1(1,1) projectedPoints1(2,1)],...
    [projectedPoints1(1,2) projectedPoints1(2,2)],'m-')
hold off
title('punkty 3D rzutowane na obraz')

%% (5) Wybór miejsca gdzie ma się pojawić obiekt
myWorldPoints   = [];
myWorldPoints.X = [1 1 3 3] * squareSize;   %[X1 X2 X3 X4]
myWorldPoints.Y = [0 2 2 0] * squareSize;   %[Y1 Y2 Y3 Y4]
 
% ---------------------------------------------------------
% UZUPEŁNIJ_1 rzutowanie punktów 3D do współrzędnych obrazu
% - zamieść w sprawozdaniu obraz wybranych punktów oraz uzupełniony kod
pts1             = [myWorldPoints.X(:) myWorldPoints.Y(:) zeros(size(myWorldPoints.X(:)))]; % (X, Y, Z - wektory kolumnowe)
projectedPoints1 = worldToImage(cameraParams, R, t, pts1);
% ---------------------------------------------------------

figure; 
imshow(undistortedImage);
hold on
plot(projectedPoints1(:,1), projectedPoints1(:,2),'r.','MarkerSize',15);
hold off
title('punkty 3D rzutowane na obraz')

% -zapis wybranych punktow do pliku MAT (używany w dalszej części
% ćwiczenia)
save mojePunkty myWorldPoints


%% (6a) Rzutowanie prostego obiektu 3D na obraz
skalaZ  = 25;   % skala w osi Z
r1      = 1;    % promien cylindra

% - skala i translacja (środek) obiektu na planszy kalibracyjnej wyznaczana 
%   na podstawie wybranych punktów
skala1  = [(max(myWorldPoints.X)-min(myWorldPoints.X)) (max(myWorldPoints.Y)-min(myWorldPoints.Y))];
srodek1 = skala1/2 + [min(myWorldPoints.X) min(myWorldPoints.Y)];

% - przykładowy obiekt 
[X,Y,Z] = cylinder(r1, 21);
X       = X * skala1(1)/2 + srodek1(1);
Y       = Y * skala1(1)/2 + srodek1(2);
Z       = -Z * skalaZ;

figure;
plot3(X,Y,Z,'r.')
hold on
for i=1:size(X,2)
    plot3([X(1,i) X(2,i)],[Y(1,i) Y(2,i)],[Z(1,i) Z(2,i)],'m-')
end
for i=1:size(X,2)-1
    plot3([X(1,i) X(1,i+1)],[Y(1,i) Y(1,i+1)],[Z(1,i) Z(1,i+1)],'m-')
    plot3([X(2,i) X(2,i+1)],[Y(2,i) Y(2,i+1)],[Z(2,i) Z(2,i+1)],'m-')
end
hold off
grid on
title('obiekt 3D')

% rzutowanie współrzędnych obiektu na obraz
x1 = X(1,:);y1 = Y(1,:);z1 = Z(1,:);
x2 = X(2,:);y2 = Y(2,:);z2 = Z(2,:);
projectedPoints1 = worldToImage(cameraParams, R, t, [x1(:) y1(:) z1(:)]);
projectedPoints2 = worldToImage(cameraParams, R, t, [x2(:) y2(:) z2(:)]);

figure; 
imshow(RGB);
hold on
plot(projectedPoints1(:,1), projectedPoints1(:,2),'r.');
plot(projectedPoints2(:,1), projectedPoints2(:,2),'r.');
for i=1:size(projectedPoints1,1)
    plot([projectedPoints1(i,1) projectedPoints2(i,1)],...
        [projectedPoints1(i,2) projectedPoints2(i,2)],'m-')
end
for i=1:size(projectedPoints1,1)-1
    plot([projectedPoints1(i,1) projectedPoints1(i+1,1)],...
        [projectedPoints1(i,2) projectedPoints1(i+1,2)],'m-')
    plot([projectedPoints2(i,1) projectedPoints2(i+1,1)],...
        [projectedPoints2(i,2) projectedPoints2(i+1,2)],'m-')
end
hold off
title('obiekt 3D rzutowany na obraz')

%% (6b) Rzutowanie innego obiektu 3D na obraz (kubek?)
% - skala i translacja (środek) obiektu na planszy kalibracyjnej wyznaczana 
%   na podstawie wybranych punktów
% - zamieść rezultaty w sprawozdaniu
skala1  = [(max(myWorldPoints.X)-min(myWorldPoints.X)) (max(myWorldPoints.Y)-min(myWorldPoints.Y))];
srodek1 = skala1/2 + [min(myWorldPoints.X) min(myWorldPoints.Y)];
skalaZ  = 50;% skala w osi Z

% ---------------------------------------------------------
% UZUPEŁNIJ_2 Utwórz bardziej zaawansowany obiekt manipulując parametrem funkcji cylinder
t1 = 0:pi/20:0.5*pi;
r1 = 1;
% ---------------------------------------------------------
[X,Y,Z] = cylinder(r1);
X       = X * skala1(1)/2 + srodek1(1);
Y       = Y * skala1(1)/2 + srodek1(2);
Z       = -Z * skalaZ;

% rzutowanie współrzędnych obiektu na obraz
projectedPoints1 = worldToImage(cameraParams, R, t, [X(:) Y(:) Z(:)]);

figure;
plot3(X,Y,Z,'r.')
hold off
grid on
title('model 3D')

figure; 
imshow(RGB);
hold on
plot(projectedPoints1(:,1), projectedPoints1(:,2),'r.');
hold off
title('obiekt 3D rzutowany na obraz')


%% (7) Rzutowanie modelu (chmura punktów) 3D na obraz
% - skala i translacja (środek) obiektu na planszy kalibracyjnej wyznaczana 
%   na podstawie wybranych punktów
% - zamieść rezultaty w sprawozdaniu
skala1  = [(max(myWorldPoints.X)-min(myWorldPoints.X)) (max(myWorldPoints.Y)-min(myWorldPoints.Y))];
srodek1 = skala1/2 + [min(myWorldPoints.X) min(myWorldPoints.Y)];
skalaZ  =15;% skala w osi Z

% - wczytanie modelu w formacie STL
TR  = stlread('bishop.stl');
X   = TR.Points(:,1);
Y   = TR.Points(:,2);
Z   = TR.Points(:,3);
X   = X * skala1(1)/2 + srodek1(1);
Y   = Y * skala1(1)/2 + srodek1(2);
Z   = -Z * skalaZ;

% rzutowanie współrzędnych obiektu na obraz
projectedPoints1 = worldToImage(cameraParams, R, t, [X(:) Y(:) Z(:)]);

figure;
plot3(X,Y,Z,'r.')
hold off
grid on
title('model 3D')

figure; 
imshow(RGB);
hold on
plot(projectedPoints1(:,1), projectedPoints1(:,2),'r.');
hold off
title('model 3D rzutowany na obraz')


