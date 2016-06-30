function [songBPM] = searchBPM(y, Fs)
% %UIでファイル取得
% [fname, dpath]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File');
% [y, Fs] = audioread(fullfile(dpath, fname));
%
% %ステレオ/モノラルで分岐
% if length(y(1,:)) == 2 %ステレオ時
%     %merge = (y(:, 1) - y(:, 2)); %Side成分=L-R
%     merge = (y(:, 1) + y(:, 2)); %Mid成分=L+R
% elseif length(y(1,:)) == 1 %モノラル時
%     merge = y(:, 1); %モノラルをそのまま使用
% end

%% ここからBPM分割
%http://ism1000ch.hatenablog.com/entry/2014/07/08/164124
merge = y;
sample_total = length(merge);
ts = 1 / Fs; %サンプリング周波数

%フレームごとの音量データ作成
%フレームサイズ分の振幅二乗和を計算
frame_size = 512;
sample_max = sample_total - rem(sample_total, frame_size); %余りフレームは切り捨てる
frame_max = sample_max / frame_size;
amp_list = []; %音量データ

for x = 0 : frame_max - 1
    amp_list = horzcat(amp_list, sum(merge(x * frame_size + 1 : x * frame_size + frame_size ,1) .^2));
end

%音量の増加量を取得
%負値は0にする
amp_diff_list = diff(amp_list);
amp_diff_list(1, find(amp_diff_list<=0)) = 0;

%bpm推定
%match_list = calc_all_match(amp_diff_list, Fs);
match_list = zeros(1,59);
%bpm_iter = 60:200;

%各BPMでmatch度計量
for bpm = 60:200
    match = calc_match_bpm(amp_diff_list, Fs, bpm);
    match_list = horzcat(match_list, match);
end

% %プロット部分
% plot(match_list)
% title(['BPM | ' fname]);
% xlim([60, 200]);
% grid minor;

%計算したBPMをreturn
songBPM = find(match_list == max(match_list));

end
