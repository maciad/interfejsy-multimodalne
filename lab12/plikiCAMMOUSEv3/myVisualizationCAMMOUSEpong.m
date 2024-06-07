classdef myVisualizationCAMMOUSEpong < handle
    % Klasa realizująca wizualizację danych dla CAMMOUSE + prosty PONG
    % Na podstawie: https://www.mathworks.com/matlabcentral/fileexchange/69833-pong
    % WERSJA: 30.09.2021, R2021b
    % WERSJA: 02.01.2024, R2023b    
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

        ball_pos                 % współrzędne i prędkość piłki
        ball_vel 
        ball                     % obiekt piłki
        block                    % obiekt paletki
        block_size               % szerokość paletki

        subplot1                 % obiekty osi
        subplot2
        subplot3

        ballmiss                 % licznik opuszczonych piłeczek
    end

    % Metody klasy
    methods
        function obj = myVisualizationCAMMOUSEpong()
            % Konstruktor klasy - tutaj odbywa się inicjalizacja
            % 
            disp('---=== myVisualizationCAMMOUSEpong ===---')
            obj.videoPlayer  = figure;      % uchwyt do okna GUI
            guih             = [];            
            guih(1)          = uicontrol(obj.videoPlayer,'units','normalized','position',[0 0 0.2 0.05],...
                                    'string','stop','callback',@(src, event) handleButtons(obj, src, event));  
            guih(2)          = uicontrol(obj.videoPlayer,'units','normalized','position',[0.3 0 0.2 0.05],...
                                'string','continue','callback',@(src, event) handleButtons(obj, src, event));  
            guih(3)          = uicontrol(obj.videoPlayer,'units','normalized','position',[0.7 0 0.2 0.05],...
                                'string','zrzut ekranu','callback',@(src, event) handleButtons(obj, src, event)); 
            
            % osie na wykresie
            obj.subplot1     = subplot(2,3,1);
            obj.subplot2     = subplot(2,3,[2:3 5:6]);
            obj.subplot3     = subplot(2,3,4);
            
            % położenie i prędkość początkowa piłeczki
            obj.ball_pos     = [0.5 0.8];
            obj.ball_vel     = [0.02 0.02];

            obj.block_size = 0.1; % szerokość paletki
            axes(obj.subplot2) % inicjalizacja piłki i paletki
            obj.ball = plot(obj.ball_pos(1),obj.ball_pos(2), ...
                'color', 'blue',  ...
                'marker', '.', ...
                'markersize',50);
            hold on
            obj.block = plot([0.5-obj.block_size 0.5+obj.block_size],...
                    [0.05 0.05], 'b-', 'LineWidth', 20);
            hold off
            xlim([0 1])
            ylim([0 1])

            obj.stopCond     = 1;           
            obj.pauseCond    = 1;  
            obj.cursorData   = -1*zeros(30*5,2);
            obj.ii           = 1;

            obj.ballmiss     = 0; % licznik opuszczonych piłeczek
        end
        
        function wyswietlDane(obj, data)
            % Wizualizacja danych "data" na wykresie   
            % INPUTS:
            % > data       - dane do wizualizacji (struktura)
            %   .outVidData  - struktura danych zwracana przez algorytm
            %   .iter        - numer ramki
            
            

            % Ball bounce if out of bounds left/right/top        
            if (obj.ball_pos(1)) > 1
                obj.ball_vel(1) = - obj.ball_vel(1);
            end
            if (obj.ball_pos(1)) < 0
                obj.ball_vel(1) = - obj.ball_vel(1);
            end
            if obj.ball_pos(2) > 1
                obj.ball_vel(2) = - obj.ball_vel(2); 
            end

            % sterowanie paletką
            if ~isempty(data.outVidData.cursorData)
                block_pos = data.outVidData.cursorData(1);
            else
                block_pos = 0.5;
            end
            
            % sterowanie piłeczką
            % If ball low, check positions then bounce or reset
            if obj.ball_pos(2) < 0.08                
                % miss
                if abs(block_pos - obj.ball_pos(1)) > obj.block_size                    
                    obj.ball.Color  = rand(1,3);          
                    obj.ball_pos(2) = 1; 
                    obj.ballmiss    = obj.ballmiss + 1;
                % not miss
                else 
                    obj.ball_vel(2) = - obj.ball_vel(2);
                end
            end

            % Update ball       
            obj.ball_pos  = obj.ball_pos  + obj.ball_vel;
            %block_pos = block_pos + block_vel;

            % wizualizacja detekcji twarzy
            axes(obj.subplot1); %subplot(2,3,1);
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
                      
            % wizualizacja planszy gry
            if ~isempty(data.outVidData.cursorData)
                % bufor pozycji kursora
                obj.cursorData(obj.ii,:) = data.outVidData.cursorData(1:2);
                obj.ii = obj.ii + 1;
                if obj.ii>size(obj.cursorData,1)
                    obj.ii = 1;
                end
                
                % wizualizacja                
                axes(obj.subplot2);%subplot(2,3,2:3);
                set(obj.ball, ...
                    'XData', obj.ball_pos(1), ...
                    'YData', obj.ball_pos(2));                   
                set(obj.block, ...
                    'XData', [data.outVidData.cursorData(1)-obj.block_size data.outVidData.cursorData(1)+obj.block_size], ...
                    'YData', [0.05 0.05]);
                title(['Liczba opuszczonych piłeczek = ' num2str(obj.ballmiss)])
                %plot(data.outVidData.cursorData(1), data.outVidData.cursorData(2), 'bo', 'MarkerSize', 8)                
                    %plot([data.outVidData.cursorData(1)-block_size data.outVidData.cursorData(1)+block_size],...
                    %    [0.05 0.05], 'b-', 'LineWidth', 20)
                %hold on
                %plot(obj.cursorData(:,1),obj.cursorData(:,2),'r.');
                %%plot(data.outVidData.cursorData(3), data.outVidData.cursorData(4), 'rx', 'MarkerSize', 8)
                %hold off
                %xlim([0 1])
                %ylim([0 1])
                %axis square                                               
                
                % wizualizacja położenia "joysticka" jeśli użyto do
                % sterowania "testHArness_CAMMOUSE_cz3.m)
                if length(data.outVidData.cursorData)>2
                    axes(obj.subplot3);%subplot(2,3,4);
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

