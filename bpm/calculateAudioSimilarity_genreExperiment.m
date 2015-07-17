%function [] = calculateAudioSimilarity_genreExperiment()

%% n小節ごとの頭1秒のみを取り出し、相関量を計量するプログラム %%%%%%%%%%
%%%% functions %%%%
%%% [y, result, bpm] = audioToMatrix(fname, dpath, beats) %%%
%%% similarity{} = calculateCosineSimilarity(yourMusic, sampleMusic) %%%

%% 真似したい音楽を取得・変換・プロット
%[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference ');
dpath_yourMusic = uigetdir;
dpath_yourMusic = [dpath_yourMusic '/'];
D_yourMusic = dir([dpath_yourMusic '*.au']);
fname_yourMusic = cell(1, length(D_yourMusic));
fname_yourMusic_legend = []; %凡例用配列を作成
tf_idf_cell = [];

% fname_yourMusic_legend_index = 0; %凡例用配列インデックスを作成
% [y_yourMusic, yourMusic, bpm_yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic, 16);

dpath_sampleMusic  =  uigetdir;

index = 1;
for i = 1 : length(D_yourMusic)
    %サンプル側マトリクスの作成
    [~,name_yourMusic,ext_yourMusic] = fileparts(D_yourMusic(i).name); %パス、ファイル名、拡張子の取得
    fname_yourMusic{i} = strcat(name_yourMusic, ext_yourMusic); %ファイル名と拡張子を結合
    %マトリクス取得
    [~, yourMusic, ~] = audioToMatrix(fname_yourMusic{i}, dpath_yourMusic, 4);
    
    [similarity_tmp, tf_idf_cell_tmp] = calculateSimilarityAndTfInSampleMusicDirectory(yourMusic, dpath_sampleMusic);
    tf_idf_cell = vertcat(tf_idf_cell, tf_idf_cell_tmp);
end

%% idf計算
for j = 1 : length(D_yourMusic) - 1
    for k = 1 : length(similarity_tmp)
        if tf_idf_cell{j * length(similarity_tmp) + k, 2} > 0
            tf_idf_cell{k, 3} = tf_idf_cell{k, 3} + 1;
        end
    end
end

for l = 1 : length(similarity_tmp)
    tf_idf_cell{l, 3} = log(length(D_yourMusic) / tf_idf_cell{l, 3}) + 1;
    if isinf(tf_idf_cell{l, 3}) == 1
        tf_idf_cell{l, 3} = 1;
    end
end

for m = 1 : length(D_yourMusic) - 1
    for n = 1 : length(similarity_tmp)
        tf_idf_cell{m * length(similarity_tmp) + n, 3} = tf_idf_cell{n, 3};
    end
end

for x = 1 : length(similarity_tmp) * length(D_yourMusic)
    tf_idf_cell{x, 4} = (tf_idf_cell{x, 2} / 29) * tf_idf_cell{x, 3};
end

% figure;
% subplot(2,1,1);
% plot(y_yourMusic(:, 1));
% title(fname_yourMusic);
% xlabel('Time (Seconds)');

%% サンプル音楽ディレクトリの選択・取得・変換・コサイン類似度計量・プロット
% dpath_sampleMusic  =  uigetdir;



%end