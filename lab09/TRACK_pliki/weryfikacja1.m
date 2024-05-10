function [bboxNos, bboxUsta] = weryfikacja1(obrazwe, bboxFace, noseBBox, mouthBBox, parametry)
% Funkcja do ćwiczenia TRACK
% WEJSCIA: 
% > obrazwe         - obraz wejściowy RGB (cały)
% > bboxFace        - wspolrzedne wykrytej twarzy [x,y,w,h]
% > noseBBox        - wspolrzedne wykrytych cech 1 [N1 * 4] - uwaga
%                     wspolrzedne na wycietym obrazie twarzy!
% > mouthBBox       - wspolrzedne wykrytych cech 2 [N2 * 4] - uwaga
%                     wspolrzedne na wycietym obrazie twarzy!
% > parametry       - struktura parametrow:
%   .proporcjaObszaruTwarzyiNosa  - proporcja wielkosci powierzchni obszaru
%                                   nosa do obszaru twarzy
%   .odlegloscUstaSrodekTwarzy    - min. odleglosc srodka obszaru ust od srodka
%                                   obszaru twarzy
% WYJSCIA:
% > bboxNos, bboxUsta - wspolrzedne ROI ust i nosa (lub puste)
%
% CREATED: 30.10.2020, R2020a, Jaromir Przybylo
%

obrazwy = obrazwe;

% uwaga bboxFace to wspolrzedne przed wycieciem twarzy natomiast noseBBox i
% mouthBBox to wspolrzedne na wycietym obrazie twarzy
srodekTwarzy  = [bboxFace(1,3)/2 bboxFace(1,4)/2];  
srodekNosa    = [noseBBox(:,1)+noseBBox(:,3)/2 noseBBox(:,2)+noseBBox(:,4)/2];
srodekUst     = [mouthBBox(:,1)+mouthBBox(:,3)/2 mouthBBox(:,2)+mouthBBox(:,4)/2];
poleTwarzy    = bboxFace(1,3).*bboxFace(1,4);
poleNosa      = noseBBox(:,3).*noseBBox(:,4);

% warunki detekcji nosa
nos_warunek_1 = poleNosa > parametry.proporcjaObszaruTwarzyiNosa*poleTwarzy;
if sum(nos_warunek_1)==1
    % wykryto 1 nos
    bbox2 = noseBBox(nos_warunek_1,:);
    bbox2(1:2)=bbox2(1:2) + bboxFace(1:2); % korekta polozenia cechy uwzględniająca wycięty obszar twarzy
    %obrazwy = insertObjectAnnotation(obrazwy, 'rectangle', bbox2, 'nos');
    bboxNos = bbox2;
else
    % nie wykryto nosa lub wykryto więcej niż jeden obiekt
    %obrazwy = insertText(obrazwy,[10 10],'Nie wykryto nosa');
    bboxNos = [];
end

% warunki detekcji ust
usta_warunek_1 = srodekUst(:,2)>srodekTwarzy(2); % usta poniżej srodka twarzy
r = sqrt(sum((srodekUst(:,1:2)-srodekTwarzy(1,2)).^2,2));%odleglosc miedzy srodkami obszarow ust a srodkiem twarzy
usta_warunek_2 = r > parametry.odlegloscUstaSrodekTwarzy;

usta_warunek = usta_warunek_1 & usta_warunek_2;
if sum(usta_warunek)==1
    % wykryto 1 nos
    bbox2 = mouthBBox(usta_warunek,:);
    bbox2(1:2)=bbox2(1:2) + bboxFace(1:2); % korekta polozenia cechy uwzględniająca wycięty obszar twarzy
    %obrazwy = insertObjectAnnotation(obrazwy, 'rectangle', bbox2, 'usta');
    bboxUsta= bbox2;
else
    % nie wykryto ust lub wykryto więcej niż jeden obiekt
    %obrazwy = insertText(obrazwy,[10 30],'Nie wykryto ust');
    bboxUsta= [];
end

%obrazwy = insertObjectAnnotation(obrazwy, 'rectangle',bboxFace,'Twarz');


