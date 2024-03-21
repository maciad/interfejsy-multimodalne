addpath('BazaObrazow')
testowy = imread('testowy_0_0000.jpeg');
figure, subplot(2,3,1), imshow(testowy);

szary = probabilityIM(testowy,model2);
subplot(2,3,2), imshow(szary,[])
colormap(gray);

%
level = 0.0018;
binarny = im2bw(szary, level);
subplot(2,3,3), imshow(binarny);

se = strel('disk', 6);
zamkniety = imclose(binarny, se);
subplot(2,3,4), imshow(zamkniety);

label1 = bwlabel(zamkniety);
res = regionprops(label1);

wyczyszczony = bwareaopen(zamkniety,400); % dobierz parametry
subplot(2,3,5), imshow(wyczyszczony);

[x1, x2, twarz] = szukaj_twarz(wyczyszczony);
subplot(2,3,6), imshow(twarz);

%%
%dodatkowa wizualizacja
subplot(2,3,1)
pos=[x1(2) x1(1) x2(2)-x1(2) x2(1)-x1(1)];
hold on;rectangle('Position',pos,'EdgeColor','red'); hold off