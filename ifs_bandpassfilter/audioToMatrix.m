function [merge_starttime_filtered, result, songBPM, Fs] = audioToMatrix(fname, dpath, frame_beats, bandpass_choice)
% UIでファイル取得
% [fname, dpath]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File');
[y, Fs] = audioread(fullfile(dpath, fname));

csvfilename = [dpath fname '_bpm.csv'];

%% ステレオ/モノラルで分岐
% merge：変数yを1チャンネルのオブジェクトに置換えた変数
if length(y(1,:)) == 2 % ステレオ時
    % merge = (y(:, 1) - y(:, 2)); % Side成分=L-R
    merge = (y(:, 1) + y(:, 2)); % Mid成分=L+R
elseif length(y(1,:)) == 1 % モノラル時
    merge = y(:, 1); % モノラルをそのまま使用
end

%% BPM推定
songBPM = searchBPM(merge, Fs);

% %% プリエンファシス(高域強調)
% pre_emphasis = 0.97; % プリエンファシス係数
% merge_high_emphasis = []; % merge_high_emphasis：高域強調済み音声の変数
% merge_high_emphasis(1) = merge(1);
% for countData = 2 : 1 : length(merge)
%     % プリエンファシス
%     thisData = merge(countData) - (pre_emphasis * merge(countData - 1));
%     merge_high_emphasis = [merge_high_emphasis; thisData];
% end
merge_high_emphasis = merge;

%% 拍の先頭を推定
peak_count_frame_size = 512; % 拍の先頭を見つける歳のフレーム幅
peak_count_frame_max = Fs * 0.5 / peak_count_frame_size; % 最初のn秒間を使用
for peak_count = 1 : peak_count_frame_max - 1
    if sum(merge_high_emphasis((peak_count - 1) * peak_count_frame_size + 1 : (peak_count - 1) * peak_count_frame_size + peak_count_frame_size, 1)) .^2 <= sum(merge_high_emphasis(peak_count * peak_count_frame_size + 1 : peak_count * peak_count_frame_size + peak_count_frame_size, 1)) .^2 && sum(merge_high_emphasis(peak_count * peak_count_frame_size + 1 : peak_count * peak_count_frame_size + peak_count_frame_size, 1)) .^2 >= sum(merge_high_emphasis((peak_count + 1) * peak_count_frame_size + 1 : (peak_count + 1) * peak_count_frame_size + peak_count_frame_size, 1)) .^2
        peak_count_start = peak_count;
    end
end
merge_starttime = merge_high_emphasis(peak_count_start * peak_count_frame_size : length(merge_high_emphasis),1); % merge_starttime：拍の先頭を推定

%% FFT前準備
frame_length = floor(Fs / (songBPM / 60) * frame_beats); %フレーム幅。最後に掛けるののはビート数
N = floor(length(merge_starttime) / frame_length); %楽曲÷フレーム幅
width_result = Fs; %サンプリング長。Fsだと高次元の為、小さめに。
result = zeros(N, width_result); %返り値設定
% window = hamming(width_result); %ハミング窓設定

%% 帯域フィルタ
% 現状はメロディ(Vocalに相当)、リズム(Drumに相当)、ハーモニー(Bass)のみで静的な分岐。周波数は、Shure社の表を参照。
% http://www.shureblog.jp/shure-notes/%E3%83%9E%E3%82%A4%E3%82%AF%E3%83%AD%E3%83%9B%E3%83%B3-%E5%91%A8%E6%B3%A2%E6%95%B0%E7%89%B9%E6%80%A7%E3%81%AE%E8%A6%8B%E6%96%B9/
if bandpass_choice == 1 % Melody
    Wn = [150 4000]/(Fs/2); % 通過帯域を表すベクトル。0Hzが0、(Fs/2)Hzが1となるようスケーリング
    fil = fir1(width_result, Wn ,'bandpass'); % バンドパスフィルタの設計
    merge_starttime_filtered = filter(fil, 1, merge_starttime);
elseif bandpass_choice == 2 % Rhythm
    Wn = [80 4000]/(Fs/2); % 阻止帯域を表すベクトル。0Hzが0、(Fs/2)Hzが1となるようスケーリング
    fil = fir1(width_result, Wn ,'stop'); % バンドストップフィルタの設計
    merge_starttime_filtered = filter(fil, 1, merge_starttime);
elseif bandpass_choice == 3 % Harmony
    Wn = [80 300]/(Fs/2); % 通過帯域を表すベクトル。0Hzが0、(Fs/2)Hzが1となるようスケーリング
    fil = fir1(width_result, Wn ,'bandpass'); % バンドパスフィルタの設計
    merge_starttime_filtered = filter(fil, 1, merge_starttime);
else
    merge_starttime_filtered = merge_starttime;
end


%% Instantaneous Frequency Spectrum (IFS)
t = 0:1/Fs:length(y)/Fs; % time vector
z = hilbert(merge_starttime_filtered);
merge_starttime_filtered_instfreq = Fs/(2*pi)*diff(unwrap(angle(z)));

%% Make matrix by bars
index = 1;
for t = 1 : N
    frame = merge_starttime_filtered( (t - 1) * frame_length + 1 : (t - 1) * frame_length + width_result, 1); %フレーム設定
    result(index, :) = frame;
    index = index + 1;
end

%plot(result);
end
