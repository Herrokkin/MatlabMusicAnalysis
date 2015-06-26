function [merge, result, songBPM] = audioToMatrix(fname, dpath)
%UIでファイル取得
%[fname, dpath]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File');
[y, Fs] = audioread(fullfile(dpath, fname));

csvfilename = [dpath fname '_bpm.csv'];
existcsv = exist(csvfilename, 'file'); %csvが存在するか判定

if existcsv == 2 %csv存在する場合
    result = csvread(csvfilename);
else %csv存在しない場合=>フーリエ変換
    %ステレオ/モノラルで分岐
    if length(y(1,:)) == 2 %ステレオ時
        %merge = (y(:, 1) - y(:, 2)); %Side成分=L-R
        merge = (y(:, 1) + y(:, 2)); %Mid成分=L+R
    elseif length(y(1,:)) == 1 %モノラル時
        merge = y(:, 1); %モノラルをそのまま使用
    end

    %BPM推定
    songBPM = searchBPM(merge, Fs);
    
    %プリエンファシス(高域強調)
    pre_emphasis = 0.97; %プリエンファシス係数
    merge_emphasis = [];
    merge_emphasis(1) = merge(1);
    for countData = 2 : 1 : length(merge)
        %プリエンファシス
        thisData = merge(countData) - (pre_emphasis * merge(countData - 1));
        merge_emphasis = [merge_emphasis; thisData];
    end

    %高速フーリエ変換
    frame_length = floor(Fs / (songBPM / 60) * 8); %フレーム幅
    N = floor(length(merge_emphasis) / frame_length); %楽曲÷フレーム幅
    width_result = Fs; %サンプリング長
    result = zeros(N, width_result); %返り値設定
    window = hamming(width_result); %ハミング窓設定
    index = 1;
    for t = 1 : N
        frame = merge_emphasis( (t - 1) * frame_length + 1 : (t - 1) * frame_length + width_result, 1); %フレーム設定
        frame_window = frame .* window; %ハミング窓で丸め
        spectrum = abs(fft(frame_window)); %高速フーリエ変換でスペクトラム生成
%         result(index, :) = spectrum(1:width_result, :); %秒ごとにスペクトラムを記録。
        result(index, :) = spectrum(1:width_result, :) - mean(spectrum(1:width_result, :)); %秒ごとにスペクトラムを記録。平均を引いて標準化。
        result(index, :) = result(index, :) - min(result(index, :)); %非負値行列とするため、全体に最小値分を足す。
        index = index + 1;
    end
%     result = diff(result); %階差取得
%     csvwrite(csvfilename, result); %csv書き出し
end

%plot(result);
end