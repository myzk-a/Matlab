%% ������
clear;
clc;

%% �Ώۂ̃V�X�e����ݒ�
model_name = "sample.slx";
target_system = "sample/Subsystem1";

%% ���f���ǂݍ���
open_system(model_name);

%% �T�u�V�X�e���̐ڑ����̃T�u�V�X�e�����擾
%   string�z���1�Ԗڂ̐ڑ����̃T�u�V�X�e����2�Ԗڈȍ~�Ɋi�[
%   string�z��̗v�f����̂Ƃ��́A�ڑ����̃T�u�V�X�e�����Ȃ����Ƃ�\��
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
    for j = 1:length(ph.Inport)
        line = get_param(ph.Inport(j), 'Line');
        if line == -1
            continue
        end
        src = get_param(line, 'SrcBlockHandle');
        source_subsystemlist = get_source_subsystem_list(src, input);
        input = source_subsystemlist;
    end
    subsystem_relationship_list{index} = input;
    index = index + 1;
end

%% block�̐ڑ����̃T�u�V�X�e���̃��X�g��Ԃ�
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
    %�u���b�N�^�C�v��Constant�AInport�AUnitDelay�ADelay�̎��́Ainput_list��return����
    elseif strcmp(block_type, "Constant")  ||...           
           strcmp(block_type, "Inport")    ||... 
           strcmp(block_type, "UnitDelay") ||... 
           strcmp(block_type, "Delay")
        subsystem_list = input_list;
        return
    end
    
    %�u���b�N�^�C�v��Subsysytem�AConstant�AInport�AUnitDelay�ȊO�̎��́Ablock�̐ڑ����̃u���b�N���擾���A�ċA�I�ɏ���
    ph = get_param(block, 'PortHandles');
    for i = 1:length(ph.Inport)
        line = get_param(ph.Inport(i), 'Line');
        if line == -1
            continue;
        end
        src = get_param(line, 'SrcBlockHandle');
        res = get_source_subsystem_list(src, input_list);
        input_list = res;
    end
    subsystem_list = input_list;
end
