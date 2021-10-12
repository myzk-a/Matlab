%% 初期化
clear;
clc;

%% 対象のシステムを設定
model_name = "sample.slx";
target_system = "sample/Subsystem1";

%% モデル読み込み
open_system(model_name);

%% サブシステムの接続元のサブシステムを取得
%   string配列の1番目の接続元のサブシステムを2番目以降に格納
%   string配列の要素が一つのときは、接続元のサブシステムがないことを表す
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

%% blockの接続元のサブシステムのリストを返す
function subsystem_list = get_source_subsystem_list(block, input_list)
    block_type = get_param(block, 'BlockType');
    %ブロックタイプを取得し、Subsystemの場合はsubsystem_listにサブシステム名を追加し、returnする
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
    %ブロックタイプがConstant、Inport、UnitDelay、Delayの時は、input_listをreturnする
    elseif strcmp(block_type, "Constant")  ||...           
           strcmp(block_type, "Inport")    ||... 
           strcmp(block_type, "UnitDelay") ||... 
           strcmp(block_type, "Delay")
        subsystem_list = input_list;
        return
    end
    
    %ブロックタイプがSubsysytem、Constant、Inport、UnitDelay以外の時は、blockの接続元のブロックを取得し、再帰的に処理
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
