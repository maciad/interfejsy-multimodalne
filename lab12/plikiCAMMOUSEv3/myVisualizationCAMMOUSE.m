classdef myVisualizationCAMMOUSE < handle
    % Klasa realizująca wizualizację danych dla CAMMOUSE
    % WERSJA: 25.11.2020, R2020a
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
        cursorData               % ostatnie N danych pozycji kursora (bufor)
        ii                       % iterator bufora kursora
    end

    % Metody klasy
    methods
        function obj = myVisualizationCAMMOUSE()
            % Konstruktor klasy - tutaj odbywa się inicjalizacja
            % 
            disp('---=== myVisualizationCAMMOUSE ===---')
            obj.videoPlayer  = figure;      % uchwyt do okna GUI
            guih             = [];            
            guih(1)          = uicontrol(obj.videoPlayer,'units','normalized','position',[0 0 0.2 0.05],...
                                    'string','stop','callback',@(src, event) handleButtons(obj, src, event));  
            guih(2)          = uicontrol(obj.videoPlayer,'units','normalized','position',[0.3 0 0.2 0.05],...
                                'string','pause','callback',@(src, event) handleButtons(obj, src, event));  
            guih(3)          = uicontrol(obj.videoPlayer,'units','normalized','position',[0.7 0 0.2 0.05],...
                                'string','zrzut ekranu','callback',@(src, event) handleButtons(obj, src, event)); 
            obj.stopCond     = 1;           
            obj.pauseCond    = 0;  
            obj.cursorData   = -1*zeros(30*5,2);
            obj.ii           = 1;
        end
        
        function wyswietlDane(obj, data)
            % Wizualizacja danych "data" na wykresie   
            % INPUTS:
            % > data       - dane do wizualizacji (struktura)
            %   .outVidData  - struktura danych zwracana przez algorytm
            %   .iter        - numer ramki
            
            subplot(2,2,1);
            obrazwy = data.outVidData.RGB;
            if ~isempty(data.outVidData.bboxFace)&data.outVidData.bboxFace(1)>=0&data.outVidData.bboxFace(3)>0&data.outVidData.bboxFace(4)>0
                obrazwy = insertObjectAnnotation(obrazwy, 'rectangle',data.outVidData.bboxFace,'Twarz');
                srodekTwarzy  = [data.outVidData.bboxFace(1,1)+data.outVidData.bboxFace(1,3)/2 data.outVidData.bboxFace(1,2)+data.outVidData.bboxFace(1,4)/2];  
                obrazwy = insertMarker(obrazwy, [srodekTwarzy(1) srodekTwarzy(2)], 'o', 'Color', 'yellow', 'size', 12);
                obrazwy = insertMarker(obrazwy, [srodekTwarzy(1) srodekTwarzy(2)], 'o', 'Color', 'yellow', 'size', 8);
            else
                obrazwy = insertText(obrazwy,[10 10],'Nie wykryto twarzy');
            end            
            %if ~isempty(data.outVidData.points)
            %    obrazwy = insertMarker(obrazwy, data.outVidData.points, '+', 'Color', 'white');
            %end            
            imshow(obrazwy)
            title(['Ramka nr ' num2str(data.iter)])
            
            if ~isempty(data.outVidData.cursorData)
                % bufor pozycji kursora
                obj.cursorData(obj.ii,:) = data.outVidData.cursorData(1:2);
                obj.ii = obj.ii + 1;
                if obj.ii>size(obj.cursorData,1)
                    obj.ii = 1;
                end
                
                % wizualizacja
                subplot(2,2,2);
                plot(data.outVidData.cursorData(1), data.outVidData.cursorData(2), 'bo', 'MarkerSize', 8)                
                hold on
                plot(obj.cursorData(:,1),obj.cursorData(:,2),'r.');
                %plot(data.outVidData.cursorData(3), data.outVidData.cursorData(4), 'rx', 'MarkerSize', 8)
                hold off
                xlim([0 1])
                ylim([0 1])
                axis square                                               
                
                if length(data.outVidData.cursorData)>2
                    subplot(2,2,3);
                    plot(data.outVidData.cursorData(3), data.outVidData.cursorData(4), 'bo', 'MarkerSize', 8)
                    rectangle('Position',[-data.outVidData.parametry.histereza ...
                        -data.outVidData.parametry.histereza ...
                        data.outVidData.parametry.histereza*2 data.outVidData.parametry.histereza*2]);
                    tmp1 = 4*data.outVidData.parametry.histereza;
                    tmp2 = 3*data.outVidData.parametry.histereza;
                    xlim([-tmp1 tmp1])
                    ylim([-tmp1 tmp1])
                    %text(-tmp1,-tmp2,['x2=' num2str(data.outVidData.cursorData(3),1) ', y2=' num2str(data.outVidData.cursorData(3),1)])
                    title('wychylenia "joysticka"')
                    axis square
                end
            end

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
            elseif strcmp(src.String,'zrzut ekranu')
                exportgraphics(obj.videoPlayer,['sterowanie_rezultat_1.jpg']);
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

