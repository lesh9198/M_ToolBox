function mit_add_DSM_init

bdclose all;

%% Pfade und Namen
opt = prj_options();
pf = [opt.ProjectRoot 'model\Frames'];
if strcmpi(pf,pwd) == 0
    cd(pf)
    disp(['Path changed to ' pwd])
end 

xlc_mdl   = dir('xlc*.mdl');
if isempty(xlc_mdl.name)
    error('Kein xlc*-rahmen gefunden')
end

ModelName = xlc_mdl(1).name;
ModelName = ModelName(1:end-4);
open_system(ModelName);

Lrg1BlockModel = [ModelName, '/Lrg1/Subsystem/Lrg1'];

open_system('tllib');


%if strcmp(s, 'outputs') || strcmp(s, 'Outputs') || strcmp(s, '')

    OutputsLrg1 = getOutports(Lrg1BlockModel);

%    [INIT_Outputs, All_Outputs] = xlsread(['Initialwerte_Outputs_', ModelName(1:end-7), '.xls'], 'Outputs');
    read_cells = mit_io_utils('read_xls', ['Initialwerte_Outputs_', ModelName(1:end-7), '.xls'], 'Outputs');
    nMLv = 0; % number of occurences of Matlab basic workspace variables
    
    INIT_Outputs = cell(length(read_cells),2);
    for i=1:length(read_cells)
        INIT_Outputs(i,1) = read_cells{i}(1);   % get Name
        INIT_Outputs(i,2) = read_cells{i}(2);   % get Value
        if isempty(str2num(INIT_Outputs{i,2})) %#ok<ST2NM> % string2double liefert unterschiedliche Ergegnisse!
            nMLv = nMLv + 1;                    % a variable is provided as it is not a number
        end
    end
    
    if nMLv > 0 % any Matlab Workspace variable 
        disp('Sind folgende Parameter im Workspace aktuell?')
    end
            
    for i=1:length(OutputsLrg1)
        OutputsLrg1_i   = OutputsLrg1{i};
        while strcmp(OutputsLrg1_i(end), ' ');
            OutputsLrg1_i = OutputsLrg1_i(1:end-1);
        end;
        OutputLrg1      = [Lrg1BlockModel, '/', OutputsLrg1{i}];
        OutputLrg1_pos  = get_param(OutputLrg1, 'Position');
        OutputLrg1_data = get_param(OutputLrg1, 'data');
        DaStMeLrg1      = [OutputLrg1, '_DCM'];
        try
            delete_block(DaStMeLrg1);
        catch %#ok<CTCH>
            % block not yet existend, nothing todo
        end;
        add_block('tllib/Data Store Memory', DaStMeLrg1);
        DaStMeLrg1_pos  = get_param(DaStMeLrg1, 'Position');
        DaStMeLrg1_pos  = [OutputLrg1_pos(1)+150, (OutputLrg1_pos(2)+OutputLrg1_pos(4)+DaStMeLrg1_pos(2)-DaStMeLrg1_pos(4))/2, DaStMeLrg1_pos(3)-DaStMeLrg1_pos(1)+OutputLrg1_pos(1)+150, (OutputLrg1_pos(2)+OutputLrg1_pos(4)-DaStMeLrg1_pos(2)+DaStMeLrg1_pos(4))/2];
        set_param(DaStMeLrg1, 'Position', DaStMeLrg1_pos);
        set_param(DaStMeLrg1, 'Orientation','up')

        DaStMeLrg1_data = get_param(DaStMeLrg1, 'data');

        OutputLrg1_data_1 = min(findstr(OutputLrg1_data, '''output'''));
        OutputLrg1_data_2 = min(findstr(OutputLrg1_data(OutputLrg1_data_1:end), '}')) + OutputLrg1_data_1 - 1;

        DaStMeLrg1_data = [DaStMeLrg1_data(1), OutputLrg1_data(OutputLrg1_data_1:OutputLrg1_data_2+1), DaStMeLrg1_data(2:end)];

        DaStMeLrg1_data_1 = min(findstr(DaStMeLrg1_data, '''description'''));

        if ~isempty(DaStMeLrg1_data_1)
            DaStMeLrg1_data_1 = min(findstr(DaStMeLrg1_data(DaStMeLrg1_data_1:end), ',')) + DaStMeLrg1_data_1 - 1;
            DaStMeLrg1_data_2 = min(findstr(DaStMeLrg1_data, '''name'''));
            DaStMeLrg1_data_2 = max(findstr(DaStMeLrg1_data(1:DaStMeLrg1_data_2), ','));

            DaStMeLrg1_data = [DaStMeLrg1_data(1:DaStMeLrg1_data_1), '['''']', DaStMeLrg1_data(DaStMeLrg1_data_2:end)];
        end;

        DaStMeLrg1_data_1 = min(findstr(DaStMeLrg1_data, '$L'));

        DaStMeLrg1_data = [DaStMeLrg1_data(1:DaStMeLrg1_data_1-1), OutputsLrg1_i, DaStMeLrg1_data(DaStMeLrg1_data_1+2:end)];

        set_param(DaStMeLrg1, 'data', DaStMeLrg1_data);

        found_InitialValue = 0;
%         for j=1:length(All_Outputs)
        for j=1:length(INIT_Outputs)
%             if strcmp(OutputsLrg1_i, All_Outputs{j})
            if strcmp(OutputsLrg1_i, INIT_Outputs{j,1})
                found_InitialValue = 1;
                set_value_str = INIT_Outputs{j,2};
                if isempty(str2num(INIT_Outputs{j,2})) %#ok<ST2NM> % check if a variable is provided
                    %  check if a workspace variable is assigned
                    [~,l] = size(set_value_str);
                    if l > 0
                        try
                            set_value = evalin('base', set_value_str);
                            set_value = num2str(set_value);
                            disp(['   ', OutputsLrg1_i, ' auf den Matlab-Workspace Wert ', ...
                                  set_value_str, ': ', set_value])
                        catch exception
                            close_system('tllib');
                            error(exception.identifier,['Variable << ', set_value_str, ' >> nicht im Matlab-Workspace gefunden.', ...
                                  ' Sind die Parameter (neu) geladen?'])
                        end
                    end
                    set_value_str = set_value;
                end 
                set_param(DaStMeLrg1, 'InitialValue', set_value_str);
                set_param(DaStMeLrg1, 'BackgroundColor', 'lightBlue');
            end
        end;

        if ~found_InitialValue
            disp(['Kein Initialwert fuer ', OutputsLrg1_i, ' gefunden, mit 0 initialisiert.']);
            set_param(DaStMeLrg1, 'InitialValue', '0');
            set_param(DaStMeLrg1, 'ForegroundColor', 'red');
        end;

        set_param(DaStMeLrg1, 'DataStoreName', ['OUT_', num2xlscolumn(i)]);
    end;

%end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close_system('tllib');
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Weiter folgt die Bearbeitung von Init-Werten für Inputs, was obsolet ist
if strcmp(s, 'inputs') || strcmp(s, 'Inputs') || strcmp(s, '') %#ok<UNRCH>

    InputsLrg1 = getInports(Lrg1BlockModel);

    % xlswrite(PortsExcel, InputsLrg1, 'Inputs',  'A1');

    [INIT_Inputs, All_Inputs] = xlsread('INIT_InputsOutputs.xls', 'Inputs');

    for i=1:length(InputsLrg1)
        InputsLrg1_i   = InputsLrg1{i};
        while strcmp(InputsLrg1_i(end), ' ');
            InputsLrg1_i = InputsLrg1_i(1:end-1);
        end;
        InputLrg1      = [Lrg1BlockModel, '/', InputsLrg1{i}];
        InputLrg1_pos  = get_param(InputLrg1, 'Position');
        InputLrg1_data = get_param(InputLrg1, 'data');
        DaStMeLrg1      = [InputLrg1, '_DCM'];
        try %#ok<TRYNC>
            delete_block(DaStMeLrg1);
        end;
        add_block('tllib/Data Store Memory', DaStMeLrg1);
        DaStMeLrg1_pos  = get_param(DaStMeLrg1, 'Position');
        DaStMeLrg1_pos  = [InputLrg1_pos(1)-150, (InputLrg1_pos(2)+InputLrg1_pos(4)+DaStMeLrg1_pos(2)-DaStMeLrg1_pos(4))/2, DaStMeLrg1_pos(3)-DaStMeLrg1_pos(1)+InputLrg1_pos(1)-150, (InputLrg1_pos(2)+InputLrg1_pos(4)-DaStMeLrg1_pos(2)+DaStMeLrg1_pos(4))/2];
        set_param(DaStMeLrg1, 'Position', DaStMeLrg1_pos);

        DaStMeLrg1_data = get_param(DaStMeLrg1, 'data');

        InputLrg1_data_1 = min(findstr(InputLrg1_data, '''output'''));
        InputLrg1_data_2 = min(findstr(InputLrg1_data(InputLrg1_data_1:end), '}')) + InputLrg1_data_1 - 1;

        DaStMeLrg1_data = [DaStMeLrg1_data(1), InputLrg1_data(InputLrg1_data_1:InputLrg1_data_2+1), DaStMeLrg1_data(2:end)];

        DaStMeLrg1_data_1 = min(findstr(DaStMeLrg1_data, '''description'''));

        if ~isempty(DaStMeLrg1_data_1)
            DaStMeLrg1_data_1 = min(findstr(DaStMeLrg1_data(DaStMeLrg1_data_1:end), ',')) + DaStMeLrg1_data_1 - 1;
            DaStMeLrg1_data_2 = min(findstr(DaStMeLrg1_data, '''name'''));
            DaStMeLrg1_data_2 = max(findstr(DaStMeLrg1_data(1:DaStMeLrg1_data_2), ','));

            DaStMeLrg1_data = [DaStMeLrg1_data(1:DaStMeLrg1_data_1), '['''']', DaStMeLrg1_data(DaStMeLrg1_data_2:end)];
        end;

        DaStMeLrg1_data_1 = min(findstr(DaStMeLrg1_data, '$L'));

        DaStMeLrg1_data = [DaStMeLrg1_data(1:DaStMeLrg1_data_1-1), InputsLrg1_i, DaStMeLrg1_data(DaStMeLrg1_data_1+2:end)];

        set_param(DaStMeLrg1, 'data', DaStMeLrg1_data);

        found_InitialValue = 0;
        for j=1:length(All_Inputs)
            if strcmp(InputsLrg1_i, All_Inputs{j})
                found_InitialValue = 1;
                set_param(DaStMeLrg1, 'InitialValue', num2str(INIT_Inputs(j)));
                set_param(DaStMeLrg1, 'BackgroundColor', 'orange');
            end;
        end;

        if ~found_InitialValue
            disp(['Kein Initialwert fuer ', InputsLrg1_i, ' gefunden, mit 0 initialisiert.']);
            set_param(DaStMeLrg1, 'InitialValue', '0');
            set_param(DaStMeLrg1, 'ForegroundColor', 'red');
        end;

        set_param(DaStMeLrg1, 'DataStoreName', ['IN_', num2xlscolumn(i)]);
    end;

end;

% close_system('tllib');

end

function c_in = getInports(s) %#ok<DEFNU>

sBlocks = get_param(s, 'Blocks');
for i=1:length(sBlocks)
    if strcmp(get_param([s, '/', sBlocks{i}], 'BlockType'), 'Inport')
        c_in{str2num(get_param([s, '/', sBlocks{i}], 'Port')), 1} = sBlocks{i}; %#ok<ST2NM,AGROW>
    end;
end;

end

function c_out = getOutports(s)

sBlocks = get_param(s, 'Blocks');
for i=1:length(sBlocks)
    if strcmp(get_param([s, '/', sBlocks{i}], 'BlockType'), 'Outport')
        c_out{str2num(get_param([s, '/', sBlocks{i}], 'Port')), 1} = sBlocks{i}; %#ok<ST2NM,AGROW>
    end;
end;

end

function s = num2xlscolumn(n)

m = n-1;

while m(1)>25
    m = [floor(m(1)/26)-1, mod(m, 26)];
end;

m = m+65;

s = char(m);

end




