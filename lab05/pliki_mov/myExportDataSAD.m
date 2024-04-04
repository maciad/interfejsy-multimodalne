classdef myExportDataSAD < handle
    % Klasa realizująca eksport danych dla ćwiczenia SAD
    % - zapisuje do pliku txt kolejne numery ramek oraz wartości SAD
    % WERSJA: 12.10.2020, R2020a
    % Przykład użycia: 
    %{
        RGB                          = imread('ngc6543a.jpg');
        parametryEksportu            = [];
        parametryEksportu.nazwapliku = 'out.txt';
        exportObj                    = myExportDataSAD(parametryEksportu);
        dane_do_eksportu             = [];
        dane_do_eksportu.iter        = 1; 
        dane_do_eksportu.outVidData.RGB  = RGB;
        dane_do_eksportu.outVidData.DIFFIM  = rgb2gray(RGB);
        dane_do_eksportu.outVidData.sum  = 12;
        dane_do_eksportu.outVidData.motion  = 1;
        exportObj.eksportujDane(dane_do_eksportu);
    
        delete(exportObj)       
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
        function obj = myExportDataSAD(parametryEksportu)
            % Konstruktor klasy - tutaj odbywa się inicjalizacja np.
            % otwarcie pliku do zapisu
            % > parametryEksportu    - struktura parametrów eksportu
            %   .nazwapliku          - nazwa pliku wy TXT
            disp('---=== myExportDataSAD ===---')
            disp(['Nazwa pliku wyjściowego TXT  =       ' parametryEksportu.nazwapliku])
            obj.fid     = fopen(parametryEksportu.nazwapliku, 'wt');
            fprintf(obj.fid,'%s,%s,%s\n','frnr','sad','motion');
        end
        
        function status = eksportujDane(obj, dane_do_eksportu)
            % Eksport kolejnej ramki danych
            % INPUTS:
            % > dane_do_eksportu       - dane do eksportu
            %   .iter                  - numer ramki
            %   .outVidData.sum        - wartość SAD
            %   .outVidData.motion     - rezultat detekcji ruchu
            % OUTPUTS:
            % > status                 - true/false
            try
                % try - jeśli wystąpi błąd zapisu do pliku, przejdź do
                % sekcji catch
                fprintf(obj.fid,'%d,%f,%d\n', dane_do_eksportu.iter, dane_do_eksportu.outVidData.sum, dane_do_eksportu.outVidData.motion);
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

