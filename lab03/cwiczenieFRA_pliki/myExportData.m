classdef myExportData < handle
    % Szablon klasy realizującej eksport danych
    % - w tym momencie klasa zapisuje do pliku txt kolejne numery ramek
    % WERSJA: 01.02.2023, R2022b
    % Przykład użycia: 
    %{
        parametryEksportu            = [];
        parametryEksportu.nazwapliku = 'out.txt';
        exportObj                    = myExportData(parametryEksportu);
        dane_do_eksportu             = [];
        dane_do_eksportu.iter        = 1;        
        exportObj.eksportujDane(dane_do_eksportu);
    
        delete(exportObj)       % używać tego zamiast "clear exportObj"
    %}
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
        function obj = myExportData(parametryEksportu)
            % Konstruktor klasy - tutaj odbywa się inicjalizacja np.
            % otwarcie pliku do zapisu
            % > parametryEksportu    - struktura parametrów eksportu
            %   .nazwapliku          - nazwa pliku wy TXT
            disp('---=== myExportData ===---')
            disp(['Nazwa pliku wyjściowego TXT  =       ' parametryEksportu.nazwapliku])
            obj.fid     = fopen(parametryEksportu.nazwapliku, 'wt');
        end
        
        function status = eksportujDane(obj, dane_do_eksportu)
            % Eksport kolejnej ramki danych
            % INPUTS:
            % > dane_do_eksportu       - dane do eksportu
            %   .iter                  - numer ramki
            % OUTPUTS:
            % > status                 - true/false
            try
                % try - jeśli wystąpi błąd zapisu do pliku, przejdź do
                % sekcji catch
                fprintf(obj.fid,'Ramka nr = %d\n', dane_do_eksportu.iter);
                status  = true;                
            catch ME
                status  = false; 
                disp([' > błąd przy zapisie do pliku TXT : ' ME.identifier])
                %rethrow(ME)                      
            end            
        end
        
        function delete(obj)
            % Usuwanie obiektów, zamykanie plików...
            fclose(obj.fid);
        end
    end
end

