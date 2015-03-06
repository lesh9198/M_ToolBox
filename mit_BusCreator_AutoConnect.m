function mit_BusCreator_AutoConnect()
%--------------------------------------------------------------------------
% MIT_BUSCREATOR_AUTOCONNECT: add Bus Creator automatically in the Block
% this Function will simplified the operation of connecting more signal to
% a "Bus Creator".
%
%  *** How to use: ***
%       1. select you source blocks.
%       2. this function start
%       3. a Bus Creator will create and connected with more blocks
%       4. adjusted the position of all blocks


% get the selected blocks, sorted the name depends the position

bus_creator = find_system(gcs,'SearchDepth',1,'Selected','on','BlockType','BusCreator');
bus_creator_name = get_param(bus_creator,'Name');
lines = find_system(gcs,'LookUnderMasks','all','FindAll','on','Type','line','Selected','on');
blocks = find_system(gcs,'SearchDepth',1,'Selected','on');
for i = length(blocks):-1:1
    if strcmp('BusCreator',get_param(blocks{i},'BlockType'))
        blocks(i)=[];
    end
end

% sorting the blocks
p_t = zeros(1,length(blocks));
p_b = zeros(1,length(blocks));
for i = 1:length(blocks)
    p = get_param(blocks(i),'Position');
    p_t(1,i) = p{1}(2);
    p_b(1,i) = p{1}(4);
end
[~,Ind] = sort(p_t);
block_list = cell(size(blocks));
for i = 1:length(blocks)
    block_list(i) = blocks(Ind(i));
end

% blocks exacly position
p = get_param(block_list{1},'Position');
block_l = p(4)-p(2);
block_inteval = 30;
for i = 2:length(block_list)
    set_param(block_list{i},'Position',[p(1) p(2)+(block_l+block_inteval)*(i-1) p(3) p(4)+(block_l+block_inteval)*(i-1)])
end

% delete lines
for i= 1:length(lines)
    delete_line(lines(i))
end

% regulate bus creator
p_block_first = get_param(block_list{1},'Position');
p_block_end = get_param(block_list{end},'Position');
p_bus_creator = get_param(bus_creator{1},'Position');
p_bus_creator(2) = p_block_first(2);
p_bus_creator(4) = p_block_end(4);
set_param(bus_creator{1},'Position',p_bus_creator);
set_param(bus_creator{1},'Inputs',num2str(length(block_list)));

% block auto connected
block_names = cell(length(block_list),1);
for i = 1:length(block_list)
    block_names(i) = get_param(block_list(i),'Name');
end

for i = 1:length(block_list)
    inport = strcat(block_names(i),'/1');
    outport = strcat(bus_creator_name, '/', num2str(i));
    add_line(gcs,inport{1},outport{1})
end
mit_logger(1,'Connection is done');
end