%function [] = calculateAudioSimilarity_genreExperiment()

%% n小節ごとの頭1秒のみを取り出し、相関量を計量するプログラム %%%%%%%%%%
%%%% functions %%%%
%%% [y, result, bpm] = audioToMatrix(fname, dpath, beats) %%%
%%% similarity{} = calculateCosineSimilarity(yourMusic, sampleMusic) %%%

%% 真似したい音楽を取得・変換・プロット
%[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference ');
dpath_yourMusic = uigetdir;
dpath_yourMusic = [dpath_yourMusic '/'];
D_yourMusic = dir([dpath_yourMusic '.au']);
fname_yourMusic = cell(1, length(D_yourMusic));
fname_yourMusic_legend = []; %凡例用配列を作成
% fname_yourMusic_legend_index = 0; %凡例用配列インデックスを作成
% [y_yourMusic, yourMusic, bpm_yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic, 16);

dpath_sampleMusic  =  uigetdir;

index = 1;
for k = 1 : length(D_yourMusic)
    %サンプル側マトリクスの作成
    [~,name_yourMusic,ext_yourMusic] = fileparts(D_yourMusic(k).name); %パス、ファイル名、拡張子の取得
    fname_yourMusic{k} = strcat(name_yourMusic, ext_yourMusic); %ファイル名と拡張子を結合
    %マトリクス取得
    [~, yourMusic{k}, ~] = audioToMatrix(fname_yourMusic{k}, dpath_yourMusic, 16);
    
    [similarity_tmp{k}, tf_idf_cell_tmp{k}] = calculateSimilarityAndTfInSampleMusicDirectory(yourMusic{k}, dpath_sampleMusic);
end

% figure;
% subplot(2,1,1);
% plot(y_yourMusic(:, 1));
% title(fname_yourMusic);
% xlabel('Time (Seconds)');

%% サンプル音楽ディレクトリの選択・取得・変換・コサイン類似度計量・プロット
% dpath_sampleMusic  =  uigetdir;



%end