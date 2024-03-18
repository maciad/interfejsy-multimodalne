function handleButtons_0(src, event)
% Obsługa przycisków GUI 
%   - kazdy przycisk zapamiętuje swoj stan w polu UserData
%   - kazdy przycisk jest identyfikowany poprzez arg we "src"
%
    if strcmp(src.String,'stop')
        % flaga zakończenia przetwarzania (ustawiana w GUI na 0 co oznacza zakończenie działania aplikacji)        
        src.UserData = 0;
        %disp('nacisnieto stop')
    else 
        % flaga włączenia pauzy przetwarzania (ustawiana w GUI na 1 oznacza pauzę, na 0 - wznowienie przetwarzania)      
        if src.UserData==1                    
            src.UserData = 0;
            src.String = 'pause';                    
        else
            src.UserData = 1;
            src.String = 'continue';
        end                
    end            
end