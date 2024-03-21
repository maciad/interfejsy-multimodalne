addpath('BazaObrazow')
% testowy = imread('testowy_0_0000.jpeg');

faceDetector = vision.CascadeObjectDetector();

% bbox = step(faceDetector, testowy);
% Out = insertObjectAnnotation(testowy,'rectangle',bbox,'Twarz');
% figure, imshow(Out), title('Wykryta twarz');

%%
files = dir('BazaObrazow/*.jpeg'); % zmień rozszerzenie na odpowiednie

for i = 1:length(files)
    filename = files(i).name;
    img = imread(filename);

    bbox = step(faceDetector, img);
    Out = insertObjectAnnotation(img,'rectangle',bbox,'Twarz'); 
    figure, imshow(Out), title('Wykryta twarz');
end