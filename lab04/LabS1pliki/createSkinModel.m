function skin_model = createSkinModel(imgname,varargin)
% CREATESKINMODEL Tworzy gaussowski model skory (2d) w przestrzeni kolorow 
%                 YCrCb
%                                                                         
%  [SKIN_MODEL] = CREATESKINMODEL(IMGNAME,OPC_BW)
%
% INPUT:
% > imgname - nazwa obrazu wejsciowego, zawierajacego probki obrazu skory
% > opcbw  - opcjonalny argument - maska wyboru pikseli z obrazu z probkami (
%            (zmienna logiczna o rozmiarze = rozmiarowi obrazu RGB, uzyskana
%            np funkcja "roipoly")
%
% OUTPUT:                                                                         
% > skin_model - model koloru skory [tablica 256x256]
%
% DEPENDICIES:
% -
% COMMENTS:
% > TODO kontrola argumentow wejsciowych
% CREATED: Jaromir Przybylo, 22 lutego2007
% LASTMODIFIED: 
% > Jaromir Przybylo, 26.10.2015
% > R2019b, Jaromir Przybylo, 17.03.2020, poprawki b³êdów
%

% wczytanie obrazu 
image1 = imread(imgname);

if nargin>1
    bw = varargin{1};
else
    bw=ones(size(image1,1),size(image1,2))>0;
end

% konwersja RGB>YCBCR
ycbcr = rgb2ycbcr(image1);

% wybor skladowych CB,CR i umieszczenie ich w macierzy 2*N
data1=ycbcr(:,:,3);data2=ycbcr(:,:,2);
data1=data1(bw);data2=data2(bw);
data=double([data1(:) data2(:)]);

% obliczenie sredniej i macierzy kowariancji
mu1=mean(data);
cov1=cov(data);

% wyznaczenie 2D probability density function dla zakresu [0-255,0-255]
x=0:255;y=0:255;
[xx,yy]=meshgrid(x,y);
xx1=xx(:);yy1=yy(:);
outdata=mvnpdf([xx1 yy1],mu1,cov1);
skin_model=reshape(outdata,256,256);

%model =     gaussian(chromatyczny);

