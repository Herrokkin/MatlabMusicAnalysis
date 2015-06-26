%function [] = calculateAudioSimilarity_mel()
%参考文献URL
%http://shower.human.waseda.ac.jp/~m-kouki/pukiwiki_public/73.html#v962bcc1

%圧縮する次元の数
melFilterNum = 12;

%真似したい音楽
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference ');
[yourMusic, y_yourMusic, Fs] = audioToMatrix(fname_yourMusic, dpath_yourMusic);
subplot(2,1,1);
plot(y_yourMusic(:, 1));
title(fname_yourMusic);
xlabel('Time (Seconds)');

%melFilterNum次元に圧縮したマトリクスの作成
yourMusic_mel = zeros(length(yourMusic(:,1)), melFilterNum);
wb = waitbar(0,'Loading Audio Data...'); %進行状況の表示
for i = 1 : length(yourMusic(:,1))
    yourMusic_mel(i,:) = melFilterbankAnalysis(Fs, yourMusic(i,:), melFilterNum);
    waitbar((i / length(yourMusic(:,1))) / 2) %進行状況の表示
end
close(wb) %進行状況の非表示

%サンプル音楽ディレクトリの選択
dpath_sampleMusic_tmp  =  uigetdir;
dpath_sampleMusic = [dpath_sampleMusic_tmp '/'];
D = dir([dpath_sampleMusic '*.wav']);
fname_sampleMusic = cell(1, length(D));
fname_sampleMusic_legend = []; %凡例用配列を作成
fname_sampleMusic_legend_index = 0; %凡例用配列インデックスを作成
similarity = cell(1, length(D));
wb = waitbar(1/2,'Calculating Similarities...'); %進行状況の表示

for k = 1 : length(D)
    %サンプル側マトリクスの作成
    [pathstr_sampleMusic,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); %パス、ファイル名、拡張子の取得
    fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); %ファイル名と拡張子を結合
    %周波数スペクトルを取得
    [matrix_sampleMusic, ~, Fs] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic);
    %melFilterNum次元に圧縮したマトリクスの作成
    matrix_sampleMusic_mel = zeros(length(matrix_sampleMusic(:,1)), melFilterNum);
    for j = 1 : length(matrix_sampleMusic(:,1))
        matrix_sampleMusic_mel(j,:) = melFilterbankAnalysis(Fs, matrix_sampleMusic(j,:), melFilterNum);
    end

    %コサイン類似度計算
    similarity{k} = calculateCosineSimilarity(yourMusic_mel, matrix_sampleMusic_mel);

    %類似度があまりにも低いものは除外
    subplot(2,1,2);
    if nanmedian(similarity{k}) >= 0.0
        fname_sampleMusic_legend_index = fname_sampleMusic_legend_index + 1; %凡例用配列インデックスを増加
        fname_sampleMusic_legend{fname_sampleMusic_legend_index} = fname_sampleMusic{k}; %凡例用配列に追加
        %プロット_ここから
        plot(similarity{k})
        xlim([0, length(yourMusic(:,1))]);
        ylim([0.0, 1.0]);
        hold all;
        %プロット_ここまで
    end

    waitbar(1/2 + (k / length(D)) / 2) %進行状況の表示
end

title(['Time series variation of similarities | ' fname_yourMusic]);
xlabel('Time (Seconds)');
ylabel('Similarity');
legend(fname_sampleMusic_legend);
grid minor;
hold off;
close(wb) %進行状況の非表示
%end