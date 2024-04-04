classdef myAlgorithmSAD < handle
    % Detekcja ruchu SAD
    %
    % - wartość SAD wyliczana jest na obrazach w odcieniach szarości
    %   (w tym celu obrazy we są zamieniane na grayscale przy pomocy
    %   funkcji rgb2gray)
    % - uwaga: klasa nie posiada zaimplementowanej kontroli poprawności 
    %          argumentów wejściowych i parametrów
    % WERSJA: 12.10.2020, R2020a
    % Przykład użycia: 
    %{
        vidObj          = VideoReader('motion1.avi');
        im0             = read(vidObj,1);
        im1             = read(vidObj,55);
        parametryAlg      = [];
        parametryAlg.tlo  = im0;
        parametryAlg.threshold = 20;
        processVideoObj   = myAlgorithmSAD(parametryAlg);
        outVidData        = processVideoObj.process(im1);  
        imtool(outVidData.DIFFIM,[])      
        outVidData.sum
        outVidData.motion
    %}
    %
    
    % Własności dostępne do odczytu
    properties  (SetAccess = private)
        bcg                     % tło lub poprzednia ramka video
        threshold               % próg detekcji ruchu
        type                    % sposób liczenia: 0-odejmowanie kolejnych ramek od siebie
                                %                  1-odejmowanie tła
    end
    
    % Własności prywatne (dostępne tylko z wnętrza klasy)
    properties  (Access = private)
    end    
    
    % Metody klasy
    methods
        function obj = myAlgorithmSAD(params)
            % Konstruktor klasy (nazwa konstruktora taka jak nazwa klasy!)
            % - tutaj odbywa się inicjalizacja obiektu klasy
            % - w zależności od potrzeb dodać odpowiednie arg we, np.
            % > params          - struktura parametrów algorytmu: 
            %   .tlo            - obraz tła (jeśli pusty to algorytm będzie
            %                     wyznaczał obraz różnicowy na podstawie różnicy
            %                     kolejnych ramek 
            %   .threshold      - próg detekcji ruchu
            disp('---=== myAlgorithmSAD ===---')
            if isempty(params.tlo)
                % puste tło
                obj.bcg = [];
                obj.type = 0;
            else           
                % tło - sprawdzanie czy RGB czy grayscale
                if size(params.tlo,3)>1
                    obj.bcg                 = rgb2gray(params.tlo);
                else
                    obj.bcg                 = params.tlo;
                end
                obj.type = 1;
            end
            obj.threshold               = params.threshold;
        end
        
        function danewy = process(obj, danewe)
            % Przetwarzanie kolejnej paczki danych
            % INPUTS:
            % > obj             - argument wymagany
            % > danewe          - dane wejściowe - tutaj obraz RGB
            % OUTPUTS:
            % > danewy          - dane wyjściowe
            %   .RGB               - kopia obrazu we RGB
            %   .DIFFIM            - różnica obrazów
            %   .sum               - znormalizowana suma pixeli obrazu
            %                        różnicowego (suma/liczba pixeli)
            %   .motion            - detekcja ruchu (0 lub 1)
            %
            
            % konwersja do grayscale jeśli potrzeba
            if size(danewe,3)>1
                imwe   = rgb2gray(danewe);
            else
                imwe   = danewe;
            end   
            
            % inicjaliazcja tla pierwszą ramką jesli nie podano go jako parametr
            if obj.type == 0 && isempty(obj.bcg)
                obj.bcg = imwe;
            end
            
            % wyznaczanie obrazu różnicowego
            obrazroznicowy   = imabsdiff(obj.bcg, imwe);
         
            % wyznaczanie SAD
            sumofabsdiff    = sum(sum(double(obrazroznicowy)))/numel(obrazroznicowy);
            
            % detekcja ruchu - progowanie sumy pikseli
            motion          = sumofabsdiff > obj.threshold;
            
            % uaktualnienie tła (po wykonaniu obliczeń)
            if obj.type == 0
                obj.bcg = imwe;
            end
            
            % przygotowanie danych wyjściowych
            danewy          = [];
            danewy.RGB      = danewe;
            danewy.DIFFIM   = obrazroznicowy;
            danewy.sum      = sumofabsdiff;            
            danewy.motion   = motion;
        end
        
        function delete(obj)
            % Tutaj realizować usuwanie obiektów które tego wymagają, 
            % zamykać otwarte pliki, itp.
        end
    end
end

