classdef myVisualizationPULS < handle
    % Klasa realizująca wizualizację danych dla PULS
    % WERSJA: 03.12.2020, R2020a
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
        sumpx                    % ostatnie N danych sumy pixeli (bufor)
        ii                       % iterator bufora 
        t1                       % czas poczatku przetwarzania
    end

    % Metody klasy
    methods
        function obj = myVisualizationPULS()
            % Konstruktor klasy - tutaj odbywa się inicjalizacja
            % 
            disp('---=== myVisualizationPULS ===---')
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
            obj.sumpx        = zeros(256,3);
            obj.ii           = 1;
            obj.t1           = clock;
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
            else
                obrazwy = insertText(obrazwy,[10 10],'Nie wykryto twarzy');
            end            
            %if ~isempty(data.outVidData.points)
            %    obrazwy = insertMarker(obrazwy, data.outVidData.points, '+', 'Color', 'white');
            %end            
            imshow(obrazwy)
            t2    = clock;
            difft = duration(t2(4),t2(5),t2(6))-duration(obj.t1(4),obj.t1(5),obj.t1(6));
            title(['Ramka nr ' num2str(data.iter) ', czas = ' char(difft)])
            
            % bufor sumy pikseli
            obj.sumpx(obj.ii,:) = data.outVidData.sumpx(1:3);
            obj.ii = obj.ii + 1;
            if obj.ii>size(obj.sumpx,1)
                obj.ii = 1;
            end            
            % wizualizacja
            subplot(2,2,3:4);
            plot(obj.sumpx, 'b')          
            title('suma pixeli w ROI')
            
            drawnow;
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

