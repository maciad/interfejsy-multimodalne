function probim = probabilityIM(im,model)
% PROBABILITYIM Wyznaczenie tablicy prawdopodobienstwa dla obrazu testowego
%               wg zadanego modelu koloru skory. 
%                                                                         
%  [PROBIM] = CREATESKINMODEL(IM,MODEL)
%
% INPUT:
% > im - testowy obraz wejsciowy w formacie RGB
% > model - model koloru skory (tablica [256*256])
% OUTPUT:                                                                         
% > skin_model - obraz prawdopodobienstwa
%
% DEPENDICIES:
% -
% COMMENTS:
% > Wykorzystano przeksztalcenie look-up-table 2D
% > TODO kontrola argumentow wejsciowych
% CREATED: Jaromir Przybylo, 22 lutego2007
% LASTMODIFIED: 
%

% konwersja RGB>YCBCR dla obrazu testowego
ycbcr = rgb2ycbcr(im);

% wybor skladowych CB,CR
data1=double(ycbcr(:,:,3));data2=double(ycbcr(:,:,2));

% 2D look-up-table (zakres [0-255,0-255])
ind=sub2ind([256 256],data2(:),data1(:));
outim=model(ind);
probim=reshape(outim,size(im(:,:,1)));
