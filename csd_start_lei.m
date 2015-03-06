function csd_start_lei(reply)
% CSD_START_LEI show the menu of different CSD versions
% This function give an option to switch the CSD between different
% versions.
% 
% For more information, see <a href="matlab: 
% web('http://www.mathworks.com')">the MathWorks Web site</a>.
% 
% See also csd_start

% suchen nach CSD Verzeichnis
clc;
csdID = 0;
csdVersion = struct('ID',csdID,'Version','None','Path','None');
csd_root_path = 'D:\DASI\CSD';
fList = dir(csd_root_path);

% Verzeichnis in D:\DASI mit dem Name 'CSD' am Anfang wird als CSD
% Sandbox gerechnet
for i = 1:size(fList,1)
    if strmatch('CSD',fList(i).name)==1
        csdID = csdID+1;
        csdVersion(csdID).ID = csdID;
        csdVersion(csdID).Version = strrep(fList(i).name,'CSD_','');
        csdVersion(csdID).Path = fullfile(csd_root_path,fList(i).name);
    end
end

% ID = 0 bedeutet keine CSD Sandbox gefunden
if csdVersion(1).ID == 0
    disp(['No CSD version been founded! Are you sure your CSD in ',csd_root_path,' ?']);
    return;
else
    nCSD = csdVersion(end).ID;
    switch reply
        case {'R','r'}
            msg_start = ['There are ',num2str(nCSD),' avaiable CSD versions.'];
        case {'Y','y'}
            msg_start = ['There are ',num2str(nCSD),' avaiable CSD versions.'];
    end
    Disp_Rahmen(msg_start)
    disp(msg_start)
    Disp_Rahmen(msg_start)
    Disp_Menu()
    vCSD_input = input('Please choose which CSD Version u want to use: ','s');
    vCSD = str2num(vCSD_input);
    clc    
    Disp_Rahmen(msg_start)
    disp(msg_start)
    Disp_Rahmen(msg_start)
    Disp_Menu(vCSD);
    pause(1)
end

if vCSD ~= 0
    cd(csdVersion(vCSD).Path);
    csd_startup
else
    disp('No CSD Version been selected. No further actions been taken.')
    return
end

    function Disp_Rahmen(msg)
        for l=1:length(msg)
            fprintf('-')
        end
        disp(' ')
    end

    function Disp_Menu(n)
        if nargin==0
            for j = 1:nCSD
                disp(['[',num2str(csdVersion(j).ID),'] ',csdVersion(j).Version])
            end
            fprintf('\n%s\n','[0] None')
        else
            for k = 1:nCSD
                if k == n
                    msg_option = ['[',num2str(csdVersion(k).ID),'] ',csdVersion(k).Version];
                    disp(' ')
                    disp(msg_option)
                    disp(' ')
                else
                    disp(['     [',num2str(csdVersion(k).ID),'] ',csdVersion(k).Version])
                end
            end
            fprintf('\n%s\n','     [0] None')
        end
    end
end

