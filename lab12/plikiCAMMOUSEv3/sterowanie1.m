function [cursorData] = sterowanie1(obrazwe, bboxFace, parametry)
% Szablon: generacja odpowiedniego sterowania kursorem (sterowanie bezwzględne)
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
        offset_x = parametry.offset_x;
        offset_y = parametry.offset_y;
        CDx      = parametry.CDx;
        CDy      = parametry.CDy;  
        
        % normalizacja sygnałów x i y do zakresu <0-1>
        % -=== UZUPEŁNIJ ===- 
        % - wskazówka obliczanie współrzędnych kursora wymaga użycia
        % offset_x, offset_y, CDx, CDy (analogicznie jak przy kalibracji)
        % UWAGA - nie liczymy tutaj ponownie CDx i CDy oraz offset_x, offset_y !
        %         obliczamy tylko x_cursor i y_cursor - pozostałe parametry 
        %         są wczytane z pliku k alibracyjnego i przekazywane tutaj
        %         jako parametry)
        x_cursor = (x - offset_x) / CDx;
        y_cursor = (y - offset_y) / CDy;

        % dodatkowo - korekta ew wychyleń głowy większych niż na etapie kalibracji
        x_cursor(x_cursor<0) = 0;
        x_cursor(x_cursor>1) = 1;
        y_cursor(y_cursor<0) = 0;
        y_cursor(y_cursor>1) = 1;
        
        % odwrócenie osi
        x_cursor=1-x_cursor;
        y_cursor=1-y_cursor;   
                 
        % sygnał wyjściowy
        cursorData = [x_cursor,y_cursor];
    end
end



