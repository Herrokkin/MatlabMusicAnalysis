%function [] = calculateAudioSimilarity()

%% n小節ごとの頭1秒のみを取り出し、相関量を計量するプログラム %%%%%%%%%%
%%%% functions %%%%
%%% [y, result, bpm] = audioToMatrix(fname, dpath, beats) %%%
%%% similarity{} = calculateCosineSimilarity(yourMusic, sampleMusic) %%%

%% 真似したい音楽を取得・変換・プロット
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference ');
[y_yourMusic, yourMusic, bpm_yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic, 8);
figure;
subplot(2,1,1);
plot(y_yourMusic(:, 1));
title(fname_yourMusic);
xlabel('Time (Seconds)');

%% サンプル音楽ディレクトリの選択・取得・変換・コサイン類似度計量・プロット
dpath_sampleMusic  =  uigetdir;
dpath_sampleMusic = [dpath_sampleMusic '/'];
D = dir([dpath_sampleMusic '*.wav']);
fname_sampleMusic = cell(1, length(D));
fname_sampleMusic_legend = []; %凡例用配列を作成
fname_sampleMusic_legend_index = 0; %凡例用配列インデックスを作成
similarity = cell(1, length(D));
wb = waitbar(0,'Please wait...'); %進行状況の表示

for k = 1 : length(D)
    %サンプル側マトリクスの作成
    [~,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); %パス、ファイル名、拡張子の取得
    fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); %ファイル名と拡張子を結合
    %マトリクス取得
    [~, matrix_sampleMusic, ~] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic, 4);

    %コサイン類似度計算
    similarity{k} = calculateCosineSimilarity(yourMusic, matrix_sampleMusic);
    
    %プロット関連
    subplot(2,1,2);
    fname_sampleMusic_legend_index = fname_sampleMusic_legend_index + 1; %凡例用配列インデックスを増加
    fname_sampleMusic_legend{fname_sampleMusic_legend_index} = fname_sampleMusic{k}; %凡例用配列に追加
    %プロット_ここから
    plot(similarity{k}(1:length(similarity{k}) - 1), '-x')
    xlim([1.0, length(yourMusic(:,1)) + 1]);
    ylim([0.0, 1.0]);
    hold all;
    %プロット_ここまで

    waitbar(k / length(D)) %進行状況の表示
end

title(['Time series variation of similarities | ' fname_yourMusic]);
xlabel('Time (bars)');
ylabel('Similarity');
legend(fname_sampleMusic_legend);
grid minor;
hold off;
close(wb) %進行状況の非表示

%% ジャンル分け
%楽曲全体
fname_genre_all_mean = fname_sampleMusic_legend{1};
index_genre_all_mean = 1;
index_min_similarity_length = 1;
for loop_genre_all = 2: length(similarity)
    if mean(similarity{index_genre_all_mean}) <= mean(similarity{loop_genre_all}) %平均を使用
        fname_genre_all_mean = fname_sampleMusic_legend{loop_genre_all};
        index_genre_all_mean = loop_genre_all;
    end
    %各類似度の長さ最小値取得。tf値用。
    if length(similarity{index_min_similarity_length}) >= length(similarity{loop_genre_all})
        min_similarity_length = length(similarity{loop_genre_all});
    end
end

%時系列変化
%disp(min_similarity_length);
%fname_genre_part = fname_sampleMusic_legend{1};
fname_genre_part = [];
index_genre_part_x = 1;
index_genre_part_y = 1;
for loop_genre_part_x = 2: length(similarity)
    for loop_genre_part_y = 2: min_similarity_length
        if similarity{index_genre_part_x}(index_genre_part_y,1) <= similarity{loop_genre_part_x}(loop_genre_part_y,1)
            fname_genre_part{loop_genre_part_y} = fname_sampleMusic_legend{loop_genre_part_x};
        end
    end
end

%tf-idf計算
fname_genre_part(find(cellfun('isempty',fname_genre_part))) = []; %セルの[]部分を削除
tf_idf_cell = cell(length(fname_sampleMusic_legend), 3); %tf-idf格納用変数
fname_genre_all_tf = fname_sampleMusic_legend{1};
index_genre_all_tf = 1;
for tf_idf_cell_x = 1 : 3
    for tf_idf_cell_y = 1 : length(fname_sampleMusic_legend)
        tf_idf_cell{tf_idf_cell_y, 1} = fname_sampleMusic_legend{tf_idf_cell_y};
        tf_temp = strfind(fname_genre_part, fname_sampleMusic_legend{tf_idf_cell_y});
        tf_temp(find(cellfun('isempty',tf_temp))) = []; %セルの[]部分を削除
        tf_idf_cell{tf_idf_cell_y, 2} = length(tf_temp);
        if tf_idf_cell{index_genre_all_tf, 2} <= tf_idf_cell{tf_idf_cell_y, 2}
            fname_genre_all_tf = fname_sampleMusic_legend{tf_idf_cell_y};
            index_genre_all_tf = tf_idf_cell_y;
        end
        tf_idf_cell{tf_idf_cell_y, 3} = 0;
    end
end

disp(['Genre: ' fname_genre_all_mean ', Mean: ' num2str(mean(similarity{index_genre_all_mean}))]); %meanで出したジャンルを表示
disp(['Genre: ' fname_genre_all_tf ', TF: ' num2str(tf_idf_cell{index_genre_all_tf, 2}) '/' num2str(length(fname_sampleMusic_legend)) ' (' num2str(tf_idf_cell{index_genre_all_tf, 2} / length(fname_sampleMusic_legend) * 100) '%)']); %TFで出したジャンルを表示



%end