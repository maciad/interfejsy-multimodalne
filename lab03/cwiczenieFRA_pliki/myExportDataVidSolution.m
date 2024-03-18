classdef myExportDataVidSolution < handle
    % Klasa realizując eksport danych - zapis kolejnych ramek do pliku video   
    % - zapisywany plik jest nieskompresowany 
    % - dodatkowo do pliku txt zapisywane są nr ramek oraz sygnatura
    %   czasowa (czas pomiędzy ramkami w [ms])
    % WERSJA: 01.02.2023, R2022b
    % Przykład użycia: 
    %{
        RGB                          = imread('ngc6543a.jpg');
        parametryEksportu            = [];
        parametryEksportu.nazwapliku = 'myexport.avi';
        exportObj                    = myExportDataVidSolution(parametryEksportu);
        dane_do_eksportu             = [];
        dane_do_eksportu.iter        = 1; 
        dane_do_eksportu.outVidData  = RGB;
        exportObj.eksportujDane(dane_do_eksportu);
    
        delete(exportObj)       
    
        % sprawdzenie realnej szybkości akwizycji ramek
        T   = readtable('out.txt');
        dt  = diff(T.timestamp); % różnica pomiędzy poszczególnymi czasami kolejnych ramek
        plot(dt)
        mdt = median(dt)         % mediana różnic
        fps = 1000/mdt           % rzeczywiste FPS
    %}
    %
    
    % Własności (dane, stan) dostępne do odczytu
    properties  (SetAccess = public)
        test                % pomocnicza zmienna  
        vidObj              % uchwyt do pliku avi
    end
    
    % Własności prywatne
    properties  (Access = private)
        fid                 % uchwyt do pliku txt    
        starttime           % czas początku akwizycji
    end    
    
    % Metody klasy
    methods
        function obj = myExportDataVidSolution(parametryEksportu)
            % Konstruktor klasy - tutaj odbywa się inicjalizacja np.
            % otwarcie pliku do zapisu
            % > parametryEksportu    - struktura parametrów eksportu
            %   .nazwapliku          - bazowa nazwa tworzonych plików (AVI i TXT)
            obj.test        = 0;

            [filepath,name,ext] = fileparts(parametryEksportu.nazwapliku);
            %name1               = fullfile(filepath,[name '.avi']);
            %name2               = fullfile(filepath,[name '.txt']);
            name1               = fullfile(filepath,strcat(name,'.avi'));
            name2               = fullfile(filepath,strcat(name,'.txt'));            
            disp('---=== myExportDataVid ===---')
            disp(['Nazwa pliku wyjściowego AVI  =       ' name1])
            disp(['Nazwa pliku wyjściowego TXT  =       ' name2])
            
            dt              = datetime;
            dt.Format       = 'uuuu,MM,dd,HH,mm,ss,MS';
            obj.starttime   = dt; % aktualna data i czas 
                                                 
            % -------------------------------------------------------
            % UZUPEŁNIJ_1 - tworzenie obiektu VideoWriter
            %               uwaga - oprócz utworzenia obiektu i
            %               odpowiedniego przypisania go do "obj.fid"
            %               należy otworzyć plik do zapisu (patrz
            %               dokumentacja do VideoWriter)
            try
                obj.fid         = fopen(name2, 'wt');
                fprintf(obj.fid,'%s, %s\n', 'iter', 'timestamp');

                obj.vidObj      = VideoWriter(name1, 'Uncompressed AVI');%SOLUTION
                open(obj.vidObj);  obj.test = 1;                         %SOLUTION
            catch ME                
                warning([' > błąd przy tworzeniu pliku AVI lub TXT: ' ME.identifier])
                rethrow(ME)                      
            end 
            % -------------------------------------------------------
        end
        
        function status = eksportujDane(obj, dane_do_eksportu)
            % Eksport kolejnej ramki danych
            % INPUTS:
            % > dane_do_eksportu       - dane do eksportu
            %   .iter                  - numer ramki
            %   .outVidData            - ramka RGB 
            % OUTPUTS:
            % > status                 - true/false
            try
                % try - jeśli wystąpi błąd zapisu do pliku, przejdź do
                % sekcji catch    
                dt              = datetime;
                timestamp1      = dt-obj.starttime;            
                timestampMS     = milliseconds(timestamp1);
                fprintf(obj.fid,'%d, %f\n', dane_do_eksportu.iter, timestampMS);
                % -------------------------------------------------------
                % UZUPEŁNIJ_2 - zapis ramki do pliku video
                writeVideo(obj.vidObj, dane_do_eksportu.outVidData);  obj.test = 2; %SOLUTION
                % -------------------------------------------------------
                status  = true;                
            catch ME
                status  = false; 
                warning([' > błąd przy zapisie do pliku AVI lub TXT : ' ME.identifier])
                rethrow(ME)                      
            end            
        end
        
        function delete(obj)
            % Usuwanie obiektów, zamykanie plików...
            fclose(obj.fid);
            % -------------------------------------------------------
            % UZUPEŁNIJ_3 - zamykanie obiektu VideoWriter oraz pliku TXT            
            close(obj.vidObj);  obj.test = 3; % SOLUTION
            % -------------------------------------------------------
        end
    end
end

