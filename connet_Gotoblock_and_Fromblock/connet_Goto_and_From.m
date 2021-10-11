%% 対象のシステムを設定
clear;
clc;

model_name = "sample.slx";
target_system = "sample/Subsystem/";

%% モデル読み込み
open_system(model_name);

%% GotoブロックとFromブロックを自動結線
from_block_list = find_system(target_system, 'SearchDepth', '1', 'BlockType', 'From'); %Fromブロック一覧を取得   
goto_block_list = find_system(target_system, 'SearchDepth', '1', 'BlockType', 'Goto'); %Gotoブロック一覧を取得

for i = 1:length(from_block_list)
    ph_from_block = get_param(from_block_list{i}, 'PortHandles');
    line = get_param(ph_from_block.Outport, 'Line');                          %Fromブロックの出力信号線(line)を取得
    if line == -1
        continue;
    end
    dst = get_param(line, 'DstPortHandle');                                   %lineの接続先を取得
    
    Tag_from_block = get_param(from_block_list{i}, 'GotoTag');
    for j = 1:length(goto_block_list)
        Tag_goto_block = get_param(goto_block_list{j}, 'GotoTag');
        
        if strcmp(Tag_from_block, Tag_goto_block)                             %FromブロックとGotoブロックのGotoタグを比較
            delete_line(line);                                                %Fromブロックに対応するGotoブロックが存在する時、Fromブロックの出力信号線を削除
            ph_go_to_block = get_param(goto_block_list{j}, 'PortHandles');
            line = get_param(ph_go_to_block.Inport, 'Line');                  %Gotoブロックの入力信号線(line)を取得
            src = get_param(line, 'SrcPortHandle');                           %lineの出力元を取得
            for k = 1:length(dst)
                add_line(target_system, src, dst(k), 'autorouting', 'smart'); %結線 
            end
            break;
        end
    end
end

%% GotoブロックとFromブロックを削除(※対応するFromブロックがないGotoブロックは残す)
deleted_goto_block = zeros(1, length(goto_block_list));                   %削除済みのGotoブロックのリスト. goto_block_listのインデックスを格納
for i = 1:length(from_block_list)
    
    Tag_from_block = get_param(from_block_list{i}, 'GotoTag');
    for j = 1:length(goto_block_list) 
        if deleted_goto_block(j) == 1                                     %goto_block_listでj番目のGotoブロックが削除されているときは以降の処理をスキップ
            continue;
        end
        Tag_goto_block = get_param(goto_block_list{j}, 'GotoTag');
        
        if strcmp(Tag_from_block, Tag_goto_block)                          %FromブロックとGotoブロックのGotoタグを比較
            ph_go_to_block = get_param(goto_block_list{j}, 'PortHandles');
            line = get_param(ph_go_to_block.Inport, 'Line');               %Gotoブロックの入力信号線(line)を取得
            delete_line(line);
            delete_block(goto_block_list{j});
            deleted_goto_block(j) = 1;                                     %削除済みのGotoブロックをdeleted_goto_blockに追加
            break;
        end
    end
    
    delete_block(from_block_list{i});
end