function [similarity] = calculateCosineSimilarity(yourMusic, srcMusic, highFrequency)
%それぞれの行数取得
lengthYourMusic = length(yourMusic(:,1));
lengthSrcMusic = length(srcMusic(:,1));

% 計算周波数指定
lowFrequency = 1;
% highFrequency = 10000;

% 各行ごとに真似したい側ノルムの作成
normYourMusic = zeros(lengthYourMusic, 1);
for countNormYourMusic = 1 : lengthYourMusic
    normYourMusic(countNormYourMusic,1) = norm(yourMusic(countNormYourMusic, lowFrequency:highFrequency)); %lowFrequency-highFrequency(Hz)のみ計算対象
end

% 各行ごとにサンプル側ノルムの作成
normSrcMusic = zeros(lengthSrcMusic, 1);
for countNormSrcMusic = 1 : lengthSrcMusic
    normSrcMusic(countNormSrcMusic,1) = norm(srcMusic(countNormSrcMusic, lowFrequency:highFrequency)); %lowFrequency-highFrequency(Hz)のみ計算対象
end

% ずらしながらコサイン類似度算出
similarityTmp = zeros(lengthSrcMusic, 1, lengthYourMusic - lengthSrcMusic + 1);
for i = 1 : lengthYourMusic - lengthSrcMusic + 1
    for j = 1 : lengthSrcMusic
        %秒ごとに多次元配列化
        similarityTmp(j,1,i) = (dot(yourMusic(i+j-1, lowFrequency:highFrequency), srcMusic(j, lowFrequency:highFrequency))) / (normYourMusic(i+j-1,1) * normSrcMusic(j,1)); %lowFrequency-highFrequency(Hz)のみ計算対象
    end
end

% 時刻kにおける類似度は、k+lengthSrcMusicまでの類似度の平均
% 第1行には、閾値超えカウントを格納するため、+1。
similarity = zeros(1, lengthYourMusic - lengthSrcMusic + 1 + 1);
%similarity(1,1) = sum(similarityTmp(:,1,1)) / lengthSrcMusic;
for k = 1 : lengthYourMusic - lengthSrcMusic + 1
    similarity(1, k) = sum(similarityTmp(:,1,k)) / lengthSrcMusic;
    if isnan(similarity(1, k)) == 1
        similarity(1, k) = 0;
    end
end
% similarity = similarity / mean(similarity); % 平均で割る
% similarity(lengthYourMusic - lengthSrcMusic + 1 + 1,1) = sum(similarity > 0.30);
end
