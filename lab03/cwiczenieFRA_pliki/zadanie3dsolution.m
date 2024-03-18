% Rozwiązanie zadania 2d

T = readtable(strrep(parametryEksportu.nazwapliku,'.avi','.txt'),"Delimiter",",");

ts = T.timestamp;   % wybór z tabeli T kolumny zwierającej timestamp
dts = diff(ts);        % wyznaczenie różnicy czasu między ramkami
FPS = median(dts);     % wyznaczenie FPS (użycie f. median na wektorze różnic czasu)

plot(dts)              % wyświetlenie różnic czasu pomiędzy ramkami
grid on
xlabel('nr ramki')
ylabel('różnica czasu [ms]')
title(['FPS = ' num2str(FPS)])