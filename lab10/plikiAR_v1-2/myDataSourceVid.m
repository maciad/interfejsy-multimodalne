classdef myDataSourceVid < handle
    % Klasa realizująca odczyt danych z pliku video
    % - dla uproszczenia odczytywana jest kolejna ramka z pliku
    %   (aby odczytać ponownie 1szą ramkę utwórz ponownie obiekt tej klasy)
    % WERSJA: 17.09.2020, R2020a
    % Przykład użycia: 
    %{
         parametryImportu=[];
         parametryImportu.filename     = 'testVideo1.avi';
         vid1    = myDataSourceVid(parametryImportu);
         IM      = vid1.pobierzDane;
         vidFPS  = vid1.vidFPS;
         nFrames = vid1.nFrames;
         imSize  = vid1.imSize;
    %}
    %
    
    % Własności (dane, stan) dostępne do odczytu
    properties  (SetAccess = private)
        vidFPS              % FPS pliku video
        nFrames             % liczba ramek pliku video
        imSize              % rozmiar ramki obrazu
    end
    
    % Własności prywatne
    properties  (Access = private)
        vidObj              % obiekt VideoReader
    end    
    
    % Metody klasy
    methods
        function obj = myDataSourceVid(parametryImportu)
            % Konstruktor klasy - tutaj odbywa się inicjalizacja
            % INPUTS:
            % > parametryImportu    - struktura parametrów:       
            %   .filename             - nazwa pliku wejściowego
            obj.vidObj          = VideoReader(parametryImportu.filename); % do własności klasy odwołujemy się poprzez nazwę "obj."  
            obj.vidFPS          = obj.vidObj.FrameRate;
            obj.nFrames         = obj.vidObj.NumFrames;
            obj.imSize          = [obj.vidObj.Height obj.vidObj.Width];
            disp('---=== myDataSourceVid ===---')
            disp('Dane źródła video:       ')
            disp(['> nazwa pliku     = ' parametryImportu.filename])
            disp(['> liczba ramek    = ' num2str(obj.nFrames)])
            disp(['> FPS             = ' num2str(obj.vidFPS)])
            disp(['> rozdzielczość   = ' num2str(obj.imSize(1)) 'x' num2str(obj.imSize(2))])
            disp(['> format koloru   = ' obj.vidObj.VideoFormat])
        end
        
        function dataFrame = pobierzDane(obj)
            % Odczyt kolejnej ramki z pliku video   
            % OUTPUTS:
            % > dataFrame       - obraz RGB [m*n*3]
            dataFrame = readFrame(obj.vidObj);            
        end
        
        function delete(obj)
            % Dla VideoReader nie ma potrzeby usuwania obiektu
        end
    end
end

