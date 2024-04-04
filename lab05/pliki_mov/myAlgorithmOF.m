classdef myAlgorithmOF < handle
    % Detekcja ruchu OF (Horn-Schunck)
    %
    % - wartość OF wyliczana jest na obrazach w odcieniach szarości
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
        parametryAlg      = [];      
        parametryAlg.Smoothness = 5;
        parametryAlg.MaxIteration = 120;
        processVideoObj   = myAlgorithmOF(parametryAlg);
        outVidData        = processVideoObj.process(im0);      
        outVidData        = processVideoObj.process(im1); 
        figure;
        plot(outVidData.OF,'DecimationFactor',[5 5],'ScaleFactor',20)
    %}
    %
    
    % Własności dostępne do odczytu
    properties  (SetAccess = private)
        of                      % obiekt optical flow
    end
    
    % Własności prywatne (dostępne tylko z wnętrza klasy)
    properties  (Access = private)
    end    
    
    % Metody klasy
    methods
        function obj = myAlgorithmOF(params)
            % Konstruktor klasy (nazwa konstruktora taka jak nazwa klasy!)
            % - tutaj odbywa się inicjalizacja obiektu klasy
            % - w zależności od potrzeb dodać odpowiednie arg we, np.
            % > params          - struktura parametrów algorytmu: 
            %   .Smoothness     - parametr metody (więcej informacji >> doc opticalFlowHS)
            %   .MaxIteration   - parametr metody (więcej informacji >> doc opticalFlowHS)
            disp('---=== myAlgorithmOF ===---')
            obj.of      = opticalFlowHS('Smoothness',params.Smoothness,'MaxIteration',params.MaxIteration);
        end
        
        function danewy = process(obj, danewe)
            % Przetwarzanie kolejnej paczki danych
            % INPUTS:
            % > obj             - argument wymagany
            % > danewe          - dane wejściowe - tutaj obraz RGB
            % OUTPUTS:
            % > danewy          - dane wyjściowe
            %   .RGB               - kopia obrazu we RGB
            %   .OF                - rezultat optical flow (obiekt)
            %
            
            % konwersja do grayscale jeśli potrzeba
            if size(danewe,3)>1
                imwe   = rgb2gray(danewe);
            else
                imwe   = danewe;
            end   
            
            % obliczenie optical flow
            flowField = estimateFlow(obj.of, imwe);
            
            % przygotowanie danych wyjściowych
            danewy          = [];
            danewy.RGB      = danewe;
            danewy.OF       = flowField;       
        end
        
        function delete(obj)
            % Tutaj realizować usuwanie obiektów które tego wymagają, 
            % zamykać otwarte pliki, itp.
        end
    end
end

