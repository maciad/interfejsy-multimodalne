classdef myAlgorithmMHI < handle
    % Detekcja ruchu MHI
    %
    % - wartość MHI wyliczana jest na obrazach w odcieniach szarości
    %   (w tym celu obrazy we są zamieniane na grayscale przy pomocy
    %   funkcji rgb2gray)
    % - uwaga: klasa nie posiada zaimplementowanej kontroli poprawności 
    %          argumentów wejściowych i parametrów
    % WERSJA: 12.10.2020, R2020a
    % Przykład użycia: 
    %{
        vidObj          = VideoReader('motion1.avi');
        im0             = read(vidObj,50);
        im1             = read(vidObj,51);
        im2             = read(vidObj,52);
        im3             = read(vidObj,53);
        im4             = read(vidObj,54);    
        parametryAlg      = [];
        parametryAlg.threshold = 20;
        parametryAlg.tau  = 3;
        processVideoObj   = myAlgorithmMHI(parametryAlg);
        outVidData        = processVideoObj.process(im0); 
        outVidData        = processVideoObj.process(im1);  
        outVidData        = processVideoObj.process(im2);  
        outVidData        = processVideoObj.process(im3);  
        outVidData        = processVideoObj.process(im4);      
        imtool(outVidData.MHI,[0 parametryAlg.tau]);        
    %}
    %
    
    % Własności dostępne do odczytu
    properties  (SetAccess = private)
        prevIM                  % poprzednia ramka video
        prevMHI                 % poprzednia ramka MHI
        threshold               % próg detekcji ruchu
        tau                     % parametr MHI
    end
    
    % Własności prywatne (dostępne tylko z wnętrza klasy)
    properties  (Access = private)
    end    
    
    % Metody klasy
    methods
        function obj = myAlgorithmMHI(params)
            % Konstruktor klasy (nazwa konstruktora taka jak nazwa klasy!)
            % - tutaj odbywa się inicjalizacja obiektu klasy
            % - w zależności od potrzeb dodać odpowiednie arg we, np.
            % > params          - struktura parametrów algorytmu: 
            %   .threshold      - próg detekcji ruchu (motion threshold)
            %   .tau            - parametr Tau
            disp('---=== myAlgorithmMHI ===---')
            obj.prevIM                  = [];
            obj.prevMHI                 = [];
            obj.threshold               = params.threshold;
            obj.tau                     = params.tau;
        end
        
        function danewy = process(obj, danewe)
            % Przetwarzanie kolejnej paczki danych
            % INPUTS:
            % > obj             - argument wymagany
            % > danewe          - dane wejściowe - tutaj obraz RGB
            % OUTPUTS:
            % > danewy          - dane wyjściowe
            %   .RGB               - kopia obrazu we RGB
            %   .MHI               - obraz MHI
            %   .BW                - obraz po binaryzacji z progiem motion threshold
            %
            
            % konwersja do grayscale jeśli potrzeba
            if size(danewe,3)>1
                imwe   = rgb2gray(danewe);
            else
                imwe   = danewe;
            end   
            
            % inicjalizacja pierwszej ramki
            if isempty(obj.prevIM)
                obj.prevIM = imwe;
                obj.prevMHI= zeros(size(imwe,1),size(imwe,2));
            end
            
            % wyznaczanie obrazu różnicowego (poprzednia ramka i aktualna)
            % (imabsdiff wyznacza od razu wartość bezwzgledną  z różnicy)
            obrazroznicowy   = imabsdiff(obj.prevIM, imwe);
         
            % progowanie
            BW               = obrazroznicowy > obj.threshold;
            
            % wyznaczanie MHI
            % - BW przyjmuje wartości 0 i 1
            % - obj.prevMHI to obraz MHI z poprzedniej iteracji
            MHI              = BW*obj.tau + (~BW).*obj.prevMHI;            

            
            % uaktualnienie poprzedniego obrazu i MHI (po wykonaniu obliczeń)            
            obj.prevIM  = imwe;
            obj.prevMHI = (MHI-1);         % odejmowanie 1 od MHI
            obj.prevMHI(obj.prevMHI<0) = 0;% jesli MHI<0 to 0
            
            % przygotowanie danych wyjściowych
            danewy          = [];
            danewy.RGB      = danewe;
            danewy.MHI      = MHI;    
            danewy.BW       = BW;    
        end
        
        function delete(obj)
            % Tutaj realizować usuwanie obiektów które tego wymagają, 
            % zamykać otwarte pliki, itp.
        end
    end
end

