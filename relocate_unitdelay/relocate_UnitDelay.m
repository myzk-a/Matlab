%% 初期化
clear;
clc;

%% 対象を設定
model_name = "sample.slx";
target_system = "sample/Subsystem1";

%% モデル読み込み
open_system(model_name);

%% Inportブロックから直接つながっているUnitDelayを一階層上に再配置する
subsystem_list = find_system(target_system, 'SearchDepth', '1', 'BlockType', 'SubSystem', 'MaskType', '');
add_num_unitdelay = 0;
for i = 1:length(subsystem_list)
    if strcmp(subsystem_list(i), target_system)
        continue;
    end
    Inport_list = find_system(subsystem_list{i}, 'SearchDepth', '1', 'BlockType', 'Inport');
    
    for j = 1:length(Inport_list)
        ph_inport = get_param(Inport_list{j}, 'PortHandles');
        line = get_param(ph_inport.Outport, 'Line');
        dst = get_param(line, 'DstBlockHandle');
        
        for k = 1:length(dst)
            if(strcmp(get_param(dst(k), 'BlockType'), 'UnitDelay') || strcmp(get_param(dst(k), 'BlockType'), 'Delay'))
                Inport_num = get_param(Inport_list{j}, 'Port');
                ph_unitdelay = get_param(dst(k), 'PortHandles');
                line_unitdelay_out = get_param(ph_unitdelay.Outport, 'Line');
                ph_from_unitdelay = get_param(line_unitdelay_out, 'DstPortHandle');
                line = get_param(ph_unitdelay.Inport, 'Line');
                delete_line(line);
                delete_block(dst(k));
                delete_line(line_unitdelay_out);
                for l = 1:length(ph_from_unitdelay)
                    add_line(subsystem_list{i}, ph_inport.Outport, ph_from_unitdelay(l), 'autorouting', 'smart');    
                end
                
                unitdelay_block_name = target_system+'/unitdelay'+add_num_unitdelay;
                add_block('simulink/Discrete/Unit Delay', unitdelay_block_name);
                ph_subsystem = get_param(subsystem_list{i}, 'PortHandles');
                pos_inport = get_param(ph_subsystem.Inport(Inport_num-'0'), 'Position');
                size = 30;
                left = pos_inport(1)-50;
                upper = pos_inport(2)-size/2;
                right = left + size;
                lower = pos_inport(2) + size/2;
                set_param(unitdelay_block_name, 'Position',[left upper right lower]);
                line = get_param(ph_subsystem.Inport(Inport_num-'0'), 'Line');
                src_port = get_param(line, 'SrcPortHandle');
                delete_line(line);
                ph_addded_unit_delay = get_param(unitdelay_block_name, 'PortHandles');
                add_line(target_system, ph_addded_unit_delay.Outport, ph_subsystem.Inport(Inport_num-'0'), 'autorouting', 'smart');
                add_line(target_system, src_port, ph_addded_unit_delay.Inport, 'autorouting', 'smart');
                add_num_unitdelay = add_num_unitdelay + 1;
            end
        end
    end
end

