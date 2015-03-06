function [Inports, Outports,M_xls] = get_subsys_ports()

Inports = {};
Outports = {};
blk_name = get_param(find_system(gcb,'selected','on'),'name');
blks = find_system(gcb,'SearchDepth',1,'Type','block');
blk_type = get_param(blks,'BlockType');


for i = 1:length(blk_type)
    if(strcmp(blk_type{i},'Inport'))
        idx_in = strfind(blks{i},'/'); 
        Inports{end+1} = blks{i}(idx_in(end)+1:end);%#ok
    elseif(strcmp(blk_type{i},'Outport'))
        idx_out = strfind(blks{i},'/');
        Outports{end+1} = blks{i}(idx_out(end)+1:end);%#ok 
    end
end

M_xls = {'Input','Output'};
for j =1:length(Inports)
    M_xls{j+1,1}= ['''''' Inports{j} '''' char(9) char(9) char(9) '0;...'];
end

for k =1:length(Outports)
    M_xls{k+1,2}= Outports{k};
end
xls_name = [blk_name{1} '_Port_List'];
xlswrite(xls_name, M_xls);