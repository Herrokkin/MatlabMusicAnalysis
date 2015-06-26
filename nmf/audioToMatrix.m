function [y, result] = audioToMatrix(fname, dpath)
%UIでファイル取得
%[fname, dpath]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File');
[y, Fs] = audioread(fullfile(dpath, fname));

csvfilename = [dpath fname '.csv'];
existcsv = exist(csvfilename, 'file'); %csvが存在するか判定

if existcsv == 2 %csv存在する場合
    result = csvread(csvfilename);
else %csv存在しない場合=>フーリエ変換
    %ステレオ/モノラルで分岐
    if length(y(1,:)) == 2 %ステレオ時
        merge = (y(:, 1) - y(:, 2)); %Side成分=L-R
%         merge = (y(:, 1) + y(:, 2)); %Mid成分=L+R
    elseif length(y(1,:)) == 1 %モノラル時
        merge = y(:, 1); %モノラルをそのまま使用
    end

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
    N = floor(length(merge_emphasis) / Fs); %楽曲の秒数取得
    result = zeros(N, Fs); %返り値設定
    window = hamming(Fs); %ハミング窓設定
    index = 1;
    for t = 1 : Fs : length(merge_emphasis) - Fs
        frame = merge_emphasis(t : t + Fs - 1, 1); %フレーム設定
        frame_window = frame .* window; %ハミング窓で丸め
        spectrum = abs(fft(frame_window)); %高速フーリエ変換でスペクトラム生成
        result(index, :) = spectrum; %秒ごとにスペクトラムを記録
        index = index + 1;
    end
    csvwrite(csvfilename, result); %csv書き出し
end

%plot(result);
end