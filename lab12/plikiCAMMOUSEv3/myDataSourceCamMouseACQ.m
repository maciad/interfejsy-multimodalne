classdef myDataSourceCamMouseACQ < handle
    % Klasa realizująca odczyt danych z kamery (interfejs Image
    % Acquisition)
    %
    % WERSJA: 22.12.2023, R2023b
    %
    
    % Własności (dane, stan) dostępne do odczytu
    properties  (SetAccess = private)
        vidFPS              % FPS strumienia video (w tym przypadku = inf)
        nFrames             % liczba ramek pliku video (w tym przypadku = inf)
        imSize              % rozmiar ramki obrazu
    end
    
    % Własności prywatne
    properties  (Access = private)
        vidObj              % obiekt kamery
    end    
    
    % Metody klasy
    methods
        function obj = myDataSourceCamMouseACQ(parametryImportu)
            % Konstruktor klasy - tutaj odbywa się inicjalizacja
            % > parametryImportu    - struktura parametrów:       
            %   .nr                  - numer kamery
            %   .resolution          - opc. rozdzielczość akwizycji 
            %                         (wg imaqhwinfo('winvideo').DeviceInfo(1).SupportedFormats')
            
            % -------------------------------------------------------
            % tworzenie obiektu video
            %obj.vidObj          = webcam(parametryImportu.nr);
            obj.vidObj          = videoinput("winvideo", parametryImportu.nr, parametryImportu.resolution);
            obj.vidObj.FramesPerTrigger = Inf;
            obj.vidObj.ReturnedColorspace = "rgb";
            % -------------------------------------------------------
            
            % opc. ustawianie rozdzielczości akwizycji
            % if isfield(parametryImportu,'resolution')
            %     try
            %         disp('Obsługiwane rozdzielczości: ')
            %         disp(obj.vidObj.AvailableResolutions)
            %         obj.vidObj.Resolution = parametryImportu.resolution;
            %     catch ME
            %         disp('Podana rozdzielczość nie jest obsługiwana przez kamerę')
            %         disp('Obsługiwane rozdzielczości: ')
            %         disp(obj.vidObj.AvailableResolutions)
            %     end
            % end
            
            % dane strumienia video
            start(obj.vidObj);
            im1 = getsnapshot(obj.vidObj);
            
            obj.vidFPS          = inf; % obiekt  nie udostępnia tej informacji
            obj.nFrames         = inf; % obiekt  nie udostępnia tej informacji
            obj.imSize          = [size(im1,1) size(im1,2)];
            
            disp('---=== myDataSourceCamMouse ===---')
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
            % pobranie ramki obrazu z webcam
            dataFrame = getsnapshot(obj.vidObj);            
            % -------------------------------------------------------
        end
        
        function delete(obj)
            % Usuwanie obiektu (zwolnienie zasobów kamery)
            stop(obj.vidObj);
            clear obj.vidObj 
        end
    end
end

