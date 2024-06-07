classdef myExportDataCAMMOUSE < handle
    % Klasa realizująca eksport danych dla Camera Mouse
    % - w tym momencie klasa zapisuje do pliku txt kolejne numery ramek
    % WERSJA: 25.11.2020, R2020a
    %
    
    % Własności (dane, stan) dostępne do odczytu
    properties  (SetAccess = private)
    end
    
    % Własności prywatne
    properties  (Access = private)
        fid                 % uchwyt do pliku txt
    end    
    
    % Metody klasy
    methods
        function obj = myExportDataCAMMOUSE(parametryEksportu)
            % Konstruktor klasy - tutaj odbywa się inicjalizacja np.
            % otwarcie pliku do zapisu
            % > parametryEksportu    - struktura parametrów eksportu
            %   .nazwapliku          - nazwa pliku wy TXT
            disp('---=== myExportDataCAMMOUSE ===---')
            if ~isempty(parametryEksportu.nazwapliku)
                disp(['Nazwa pliku wyjściowego TXT  =       ' parametryEksportu.nazwapliku])
                obj.fid     = fopen(parametryEksportu.nazwapliku, 'wt');
                fprintf(obj.fid,'%s,%s,%s,%s\n', 'iter', 'facex', 'facey','t2');
            else
                obj.fid = [];
            end
        end
        
        function status = eksportujDane(obj, dane_do_eksportu)
            % Eksport kolejnej ramki danych
            % INPUTS:
            % > dane_do_eksportu       - dane do eksportu
            %   .iter                  - numer ramki
            %   .t2                    - czas przetwarzania poprzedniej ramki
            %   .bboxFace              - na tej podstawie liczony jest
            %                            srodek twarzy
            % OUTPUTS:
            % > status                 - true/false
            if ~isempty(obj.fid)
                try
                    % try - jeśli wystąpi błąd zapisu do pliku, przejdź do
                    % sekcji catch
                    if ~isempty(dane_do_eksportu.outVidData.bboxFace)
                        bboxFace = dane_do_eksportu.outVidData.bboxFace;
                        srodekTwarzy  = [bboxFace(1,1)+bboxFace(1,3)/2 bboxFace(1,2)+bboxFace(1,4)/2];
                    else
                        srodekTwarzy = [-1 -1];
                    end            
                    fprintf(obj.fid,'%d,%d,%d,%f\n', dane_do_eksportu.iter, srodekTwarzy(1), srodekTwarzy(2), dane_do_eksportu.t2);
                    status  = true;                
                catch ME
                    status  = false; 
                    disp([' > błąd przy zapisie do pliku TXT : ' ME.identifier])
                    %rethrow(ME)                      
                end      
            end
        end
        
        function delete(obj)
            % Usuwanie obiektów, zamykanie plików...
            if ~isempty(obj.fid)
                fclose(obj.fid);
            end
        end
    end
end

