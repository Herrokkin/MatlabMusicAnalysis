%function [] = calculateAudioSimilarity()

%% ----------n小節ごとの頭1秒のみを取り出し、相関量を計量するプログラム----------
% -----使用する関数-----
% 1)オーディオデータをFFT・マトリクス化
% [y, result, bpm] = audioToMatrix(fname, dpath, beats)
%
% 2)コサイン類似度計量
% similarity{} = calculateCosineSimilarity(yourMusic, sampleMusic)

%% -----分析対象とする楽曲を取得・変換・プロット-----
% 分析対象とする楽曲の選択
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'分析対象とする楽曲を選択してください。 | Open Audio File you want to use as reference.');
% genre_choice_str = {'blues','classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
% genre_choice_yourMusic = menu('楽曲のジャンルを選択してください。 | What genre is this music?','blues','classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock');

% 分析対象とする楽曲のメタタグ入力
yourMusicTitle = input('Song Title (with single quote): ');
yourMusicArtist = input('Artist (with single quote): ');

% バンドパスフィルタ用セレクトボックス
bandpass_choice_str = {'Melody', 'Rhythm', 'Harmony'};
bandpass_choice = menu('楽曲のどの部分を比較対象としたいですか？ | Which sections do you want to compare?','メロディ | Melody','リズム | Rhythm', 'ハーモニー | Harmony');

% 分析対象とする楽曲をFFT・マトリクス化
[y_yourMusic, yourMusic, bpm_yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic, 4, bandpass_choice);

% 分析対象とする楽曲のプロット
figure;
subplot(2, 1, 1);
plot(y_yourMusic(:, 1));
title([fname_yourMusic ' | ' bandpass_choice_str{bandpass_choice}]);
xlabel('Time (Seconds)');

%% -----サンプル音楽ディレクトリの選択・取得・変換・コサイン類似度計量・プロット-----
% サンプル音楽ディレクトリの選択
dpath_sampleMusic  =  uigetdir;
dpath_sampleMusic = [dpath_sampleMusic '/'];
sampleMusicDataset = input('Dataset Name: '); % データセット名入力
D = dir([dpath_sampleMusic '*.wav']); % wavファイル検索
fname_sampleMusic = cell(1, length(D)); % 凡例用セル配列を作成
similarity = cell(1, length(D)); % 類似度用テンポラリセル配列
result = cell(length(D), 200); %　結果用セル配列, col1-5: メタ情報, col6-195: 類似度
wb = waitbar(0,'Please wait...'); % 進行状況の表示

% サンプル音楽ディレクトリ内のwavファイルそれぞれについて、FFT・マトリクス化・類似度計量・プロット
for k = 1 : length(D)
    % サンプル側マトリクスの作成
    [~,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); %パス、ファイル名、拡張子の取得
    fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); %ファイル名と拡張子を結合
    % マトリクス取得
    [~, matrix_sampleMusic, ~] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic, 4, bandpass_choice);

    % コサイン類似度計算
    similarity{k} = calculateCosineSimilarity(yourMusic, matrix_sampleMusic);
    
    % 結果用セル配列のデータ埋め込み
    % col1-5: メタ情報, col6-195: 類似度
    % Title, Artist, DatasetName, Part, Filename, Sim001, ..., sim195
    result{k, 1} = yourMusicTitle;
    result{k, 2} = yourMusicArtist;
    result{k, 3} = sampleMusicDataset;
    result{k, 4} = bandpass_choice_str{bandpass_choice};
    result{k, 5} = fname_sampleMusic{k};
    for result_index = 1 : length(similarity{k}(1, :))
        result{k, result_index + 5} = similarity{k}(1, result_index); % col6-195: 類似度埋め込み
        % col(last)-col195を0に固定。
        if length(similarity{k}(1, :)) + 5 + result_index <= 200
            result{k, length(similarity{k}(1, :)) + 5 + result_index} = 0;
        end
    end
    
    % 類似度のプロット(1)
    subplot(2, 1,2);
    plot(similarity{k}(1:length(similarity{k}) - 1), '-x')
    xlim([1.0, length(yourMusic(:, 1)) + 1]);
    ylim([0.0, 1.0]);
    hold all;

    waitbar(k / length(D)) % 進行状況の表示
end

% 類似度のプロット(2)
title(['Time series variation of similarities | ' fname_yourMusic]);
xlabel('Time (bars)');
ylabel('Similarity');
legend(fname_sampleMusic);
grid minor;
hold off;
close(wb) % 進行状況の非表示


%% -----結果用セル配列のテーブル化およびcsv書き出し-----
resultTable = cell2table(result);
writetable(resultTable,'tabledata.csv');

%end