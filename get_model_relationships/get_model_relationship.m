%% ������
clear;
clc;

%% �Ώۂ̃V�X�e����ݒ�
model_name = "sample.slx";
target_system = "sample/Subsystem1";

%% ���f���ǂݍ���
open_system(model_name);

%% �T�u�V�X�e���̐ڑ���̃T�u�V�X�e�����擾
%   string�z���1�Ԗڂɐڑ����̃T�u�V�X�e�����A2�Ԗڈȍ~�ɐڑ���̃T�u�V�X�e���i�[
%   string�z��̗v�f����̂Ƃ��́A�ڑ���̃T�u�V�X�e�����Ȃ����Ƃ�\��
subsystem_list = find_system(target_system, 'SearchDepth', '1', 'BlockType', 'SubSystem');

subsystem_relationship_list = cell(1, length(subsystem_list)-1);
index = 1;
for i = 1:length(subsystem_list)
    if strcmp(subsystem_list(i), target_system)
        continue;
    end
    subsystem_name = string(get_param(subsystem_list{i}, 'Name'));
    input = [subsystem_name];
    ph = get_param(subsystem_list{i}, 'PortHandles');
    for j = 1:length(ph.Outport)
        line = get_param(ph.Outport(j), 'Line');
        if line == -1
            continue
        end
        dst = get_param(line, 'DstBlockHandle');
        for k = 1:length(dst)
            dst_subsystemlist = get_source_subsystem_list(dst(k), input);
            input = dst_subsystemlist;    
        end
    end
    subsystem_relationship_list{index} = input;
    index = index + 1;
end

%% ���f���̈ˑ��֌W����������
A = zeros(length(subsystem_relationship_list), length(subsystem_relationship_list));

names = cell(1, length(subsystem_relationship_list));
for i = 1:length(subsystem_relationship_list)
    names{i} = char(subsystem_relationship_list{i}(1));
end

for i = 1:length(subsystem_relationship_list)
    list = subsystem_relationship_list{i};
    if length(list) == 1
        continue;
    end
    for j = 1:length(names)
        if string(names{j}) == list(1)
            row = j;
            break;
        end
    end
    for j = 2:length(list)
        for k = 1:length(names)
            if string(names{k}) == list(j)
                A(row, k) = 1;
                break;
            end
        end
    end
end

G = digraph(A,names);
plot(G)

%% �ڑ���̃T�u�V�X�e�������擾����
function subsystem_list = get_source_subsystem_list(block, input_list)
    block_type = get_param(block, 'BlockType');
    %�u���b�N�^�C�v���擾���ASubsystem�̏ꍇ��subsystem_list�ɃT�u�V�X�e������ǉ����Areturn����
    if strcmp(block_type, "SubSystem")
        subsystem_name = string(get_param(block, 'Name'));
        f = true;
        for i = 1:length(input_list)
            if strcmp(subsystem_name, input_list(i))
                f = false;
                break;
            end
        end
        if f == true
            subsystem_list = [input_list, subsystem_name];
        else
            subsystem_list = input_list;
        end
        return
    %�u���b�N�^�C�v��Outport�AUnitDelay�ADelay�AGoto�̎��́Ainput_list��return����
    elseif strcmp(block_type, "Outport")   ||...
           strcmp(block_type, "UnitDelay") ||...
           strcmp(block_type, "Delay")     ||...
           strcmp(block_type, "Goto")
        subsystem_list = input_list;
        return
    end
    
    %block�̐ڑ���̃u���b�N���擾���A�ċA�I�ɏ���
    ph = get_param(block, 'PortHandles');
    for i = 1:length(ph.Outport)
        line = get_param(ph.Outport(i), 'Line');
        if line == -1
            continue;
        end
        dst = get_param(line, 'DstBlockHandle');
        for j = 1:length(dst)
            res = get_source_subsystem_list(dst(j), input_list);
            input_list = res;
        end
    end
    subsystem_list = input_list;
end
