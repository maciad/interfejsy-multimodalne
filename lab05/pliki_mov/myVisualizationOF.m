classdef myVisualizationOF < handle
    % Klasa realizująca wizualizację danych dla ćwiczenia optical flow
    % WERSJA: 12.10.2020, R2020a
    % Przykład użycia: 
    %{
        vidObj          = VideoReader('motion1.avi');
        im0             = read(vidObj,50);
        im1             = read(vidObj,51);
        of              = opticalFlowHS;
        flowField       = estimateFlow(of, rgb2gray(im0));
        flowField       = estimateFlow(of, rgb2gray(im1));       
        vis1             = myVisualizationOF;
        dane             = [];       
        dane.outVidData.RGB  = im0;
        dane.outVidData.OF  = flowField;
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
        function obj = myVisualizationOF()
            % Konstruktor klasy - tutaj odbywa się inicjalizacja
            % 
            disp('---=== myVisualizationOF ===---')
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
            %   .outVidData.RGB     - obraz RGB do wyświetlenia
            %   .outVidData.OF      - obiekt optical flow
            %   .iter        - numer ramki
                 
            I = rgb2gray(data.outVidData.RGB);
            ax1=subplot(2,2,1);
            imshow(data.outVidData.RGB)       
            title(['Ramka nr ' num2str(data.iter)])
            ax2=subplot(2,2,2);
            imshow(I);
            hold on
            plot(data.outVidData.OF,...
                'DecimationFactor',[5 5],'ScaleFactor',20)
            hold off
            title('Optical flow')  
            
            horizontalMotion = data.outVidData.OF.Vx;
            verticalMotion = data.outVidData.OF.Vy;
            ax3=subplot(2,2,3);
            imshow(I);
            imshow(horizontalMotion,[0 1])
            colormap(ax3,jet)
            title('Optical flow - składowa Vx')    
            ax4=subplot(2,2,4);
            imshow(I);
            imshow(verticalMotion,[0 1]);
            colormap(ax4,jet)
            title('Optical flow - składowa Vy')    
            
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

