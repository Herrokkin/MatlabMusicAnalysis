%function [] = calculateAudioSimilarity()

%真似したい音楽
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference ');
[y_yourMusic, yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic);
figure;
subplot(2,1,1);
plot(y_yourMusic(:, 1));
title(fname_yourMusic);
xlabel('Time (Seconds)');

%サンプル音楽ディレクトリの選択
dpath_sampleMusic_tmp  =  uigetdir;
dpath_sampleMusic = [dpath_sampleMusic_tmp '/'];
D = dir([dpath_sampleMusic '*.wav']);
fname_sampleMusic = cell(1, length(D));
fname_sampleMusic_legend = []; %凡例用配列を作成
fname_sampleMusic_legend_index = 0; %凡例用配列インデックスを作成
similarity = cell(1, length(D));
wb = waitbar(0,'Please wait...'); %進行状況の表示

for k = 1 : length(D)
    %サンプル側マトリクスの作成
    [pathstr_sampleMusic,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); %パス、ファイル名、拡張子の取得
    fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); %ファイル名と拡張子を結合
    %マトリクス取得
    [~, matrix_sampleMusic] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic);

    %コサイン類似度計算
    similarity{k} = calculateCosineSimilarity(yourMusic, matrix_sampleMusic);
    
    %プロット関連
    subplot(2,1,2);
    fname_sampleMusic_legend_index = fname_sampleMusic_legend_index + 1; %凡例用配列インデックスを増加
    fname_sampleMusic_legend{fname_sampleMusic_legend_index} = fname_sampleMusic{k}; %凡例用配列に追加
    %プロット_ここから
    plot(similarity{k}(1:length(similarity{k}) - 1))
    xlim([0, length(yourMusic(:,1))]);
    ylim([0.0, 1.0]);
    hold all;
    %プロット_ここまで

    waitbar(k / length(D)) %進行状況の表示
end

title(['Time series variation of similarities | ' fname_yourMusic]);
xlabel('Time (Seconds)');
ylabel('Similarity');
legend(fname_sampleMusic_legend);
grid minor;
hold off;
close(wb) %進行状況の非表示

%ジャンル分け。出現回数でif回す。
fname_genre = fname_sampleMusic_legend{1};
for j = 1: length(similarity) - 1
    if max(similarity{j}) <= max(similarity{j+1})
        fname_genre = fname_sampleMusic_legend{j+1};
        index_genre = j+1;
    end
end

disp(fname_genre);
disp(max(similarity{index_genre}));

%end