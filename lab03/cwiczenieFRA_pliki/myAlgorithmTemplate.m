classdef myAlgorithmTemplate < handle
    % Szablon klasy realizującej przetwarzanie danych 
    % - przykład dla analizy video
    % WERSJA: 01.02.2023, R2022b
    % Przykład użycia: 
    %{
        A = imread('ngc6543a.jpg');
        parametryAlg      = [];
        parametryAlg.nr   = 1;
        processVideoObj   = myAlgorithmTemplate(parametryAlg);
        outVidData        = processVideoObj.process(A);      
    %}
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
        function obj = myAlgorithmTemplate(params)
            % Konstruktor klasy (nazwa konstruktora taka jak nazwa klasy!)
            % - tutaj odbywa się inicjalizacja obiektu klasy
            % - w zależności od potrzeb dodać odpowiednie arg we, np.
            % > params          - struktura parametrów algorytmu: 
            %   .nr               - numer składowej (R,G lub B) obrazu do analizy
            disp('---=== myAlgorithmTemplate ===---')
            obj.params              = params; % do własności klasy odwołujemy się poprzez nazwę "obj."            
        end
        
        function danewy = process(obj, danewe)
            % Przetwarzanie kolejnej paczki danych
            % INPUTS:
            % > obj             - argument wymagany
            % > danewe          - dane wejściowe - tutaj obraz RGB
            % OUTPUTS:
            % > danewy          - dane wyjściowe - wybrana składowa z obrazu RGB            
            danewy          = danewe(:,:,obj.params.nr);  
            %[danewy,maskedImage] = segmentImage_test(danewe(:,:,obj.params.nr));
        end
        
        function delete(obj)
            % Tutaj realizować usuwanie obiektów które tego wymagają, 
            % zamykać otwarte pliki, itp.
        end
    end
end

