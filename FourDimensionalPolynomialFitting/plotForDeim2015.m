%Disclosure - You & Me読み込み
audioToMatrixFitting_notFunction
merge = (y(:,1) + y(:,2)) / 2;

subplot(4,2,1);
xlim([0,N]);
plot(merge);
title('Waveform | Music for analysis');
xlabel('Time (Seconds)');
ylabel('Amplitude');

subplot(4,2,3);
xlim([20,20000]);
semilogx(means_result);
title('Spectrum | Music for analysis');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

subplot(4,2,5);
xlim([20,20000]);
semilogx(fit);
title('Fourth-Degree Polynomial Fit | Music for analysis');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

clear

%アーメン読み込み
audioToMatrixFitting_notFunction
merge = (y(:,1) + y(:,2)) / 2;

hold off;
subplot(4,2,2);
xlim([0,N]);
plot(merge);
title('Waveform | Sample phrase(s)');
xlabel('Time (Seconds)');
ylabel('Amplitude');

subplot(4,2,4);
xlim([20,20000]);
semilogx(means_result);
title('Spectrum | Sample phrase(s)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

subplot(4,2,6);
xlim([20,20000]);
semilogx(fit);
title('Fourth-Degree Polynomial Fit | Sample phrase(s)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

clear

%以下、類似度計算プログラムのコピペ
%真似したい音楽
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File you want to use as reference ');
yourMusic = audioToMatrix(fname_yourMusic, dpath_yourMusic);

%サンプル音楽ディレクトリの選択
dpath_sampleMusic  =  uigetdir;
D = dir([dpath_sampleMusic '/*.wav']);
fname_sampleMusic = cell(1, length(D));
fname_sampleMusic_legend = []; %凡例用配列を作成
fname_sampleMusic_legend_index = 0; %凡例用配列インデックスを作成
similarity = cell(1, length(D));
wb = waitbar(0,'Please wait...'); %進行状況の表示

for k = 1 : length(D)
    %サンプル側マトリクスの作成
    [pathstr_sampleMusic,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); %パス、ファイル名、拡張子の取得
    fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); %ファイル名と拡張子を結合
    %マトリクスとフィッティングした周波数の山を取得
    [matrix_sampleMusic, low_index, high_index] = audioToMatrixFitting(fname_sampleMusic{k}, dpath_sampleMusic);

    %フィッティング関数の山の数によって処理を分岐
    yourMusic_tmp = yourMusic;
    if length(low_index) == 1 %山が1つの場合
        %フィルタ用周波数の設定。3つの山の周波数の差の1/3を、3つそれぞれの山にプラマイ
        filter01 = low_index(1,1) * 2 / 3;
        filter02 = low_index(1,1) + (22050 - low_index(1,1) / 3);
        %真似したい音楽を、サンプル側の周波数の山に添って整形
        yourMusic_tmp(:, filter01 : filter02) = 0.0;
    elseif length(low_index) == 2 %山が2つの場合
        %フィルタ用周波数の設定。3つの山の周波数の差の1/3を、3つそれぞれの山にプラマイ
        filter01 = low_index(1,1) * 2 / 3;
        filter02 = low_index(1,1) + ((high_index(1,1) - low_index(1,1)) / 3);
        filter03 = low_index(1,2) - ((low_index(1,2) - high_index(1,1)) / 3);
        filter04 = low_index(1,2) + (22050 - low_index(1,2) / 3);
        %真似したい音楽を、サンプル側の周波数の山に添って整形
        yourMusic_tmp(:, filter01 : filter02) = 0.0;
        yourMusic_tmp(:, filter03 : filter04) = 0.0;
    end        

    %コサイン類似度計算
    similarity{k} = calculateCosineSimilarity(yourMusic_tmp, matrix_sampleMusic);

    %類似度があまりにも低いものは除外
    if nanmedian(similarity{k}) >= 0.2
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

    waitbar(k / length(D)) %進行状況の表示
end

%最後にプロット
title('Time series variation of similarities | ');
xlabel('Time (Seconds)');
ylabel('Similarity');
% legend(fname_sampleMusic_legend);
grid minor;
hold off;
close(wb) %進行状況の非表示