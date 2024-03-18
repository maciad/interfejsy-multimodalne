classdef myVisualization0 < handle
    % Klasa realizująca wizualizację danych
    % WERSJA: 01.02.2023, R2022b
    % Przykład użycia: 
    %{
       A                = imread('ngc6543a.jpg');
       vis1             = myVisualization0;
       dane             = [];
       dane.outVidData  = A;
       dane.iter        = 10;
       vis1.wyswietlDane(dane)
    
       delete(vis1)  % używać tego zamiast "clear vis1"
    %}
    %
    
    % Własności dostępne do odczytu
    properties  (SetAccess = private)
        stopCond                 % flaga zakończenia przetwarzania (ustawiana w GUI na 0 co oznacza zakończenie działania aplikacji)
        pauseCond                % flaga włączenia pauzy przetwarzania (ustawiana w GUI na 1 oznacza pauzę, na 0 - wznowienie przetwarzania)      
    end
    
    % Własności prywatne
    properties  (Access = private)
        videoPlayer              % uchwyt do okna wykresu
    end

    % Metody klasy
    methods
        function obj = myVisualization0()
            % Konstruktor klasy - tutaj odbywa się inicjalizacja
            % 
            disp('---=== myVisualization0 ===---')
            obj.videoPlayer  = figure;      % uchwyt do okna GUI
            guih             = [];            
            guih(1)          = uicontrol(obj.videoPlayer,'units','normalized','position',[0 0 0.2 0.05],...
                                    'string','stop','callback',@(src, event) handleButtons(obj, src, event));  
            guih(2)          = uicontrol(obj.videoPlayer,'units','normalized','position',[0.3 0 0.2 0.05],...
                                'string','pause','callback',@(src, event) handleButtons(obj, src, event));  
            obj.stopCond     = 1;           
            obj.pauseCond    = 0;           
        end
        
        function wyswietlDane(obj, data)
            % Wizualizacja danych "data" na wykresie   
            % INPUTS:
            % > data       - dane do wizualizacji (struktura)
            %   .outVidData  - obraz do wyświetlenia
            %   .iter        - numer ramki
                        
            subplot(1,2,1);
            imshow(data.outVidData)
            title(['Ramka nr ' num2str(data.iter)])
        end
        
        function delete(obj)
            % Usuwanie obiektu
            close(obj.videoPlayer)
        end
    end
    methods (Access = private)
        function handleButtons(obj, src, event)
            % Metoda wewnętrzna - obsługa przycisków
            if strcmp(src.String,'stop')
                obj.stopCond = 0;
                %disp('nacisnieto stop')
            else % w przypadku rozbudowy o kolejne przyciski, tutaj porównać nazwę z "pause" i "continue"
                if obj.pauseCond==1                    
                    obj.pauseCond = 0;
                    src.String = 'pause';                    
                else
                    obj.pauseCond = 1;
                    src.String = 'continue';
                end                
            end            
        end
    end
end

