function [cursorData] = sterowanie2(obrazwe, bboxFace, parametry)
% Szablon: generacja odpowiedniego sterowania kursorem (sterowanie bezwzględne)
% WEJSCIA: 
% > obrazwe         - obraz wejściowy RGB (cały)
% > bboxFace        - wspolrzedne wykrytej twarzy [x,y,w,h]
% > parametry       - struktura parametrow:
%  .histereza      - parametr histerezy dla sterowania względnego
%  .gainx          - parametr wzmocnienia x dla sterowania względnego
%  .gainy          - parametr wzmocnienia y dla sterowania względnego
% WYJSCIA:
% > cursorData      - wspolrzedne kursora (sterowanie) [x,y,x2,y2] lub puste
%                     (gdzie x2,y2 to wartości "wychylenia" od pozycji
%                     środkowej
%
% CREATED: 25.11.2020, R2020a, Jaromir Przybylo
%

cursorData = [];

% zmienne persistent są pamiętane pomiędzy kolejnymi wywołaniami funkcji
% - x_cursor2 y_cursor2 zawierają aktualne współrzędne kursora
persistent x_cursor2 y_cursor2      

% inicjalizacja zmiennych persistent przy pierwszym uruchomieniu
if isempty(x_cursor2)               
    x_cursor2 = 0.5;                
end                                 
if isempty(y_cursor2)               
    y_cursor2 = 0.5;                
end  

% uwaga bboxFace to wspolrzedne przed wycieciem twarzy 
if ~isempty(bboxFace)
    srodekTwarzy  = [bboxFace(1,1)+bboxFace(1,3)/2 bboxFace(1,2)+bboxFace(1,4)/2];  
    %poleTwarzy    = bboxFace(1,3).*bboxFace(1,4);

    % sterowanie
    x   = srodekTwarzy(1);
    y   = srodekTwarzy(2);   
        
    % wielkosc obrazu
    [m,n,~] = size(obrazwe);
        
    % Wyznaczanie "wychylenia"  od pozycji środkowej:
    % - normalizacja współrzędnych <0,1> połączona z translacją do środka
    %   układu <0.5,0.5>. Dodatkowo odwracanie osi.
    x2      = -((x/n)-0.5);
    y2      = -((y/m)-0.5);
            
    % jesli wychylenie > histerezy to generowanie przesuwanie kursora z
    % uwzględnieniem parametrów wzmocnienia
    if abs(x2)>parametry.histereza            
        x_cursor2 = x_cursor2 + parametry.gainx * sign(x2)*(abs(x2)-parametry.histereza);        
    end
    if abs(y2)>parametry.histereza            
        y_cursor2 = y_cursor2 + parametry.gainy * sign(y2)*(abs(y2)-parametry.histereza);       
    end  
    
    % dodatkowo - korekta ew wychyleń głowy poza obszarem sterowania
    x_cursor2(x_cursor2<0) = 0;
    x_cursor2(x_cursor2>1) = 1;
    y_cursor2(y_cursor2<0) = 0;
    y_cursor2(y_cursor2>1) = 1;
        
    % zwracanie argumentow wyjsciowych
    x_cursor = x_cursor2;
    y_cursor = y_cursor2;
    cursorData = [x_cursor,y_cursor,x2, y2];                    
end



