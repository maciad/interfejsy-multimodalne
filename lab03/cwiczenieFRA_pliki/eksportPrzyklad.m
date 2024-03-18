classdef eksportPrzyklad < handle
    % Przykład: klasa realizująca eksport danych
    %
    % WERSJA: 01.02.2023, autor: Jaromir Przybylo (przybylo@agh.edu.pl), MATLAB R2022b
    %
    % Przykład użycia:
    %{
        parametryExportu = [];
        parametryExportu.nazwapliku = 'test.txt';
        
        exportObj = eksportPrzyklad(parametryExportu);
        properties(exportObj)
        methods(exportObj)
    
        dane_do_eksportu = [];
        dane_do_eksportu.iter   = 1;
        dane_do_eksportu.result = rand(1); 
        status = exportObj.eksportujDane(dane_do_eksportu)
    
        dane_do_eksportu.iter = 2;  
        dane_do_eksportu.result = rand(1); 
        status = exportObj.eksportujDane(dane_do_eksportu)
    
        clear exportObj
    
        open test.txt
    %}

    % Sekcja ta zawiera własności danej klasy.
    % Może być wiele takich sekcji z różnymi opcjami dostępu 
    %   private – widoczne tylko z wnętrza klasy, 
    %   public – widoczne na zewnątrz klasy. 
    % Jest to miejsce gdzie można umieszczać np. wewnętrzne zmienne 
    % obiektu lub zapamiętywać parametry używane przez różne metody klasy.
    properties
        fid                      % uchwyt do pliku txt
    end
    
    % Sekcja methods zawiera różne metody klasy. Każda metoda ma postać
    % funkcji.
    % - w tym przykładzie są 3 metody: konstruktor, eksportujDane, delete
    methods
        %----------------------------------------------------------------
        function obj = eksportPrzyklad(params)
            %  Konstruktor klasy (nazwa konstruktora musi być taka jak nazwa klasy!)
            %  - w tym przykładzie konstruktor przyjmuje arg we "params"
            %    będący strukturą zawierającą nazwę pliku wyjściowego
            %    "params.nazwapliku"
            %  - zadaniem konstruktora jest odpowiednia inicjalizacja: 
            %    - otwieramy do zapisu plik tekstowy
            %    - zapamiętujemy we własnościach klasy (properties) uchwyt
            %      do otwartego pliku
            %
            
            % Ważne - aby poprawnie odwoływać się do własności danej klasy 
            %         stosuje się nazwę obj (będącą argumentem metod). 
            disp('Klasa eksportPrzyklad - konstruktor')
            obj.fid     = fopen(params.nazwapliku, 'wt'); 
            fprintf(obj.fid,'NrRamki, Rezultat\n');
        end
        
        %----------------------------------------------------------------
        function status = eksportujDane(obj, dane_do_eksportu)
            % Metoda przyjmuje 2 argumenty we:
            % - obj : zawsze występuje - pozwala na dostęp do danych tej klasy
            % - dane_do_eksportu: struktura zawierająca różne dane które
            %    chcemy zapisywać do pliku TXT
            %    np.   dane_do_eksportu.iter  - numer ramki
            % 
            % Metoda zwraca jeden arg wyjściowy - status realizacji
            % operacji
            
            % disp('Klasa eksportPrzyklad - metoda eksportujDane')
            
            % Stosujemy tutaj również instrykcję "try...catch" pozwalającą
            % na przechwycenie ew błędów zapisu do pliku            
            try
                % try - jeśli wystąpi błąd zapisu do pliku, przejdź do
                % sekcji catch
                fprintf(obj.fid,'%d, %f\n', dane_do_eksportu.iter, dane_do_eksportu.result);
                status  = true;                
            catch ME
                status  = false; 
                disp([' > błąd przy zapisie do pliku TXT : ' ME.identifier])
                %rethrow(ME)                      
            end                        
        end
        
        %----------------------------------------------------------------
        function delete(obj)
            % Deallokacja zasobów
            % - w większości przypadków w MATLABie nie jest wymagana
            %   ponieważ MATLAB jest środowiskiem posiadających automatyczne
            %   zarządzanie pamięcią i danymi i potrafi sam zwalniać
            %   niewykorzystywane zasoby i pamięć.
            % - w tym przykładzie musimy jednak zadbać o zamknięcie
            %   wcześniej otwartego pliku tekstowego 
            disp('Klasa eksportPrzyklad - metoda delete')
            if ~isempty(obj.fid)
                fclose(obj.fid);
            end
        end
    end
end

