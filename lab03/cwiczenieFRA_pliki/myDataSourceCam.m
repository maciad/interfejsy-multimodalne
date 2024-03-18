classdef myDataSourceCam < handle
    % Klasa realizująca odczyt danych z kamery
    % - SZABLON DO UZUPELNIENIA
    % WERSJA: 01.02.2023, R2022b
    % Przykład użycia (użyj tego kodu do testów poprawności działania klasy): 
    %{
         parametryImportu=[];
         parametryImportu.nr     = 1; 
         vid1    = myDataSourceCam(parametryImportu);
         IM      = vid1.pobierzDane;
         vidFPS  = vid1.vidFPS;
         nFrames = vid1.nFrames;
         imSize  = vid1.imSize;
         
         clear vid1    
    %}
    %
    
    % Własności (dane, stan) dostępne do odczytu
    properties  (SetAccess = private)
        vidFPS              % FPS strumienia video (w tym przypadku = inf)
        nFrames             % liczba ramek pliku video (w tym przypadku = inf)
        imSize              % rozmiar ramki obrazu
        test                % pomocnicza zmienna        
    end
    
    % Własności prywatne
    properties  (Access = private)
        vidObj              % obiekt kamery
    end    
    
    % Metody klasy
    methods
        function obj = myDataSourceCam(parametryImportu)
            % Konstruktor klasy - tutaj odbywa się inicjalizacja
            % INPUTS: 
            % > parametryImportu    - struktura parametrów:       
            %   .nr                  - numer kamery
            %   .resolution          - opc. rozdzielczość akwizycji (wg AvailableResolutions)
            obj.test        = 0;

            % -------------------------------------------------------
            % UZUPEŁNIJ_1 - tworzenie obiektu webcam (pomoc - wpisz w linii komend: doc webcam)
            %               - zapamiętaj obiekt webcam we własności klasy "vidObj"
            %                 - zwróć uwagę na odpowiednie odwołanie do własności klasy (poprzez obj.)
            %               - numer kamery pobierz ze struktury "parametryImportu"
            obj.vidObj = webcam(parametryImportu.nr);
            % obj.test = 1;
            


            % -------------------------------------------------------
            
            % opc. ustawianie rozdzielczości akwizycji
            if isfield(parametryImportu,'resolution')
                try
                    obj.vidObj.Resolution = parametryImportu.resolution;
                catch ME
                    warning('Podana rozdzielczość nie jest obsługiwana przez kamerę')
                    disp('Obsługiwane rozdzielczości: ')
                    disp(obj.vidObj.AvailableResolutions)
                end
            end
            
            % dane strumienia video            
            im1 = snapshot(obj.vidObj);
            obj.vidFPS          = inf; % obiekt webcam nie udostępnia tej informacji
            obj.nFrames         = inf; % obiekt webcam nie udostępnia tej informacji
            obj.imSize          = [size(im1,1) size(im1,2)];
            
            disp('---=== myDataSourceCam ===---')
            disp('Dane źródła video:       ')
            disp(['> numer kamery    = ' num2str(parametryImportu.nr)])
            disp(['> liczba ramek    = ' num2str(obj.nFrames)])
            disp(['> FPS             = ' num2str(obj.vidFPS)])
            disp(['> rozdzielczość   = ' num2str(obj.imSize(1)) 'x' num2str(obj.imSize(2))])                        
        end
        
        function dataFrame = pobierzDane(obj)
            % Odczyt kolejnej ramki 
            % OUTPUTS:
            % > dataFrame       - obraz RGB [m*n*3]

            % -------------------------------------------------------
            % UZUPEŁNIJ_2 - pobranie ramki obrazu z webcam (funkcja snapshot)
            dataFrame = snapshot(obj.vidObj);
            % obj.test = 2;
            % -------------------------------------------------------
        end
        
        function delete(obj)
            % Usuwanie obiektu (zwolnienie zasobów kamery)
            clear obj.vidObj 
        end
    end
end

