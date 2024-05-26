classdef myVisualizationAR < handle
    % Klasa realizująca wizualizację danych dla AR
    % WERSJA: 01.12.2020, R2020a
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
        function obj = myVisualizationAR()
            % Konstruktor klasy - tutaj odbywa się inicjalizacja
            % 
            disp('---=== myVisualizationAR ===---')
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
            %   .outVidData  - dane do wyświetlenia
            %   .iter        - numer ramki
                        
            subplot(1,1,1);
            imshow(data.outVidData.RGB)
            
            if ~isempty(data.outVidData.skala1)
                % - przykładowy obiekt 
                [X,Y,Z] = cylinder(1, 21);
                X       = X * data.outVidData.skala1(1)/2 + data.outVidData.srodek1(1);
                Y       = Y * data.outVidData.skala1(1)/2 + data.outVidData.srodek1(2);
                Z       = -Z * data.outVidData.skalaZ;
                % rzutowanie współrzędnych obiektu na obraz
                x1 = X(1,:);y1 = Y(1,:);z1 = Z(1,:);
                x2 = X(2,:);y2 = Y(2,:);z2 = Z(2,:);
                projectedPoints1 = worldToImage(data.outVidData.cameraParams, data.outVidData.R, data.outVidData.t, [x1(:) y1(:) z1(:)]);
                projectedPoints2 = worldToImage(data.outVidData.cameraParams, data.outVidData.R, data.outVidData.t, [x2(:) y2(:) z2(:)]);
                hold on
                plot(projectedPoints1(:,1), projectedPoints1(:,2),'r.');
                plot(projectedPoints2(:,1), projectedPoints2(:,2),'r.');
                for i=1:size(projectedPoints1,1)
                    plot([projectedPoints1(i,1) projectedPoints2(i,1)],...
                        [projectedPoints1(i,2) projectedPoints2(i,2)],'m-')
                end
                for i=1:size(projectedPoints1,1)-1
                    plot([projectedPoints1(i,1) projectedPoints1(i+1,1)],...
                        [projectedPoints1(i,2) projectedPoints1(i+1,2)],'m-')
                    plot([projectedPoints2(i,1) projectedPoints2(i+1,1)],...
                        [projectedPoints2(i,2) projectedPoints2(i+1,2)],'m-')
                end
                hold off

            end
            
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

