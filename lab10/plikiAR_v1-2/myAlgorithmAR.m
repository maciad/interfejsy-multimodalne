classdef myAlgorithmAR < handle
    % Detekcja wzorca (szablon kalibracji) 
    % WERSJA: 17.12.2021, R2021b
    %
    
    % Własności dostępne do odczytu
    properties  (SetAccess = private)
        
    end
    
    % Własności prywatne (dostępne tylko z wnętrza klasy)
    properties  (Access = private)
        params                  % struktura parametrów algorytmu
    end    
    
    % Metody klasy
    methods
        function obj = myAlgorithmAR(params)
            % Konstruktor klasy (nazwa konstruktora taka jak nazwa klasy!)
            % - tutaj odbywa się inicjalizacja obiektu klasy
            % - w zależności od potrzeb dodać odpowiednie arg we, np.
            % > params          - struktura parametrów algorytmu: 
            %   .calibfilename  - nazwa pliku z danymi kalibracji kamery
            %   .pointsfilename - nazwa pliku z wybranymi punktami planszy
            disp('---=== myAlgorithmAR ===---')
            obj.params              = params; % do własności klasy odwołujemy się poprzez nazwę "obj."    
            load(params.calibfilename);
            load(params.pointsfilename);
            obj.params.cameraParams         = cameraParams;
            obj.params.worldPoints          = worldPoints;
            obj.params.myWorldPoints        = myWorldPoints;
        end
        
        function danewy = process(obj, danewe)
            % Przetwarzanie kolejnej paczki danych
            % INPUTS:
            % > obj             - argument wymagany
            % > danewe          - dane wejściowe - tutaj obraz RGB
            % OUTPUTS:
            % > danewy          - dane wyjściowe
            %   .RGB               - kopia obrazu we RGB             
            %   .R, t              - rotacja i translacja kamery względem
            %                        planszy kalibracyjnej lub puste jeśli nie wykryto
            %   .srodek1, skala1   - skala i translacja (środek) obiektu na planszy kalibracyjnej
            %   .cameraParams      - parametry kalibracji
            %   .skalaZ            - skala w osi Z
            %
            
            % - korekta zniekształceń obiektywu kamery
            [undistortedImage,newOrigin] = undistortImage(danewe, obj.params.cameraParams);

            % - wykrycie punktow wzorca
            [imagePoints, boardSize] = detectCheckerboardPoints(undistortedImage);
            if size(imagePoints,1)==size(obj.params.worldPoints,1)
                % - obliczenie rotacji i translacji kamery (na podstawie punktów obrazu i
                %   ich współrzędnych w układzie świata)
                %   - worldPoints: generowane na etapie kalibracji współrzędne planszy 
                %     kalibracyjnej na płaszczyźnie w ukł. świata 
                %   - imagePoints: odpowiadające im współrzędne punktów obrazu
                try
                    [R, t] = extrinsics(imagePoints, obj.params.worldPoints, obj.params.cameraParams);
                    % - skala i translacja (środek) obiektu na planszy kalibracyjnej wyznaczana 
                    %   na podstawie wybranych punktów
                    skala1  = [(max(obj.params.myWorldPoints.X)-min(obj.params.myWorldPoints.X)) (max(obj.params.myWorldPoints.Y)-min(obj.params.myWorldPoints.Y))];
                    srodek1 = skala1/2 + [min(obj.params.myWorldPoints.X) min(obj.params.myWorldPoints.Y)];
                catch
                    R = [];
                    t = [];
                    srodek1 = [];
                    skala1  = [];                      
                end
            else
                % disp('Problem z wykryciem punktów planszy kalibracyjnej');
                R = [];
                t = [];
                srodek1 = [];
                skala1  = [];                
            end

            danewy          = [];   
            danewy.RGB      = danewe;
            danewy.R        = R;
            danewy.t        = t;
            danewy.srodek1  = srodek1;
            danewy.skala1   = skala1;
            danewy.skalaZ   = obj.params.skalaZ;
            danewy.cameraParams = obj.params.cameraParams;
        end
        
        function delete(obj)
            % Tutaj realizować usuwanie obiektów które tego wymagają, 
            % zamykać otwarte pliki, itp.
        end
    end
end

