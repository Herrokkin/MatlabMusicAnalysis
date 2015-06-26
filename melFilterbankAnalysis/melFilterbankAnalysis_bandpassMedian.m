function [AdftSum, bandpassMedianFreq] = melFilterbankAnalysis_bandpassMedian(Fs, Adft, melFilterNum)
fftsize = Fs;                         % フーリエ変換の次数, 周波数ポイントの数
fscale = linspace(0, Fs/2, fftsize/2);  % 周波数スケール（0～Fs/2をfftsize/2に分割）
Adft_log = log10(Adft);

% メルフィルタバンクの開始・終了周波数を求める
%  melFilterNum = 20;                      % フィルタバンクの分割数
melScale = mellog(fscale);              % メルスケール軸
melWidth = max(melScale) / ( melFilterNum / 2 + 0.5 );  %フィルタバンクの幅
%  メルスケール上で等間隔、ただし半分は隣と重複しているので(分割数/2+0.5)で割る
%  最後に足す0.5は右端の三角窓の右半分の長さ
bandpassFreq = [];
countFilterNum = 0;
for count = min(melScale) : melWidth/2 : max(melScale)
    countFilterNum = countFilterNum + 1;
    if countFilterNum <= melFilterNum
        startMel = count;               % このフィルタの開始メル値
        endMel = count + melWidth;      % このフィルタの終了メル値
        % ベクトルmelScaleの中で、startMelに最も近い値の番号を得る
        [startNum startData] = getNearNum(melScale, startMel);
        % ベクトルmelScaleの中で、endMelに最も近い値の番号を得る
        [endNum endData] = getNearNum(melScale, endMel);
        % 周波数スケールに変換
        bandpassFreq = [bandpassFreq ; fscale(startNum) fscale(endNum)];
    end
end
% メルフィルタバンクの理想応答を作る
mBank = [];
for count = 1 : 1 : length(bandpassFreq)
    % 周波数スケールの間隔を求める
    fScaleInterval = Fs / fftsize;
    % 三角窓のゲイン特性を作る
    startFreq = bandpassFreq(count,1);
    endFreq = bandpassFreq(count,2);
    % fScaleInterval[Hz]おきに、長さ(endFreq - startFreq)Hzの三角窓を作る
    triWin = triang((endFreq - startFreq)/fScaleInterval)';
    % ゲインの値を初期化
    m = zeros(1,length(fscale));
    % startFreqHzからendFreqHzの区間のゲインを triWin に置き換え
    m(ceil(startFreq/fScaleInterval):ceil(endFreq/fScaleInterval-1)) = triWin;
    mBank = [mBank ; m];
end

% 理想応答のメルフィルタバンクに振幅スペクトルを掛け合わせて、各帯域の
% スペクトルの和を求め、振幅スペクトルを20次元に圧縮する
filtersize = length(bandpassFreq);              % フィルタの数
AdftSum = [];
for count = 1 : 1 : filtersize
    % フィルタをかける
    AdftFilterBank = Adft(1:fftsize/2) .* mBank(count,1:fftsize/2);
    % 和をとる
    AdftSum = [AdftSum sum(AdftFilterBank)];
end

% フィルタバンクによって melFilterNum 次元に圧縮された対数振幅スペクトルを求める
bandpassMedianFreq = median(bandpassFreq,2);    % バンドパスフィルタの中心周波数

% AdftSum_log = log10(AdftSum);
% 
% % コサイン変換
% cpst = 12;      % ケプストラム係数（低次成分何次元を取り出すか）
% AdftCpst = dct(AdftSum_log);
end