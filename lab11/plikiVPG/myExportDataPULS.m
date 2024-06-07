classdef myExportDataPULS < handle
    % Klasa realizująca eksport danych dla algorytmu detekcji pulsu
    %
    % WERSJA: 03.12.2020, R2020a
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
        function obj = myExportDataPULS(parametryEksportu)
            % Konstruktor klasy - tutaj odbywa się inicjalizacja np.
            % otwarcie pliku do zapisu
            % > parametryEksportu    - struktura parametrów eksportu
            %   .nazwapliku          - nazwa pliku wy TXT
            disp('---=== myExportDataPULS ===---')
            if ~isempty(parametryEksportu.nazwapliku)
                disp(['Nazwa pliku wyjściowego TXT  =       ' parametryEksportu.nazwapliku])
                obj.fid     = fopen(parametryEksportu.nazwapliku, 'wt');
                fprintf(obj.fid,'%s,%s,%s,%s,%s\n', 'iter', 't2', 'sumr','sumg','sumb');
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
            %   .bboxFace              - ROI twarzy (1x4)
            %   .sumpx                 - suma pikseli w ROI twarzy (1x3)
            % OUTPUTS:
            % > status                 - true/false
            if ~isempty(obj.fid)
                try
                    % try - jeśli wystąpi błąd zapisu do pliku, przejdź do
                    % sekcji catch                             
                    fprintf(obj.fid,'%d,%f,%f,%f,%f\n', dane_do_eksportu.iter, dane_do_eksportu.t2, ...
                        dane_do_eksportu.outVidData.sumpx(1), dane_do_eksportu.outVidData.sumpx(2), dane_do_eksportu.outVidData.sumpx(3));
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

