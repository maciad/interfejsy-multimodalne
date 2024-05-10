classdef myAlgorithmTRACK < handle
    % Śledzenie twarzy
    %
    % - uwaga: klasa nie posiada zaimplementowanej kontroli poprawności 
    %          argumentów wejściowych i parametrów
    % WERSJA: 30.10.2020, R2020a    
    %
    
    % Własności dostępne do odczytu
    properties  (SetAccess = private)
        
    end
    
    % Własności prywatne (dostępne tylko z wnętrza klasy)
    properties  (Access = private)
        params
        faceDetector
        noseDetector
        mouthDetector
        pointTracker
        numPts
        oldPoints
        oldInliers
        bboxPoints
    end    
    
    % Metody klasy
    methods
        function obj = myAlgorithmTRACK(params)
            % Konstruktor klasy (nazwa konstruktora taka jak nazwa klasy!)
            % - tutaj odbywa się inicjalizacja obiektu klasy
            % - w zależności od potrzeb dodać odpowiednie arg we, np.
            % > params          - struktura parametrów algorytmu: 
            %   opis w weryfikacja1.m
            disp('---=== myAlgorithmTRACK ===---')
            obj.params = params;% zapamiętanie parametrów
            % Utworzenie detektorow cech
            obj.faceDetector = vision.CascadeObjectDetector();                  % detektor twarzy
            obj.pointTracker = vision.PointTracker('MaxBidirectionalError', 2); % śledzenie cech
            
            % - utworzenie dodatkowych detektorow cech twarzy (usta, nos)
            obj.noseDetector = vision.CascadeObjectDetector('Nose');
            obj.mouthDetector = vision.CascadeObjectDetector('Mouth');

            % Inicjalizacja zmiennych
            obj.numPts       = 0; % aktualna liczba wykrytych cech "pointTracker"
            obj.oldPoints    = [];% kopia śledzonych punktów
            obj.oldInliers   = [];% kopia punktów oldInliers (zmienna pomocnicza)
            obj.bboxPoints   = [];% kopia punktów ROI (zmienna pomocnicza)
        end
        
        function danewy = process(obj, danewe)
            % Przetwarzanie kolejnej paczki danych
            % INPUTS:
            % > obj             - argument wymagany
            % > danewe          - dane wejściowe - tutaj obraz RGB
            % OUTPUTS:
            % > danewy          - dane wyjściowe
            %   .RGB               - kopia obrazu we RGB 
            %   .bboxFace,bboxNos,bboxUsta -  ROI twarzy, ust i nosa
            %   .points            - wykryte punkty twarzy
            bboxNos = [];
            bboxUsta= [];
            
            % konwersja do grayscale jeśli potrzeba
            if size(danewe,3)>1
                videoFrameGray   = rgb2gray(danewe);
            else
                videoFrameGray   = danewe;
            end   
            videoFrame           = danewe;
            
            if obj.numPts < 10
                disp('inicjalizacja lub re-inicjalizacja trackera')
                % Detekcja punktów

                bboxFace = obj.faceDetector.step(videoFrameGray);% detekcja twarzy
                if ~isempty(bboxFace)
                    % znalezienie punktow wewnatrz ROI twarzy
                    points = detectMinEigenFeatures(videoFrameGray, 'ROI', bboxFace(1, :));

                    % re-inicjalizacja trackera
                    xyPoints = points.Location;
                    obj.numPts = size(xyPoints,1);
                    release(obj.pointTracker);
                    initialize(obj.pointTracker, xyPoints, videoFrameGray);

                    % zapamietanie kopii punktow
                    obj.oldPoints = xyPoints;

                    %-konwersja wspolrzednych prostokata [x, y, w, h] na
                    %  tablice Mx2 wspolrzednych [x,y] 4 rogow prostokata.
                    %  (wymagane do funkcji transformacji przestrzenych)
                    obj.bboxPoints = bbox2points(bboxFace(1, :));

                    %-konwersja wspolrzednych naroznikow prostokata do formatu 
                    % wymaganego przez insertShape
                    %bboxPolygon = reshape(obj.bboxPoints', 1, []);

                    % Wizualizacja
                    %videoOut = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
                    %videoOut = insertMarker(videoOut, xyPoints, '+', 'Color', 'white');
                end
            else
                % Sledzenie punktow
                [xyPoints, isFound] = step(obj.pointTracker, videoFrameGray);
                visiblePoints = xyPoints(isFound, :);
                obj.oldInliers = obj.oldPoints(isFound, :);

                obj.numPts = size(visiblePoints, 1);
                bboxFace = [obj.bboxPoints(1,:) obj.bboxPoints(3,:)-obj.bboxPoints(1,:)];
                
                if obj.numPts >= 10
                    % Estymacja transformacji geometrycznej pomiedzy starymi a
                    % nowymi punktami.
                    [xform, obj.oldInliers, visiblePoints] = estimateGeometricTransform(...
                        obj.oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

                    % Zastosowanie transformacji geometrycznej do prostokata twarzy
                    obj.bboxPoints = transformPointsForward(xform, obj.bboxPoints);
                    %bboxPolygon = reshape(obj.bboxPoints', 1, []);

                    % wycięcie obszaru twarzy
                    bboxFace = [obj.bboxPoints(1,:) obj.bboxPoints(3,:)-obj.bboxPoints(1,:)];
                    faceIM = imcrop(videoFrame, bboxFace);

                    % Detekcja atrybutów twarzy (na wyciętym ROI twarzy)
                    noseBBox=step(obj.noseDetector,faceIM);
                    mouthBBox=step(obj.mouthDetector,faceIM);                                   

                    % Weryfikacja atrybutów twarzy
                    [bboxNos, bboxUsta] = weryfikacja1(videoFrame, bboxFace, noseBBox, mouthBBox, obj.params);

                    % Uaktualnienie punktow
                    obj.oldPoints = visiblePoints;
                    setPoints(obj.pointTracker, obj.oldPoints);
                end        
            end
                
            % przygotowanie danych wyjściowych
            danewy          = [];
            danewy.RGB      = videoFrame;
            danewy.bboxFace = bboxFace;
            danewy.bboxNos  = bboxNos;
            danewy.bboxUsta = bboxUsta;
            danewy.points   = obj.oldPoints;
        end
        
        function delete(obj)
            % Tutaj realizować usuwanie obiektów które tego wymagają, 
            % zamykać otwarte pliki, itp.
        end
    end
end

