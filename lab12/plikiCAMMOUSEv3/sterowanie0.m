function [cursorData] = sterowanie0(obrazwe, bboxFace, parametry)
% Szablon: generacja odpowiedniego sterowania kursorem
% WEJSCIA: 
% > obrazwe         - obraz wejściowy RGB (cały)
% > bboxFace        - wspolrzedne wykrytej twarzy [x,y,w,h]
% > parametry       - struktura parametrow:
%   (parametry ustawiane automatycznie w myAlgorithmCAMMOUSE na podstawie danych kalibracyjnych)
%   .CDx            - współczynnik CD dla osi x
%   .CDy            - współczynnik CD dla osi y
%   .offset_x       - offset dla osi x
%   .offset_y       - offset dla osi y 
% WYJSCIA:
% > cursorData      - wspolrzedne kursora (sterowanie) [x,y] lub puste
%
% CREATED: 25.11.2020, R2020a, Jaromir Przybylo
%

cursorData = [];

% uwaga bboxFace to wspolrzedne przed wycieciem twarzy 
if ~isempty(bboxFace)
    srodekTwarzy  = [bboxFace(1,1)+bboxFace(1,3)/2 bboxFace(1,2)+bboxFace(1,4)/2];  
    %poleTwarzy    = bboxFace(1,3).*bboxFace(1,4);

    % sterowanie
    x   = srodekTwarzy(1);
    y   = srodekTwarzy(2);
    if ~isempty(parametry.CDx)
        % normalizacja sygnałów x i y
        

        % dodatkowo - korekta ew wychyleń głowy większych niż na etapie kalibracji
        
        % odwrócenie osi
         
        % sygnał wyjściowy
        %cursorData = [x_cursor,y_cursor];
    end
end



