%% �Ώۂ̃V�X�e����ݒ�
clear;
clc;

model_name = "sample.slx";
target_system = "sample/Subsystem/";

%% ���f���ǂݍ���
open_system(model_name);

%% Goto�u���b�N��From�u���b�N����������
from_block_list = find_system(target_system, 'SearchDepth', '1', 'BlockType', 'From'); %From�u���b�N�ꗗ���擾   
goto_block_list = find_system(target_system, 'SearchDepth', '1', 'BlockType', 'Goto'); %Goto�u���b�N�ꗗ���擾

for i = 1:length(from_block_list)
    ph_from_block = get_param(from_block_list{i}, 'PortHandles');
    line = get_param(ph_from_block.Outport, 'Line');                          %From�u���b�N�̏o�͐M����(line)���擾
    if line == -1
        continue;
    end
    dst = get_param(line, 'DstPortHandle');                                   %line�̐ڑ�����擾
    
    Tag_from_block = get_param(from_block_list{i}, 'GotoTag');
    for j = 1:length(goto_block_list)
        Tag_goto_block = get_param(goto_block_list{j}, 'GotoTag');
        
        if strcmp(Tag_from_block, Tag_goto_block)                             %From�u���b�N��Goto�u���b�N��Goto�^�O���r
            delete_line(line);                                                %From�u���b�N�ɑΉ�����Goto�u���b�N�����݂��鎞�AFrom�u���b�N�̏o�͐M�������폜
            ph_go_to_block = get_param(goto_block_list{j}, 'PortHandles');
            line = get_param(ph_go_to_block.Inport, 'Line');                  %Goto�u���b�N�̓��͐M����(line)���擾
            src = get_param(line, 'SrcPortHandle');                           %line�̏o�͌����擾
            for k = 1:length(dst)
                add_line(target_system, src, dst(k), 'autorouting', 'smart'); %���� 
            end
            break;
        end
    end
end

%% Goto�u���b�N��From�u���b�N���폜(���Ή�����From�u���b�N���Ȃ�Goto�u���b�N�͎c��)
deleted_goto_block = zeros(1, length(goto_block_list));                   %�폜�ς݂�Goto�u���b�N�̃��X�g. goto_block_list�̃C���f�b�N�X���i�[
for i = 1:length(from_block_list)
    
    Tag_from_block = get_param(from_block_list{i}, 'GotoTag');
    for j = 1:length(goto_block_list) 
        if deleted_goto_block(j) == 1                                     %goto_block_list��j�Ԗڂ�Goto�u���b�N���폜����Ă���Ƃ��͈ȍ~�̏������X�L�b�v
            continue;
        end
        Tag_goto_block = get_param(goto_block_list{j}, 'GotoTag');
        
        if strcmp(Tag_from_block, Tag_goto_block)                          %From�u���b�N��Goto�u���b�N��Goto�^�O���r
            ph_go_to_block = get_param(goto_block_list{j}, 'PortHandles');
            line = get_param(ph_go_to_block.Inport, 'Line');               %Goto�u���b�N�̓��͐M����(line)���擾
            delete_line(line);
            delete_block(goto_block_list{j});
            deleted_goto_block(j) = 1;                                     %�폜�ς݂�Goto�u���b�N��deleted_goto_block�ɒǉ�
            break;
        end
    end
    
    delete_block(from_block_list{i});
end