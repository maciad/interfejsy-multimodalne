classdef myVisualizationTRACK < handle
    % Klasa realizująca wizualizację danych dla śledzenia twarzy
    % WERSJA: 13.11.2020, R2020a
    % Przykład użycia: 
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
        function obj = myVisualizationTRACK()
            % Konstruktor klasy - tutaj odbywa się inicjalizacja
            % 
            disp('---=== myVisualizationTRACK ===---')
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
            %   .outVidData.RGB  - obraz do wyświetlenia
            %   .iter        - numer ramki
                        
            subplot(1,2,1);
            obrazwy = data.outVidData.RGB;
            if ~isempty(data.outVidData.bboxFace)
                obrazwy = insertObjectAnnotation(obrazwy, 'rectangle',data.outVidData.bboxFace,'Twarz');
            else
                obrazwy = insertText(obrazwy,[10 10],'Nie wykryto twarzy');
            end
            if ~isempty(data.outVidData.bboxNos)
                obrazwy = insertObjectAnnotation(obrazwy, 'rectangle',data.outVidData.bboxNos,'Nos');
            else
                obrazwy = insertText(obrazwy,[10 30],'Nie wykryto nosa');
            end            
            if ~isempty(data.outVidData.bboxUsta)
                obrazwy = insertObjectAnnotation(obrazwy, 'rectangle',data.outVidData.bboxUsta,'Usta');
            else
                obrazwy = insertText(obrazwy,[10 60],'Nie wykryto ust');
            end
            if ~isempty(data.outVidData.points)
                obrazwy = insertMarker(obrazwy, data.outVidData.points, '+', 'Color', 'white');
            end
            
            imshow(obrazwy)
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

