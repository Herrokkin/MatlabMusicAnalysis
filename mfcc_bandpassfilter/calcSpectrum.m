function [ Adft ] = calcSpectrum( wavdata, fftsize, pre_emphasis )
%CALCSPECTRUM サウンドデータにハン窓をかけ、プリエンファシスして振幅スペクトルを求める

%fftsize = 2048;                     %フーリエ変換の次数, 周波数ポイントの数
%pre_emphasis = 0.97;                %プリエンファシス係数

han_window = hanning(fftsize + 1);
wavdataW = han_window' .* wavdata;
wavdataWP = filter([1 (pre_emphasis*(-1))],1,wavdataW);
dft = fft(wavdataWP, fftsize);
Adft = abs(dft);
end

