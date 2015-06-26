%Disclosure - You & Me読み込み
audioToMatrix_notFunction
melFilterNum = 20;
merge = (y(:,1) + y(:,2)) / 2;
[result_mel(1,:), bandpassMedianFreq] = melFilterbankAnalysis_bandpassMedian(Fs, result(1,:), melFilterNum);

subplot(4,2,1);
xlim([0,N]);
plot(merge);
title('Waveform | Music for analysis');
xlabel('Time (Seconds)');
ylabel('Amplitude');

subplot(4,2,3);
xlim([20,20000]);
semilogx(result(1,:));
title('Spectrum | Music for analysis');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

subplot(4,2,5);
xlim([20,20000]);
semilogx(bandpassMedianFreq, result_mel, '.');
title('Dimension Reduction | Music for analysis');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

clear

%アーメン読み込み
audioToMatrix_notFunction
merge = (y(:,1) + y(:,2)) / 2;
melFilterNum = 20;
[result_mel(1,:), bandpassMedianFreq] = melFilterbankAnalysis_bandpassMedian(Fs, result(1,:), melFilterNum);

hold off;
subplot(4,2,2);
xlim([0,N]);
plot(merge);
title('Waveform | Sample phrase(s)');
xlabel('Time (Seconds)');
ylabel('Amplitude');

subplot(4,2,4);
semilogx([20,20000]);
semilogx(result(1,:));
title('Spectrum | Sample phrase(s)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

subplot(4,2,6);
semilogx([20,20000]);
plot(bandpassMedianFreq, result_mel, '.');
title('Dimension Reduction | Sample phrase(s)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

clear

%以下、類似度計算プログラムのコピペ
%参考文献URL
%http://shower.human.waseda.ac.jp/~m-kouki/pukiwiki_public/73.html#v962bcc1

melFilterNum = 20;

%真似したい音楽
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File you want to use as reference ');
wb = waitbar(0,'Loading Audio Data...'); %進行状況の表示
[yourMusic, Fs] = audioToMatrix(fname_yourMusic, dpath_yourMusic);
%melFilterNum次元に圧縮したマトリクスの作成
yourMusic_mel = zeros(length(yourMusic(:,1)), melFilterNum);
for i = 1 : length(yourMusic(:,1))
    yourMusic_mel(i,:) = melFilterbankAnalysis(Fs, yourMusic(i,:), melFilterNum);
    waitbar((i / length(yourMusic(:,1))) / 2) %進行状況の表示
end
close(wb) %進行状況の非表示

%サンプル音楽ディレクトリの選択
dpath_sampleMusic  =  uigetdir;
D = dir([dpath_sampleMusic '/*.wav']);
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
    [matrix_sampleMusic, Fs] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic);
    %melFilterNum次元に圧縮したマトリクスの作成
    matrix_sampleMusic_mel = zeros(length(matrix_sampleMusic(:,1)), melFilterNum);
    for j = 1 : length(matrix_sampleMusic(:,1))
        matrix_sampleMusic_mel(j,:) = melFilterbankAnalysis(Fs, matrix_sampleMusic(j,:), melFilterNum);
    end

    %コサイン類似度計算
    similarity{k} = calculateCosineSimilarity(yourMusic_mel, matrix_sampleMusic_mel);

    %類似度があまりにも低いものは除外
    if nanmedian(similarity{k}) >= 0.0
        fname_sampleMusic_legend_index = fname_sampleMusic_legend_index + 1; %凡例用配列インデックスを増加
        fname_sampleMusic_legend{fname_sampleMusic_legend_index} = fname_sampleMusic{k}; %凡例用配列に追加
        %プロット_ここから
        subplot(4,1,4);
        plot(similarity{k})
        xlim([0, length(yourMusic(:,1))]);
        ylim([0.0, 1.0]);
        hold all;
        %プロット_ここまで
    end

    waitbar(1/2 + (k / length(D)) / 2) %進行状況の表示
end

%最後にプロット
title('Time series variation of similarities');
xlabel('Time (Seconds)');
ylabel('Similarity');
% legend(fname_sampleMusic_legend);
grid minor;
hold off;
close(wb) %進行状況の非表示