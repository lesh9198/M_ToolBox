% =====================================================================
%  CSD_Auto_Start Matlab startup M-file
%  + Author: lesh9198
%  + Ziel: Vorhandene CSD-Version erkennen u. bitte eine Möglichkeit eine
%  davon zu wählen order ohne CSD das Matlab zu starten.
%  + Hinweise: Alle CSD Sandbox soll in Verzeichnis "D:\DASI\" hinlegen,
%  welche muss mit "CSD_<VersionsNr.>" (z.B. CSD_1.23.1.8) auf Kopf benenen.
% =====================================================================

reply = input('start CSD or restart right now? Y/R/N [Y]: ', 's');
if isempty(reply)
    reply = 'Y';
end
if (reply == 'N' || reply == 'n')
    disp('No CSD is been Called! Matlab will be started!')
    pause(0.5);
    clc;
    return;
else
    if (reply == 'R' || reply == 'r')
        try
            csd_close;
            clc;
            disp('CSD is restarted!!!')
            pause(1)
            csd_start_lei(reply);
        catch ME
            clc;
            disp('No CSD is currently opened!!!')
            pause(1)
            csd_start_lei(reply);
        end
    else
        csd_start_lei(reply);
    end
end