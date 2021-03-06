function [similarity] = calculateCosineSimilarity(yourMusic, srcMusic)
%それぞれの行数取得
lengthYourMusic = length(yourMusic(:,1));
lengthSrcMusic = length(srcMusic(:,1));

%各行ごとに真似したい側ノルムの作成
normYourMusic = zeros(lengthYourMusic, 1);
for countNormYourMusic = 1 : lengthYourMusic
    normYourMusic(countNormYourMusic,1) = norm(yourMusic(countNormYourMusic,:));
end

%各行ごとにサンプル側ノルムの作成
normSrcMusic = zeros(lengthSrcMusic, 1);
for countNormSrcMusic = 1 : lengthSrcMusic
    normSrcMusic(countNormSrcMusic,1) = norm(srcMusic(countNormSrcMusic,:));
end

%ずらしながらコサイン類似度算出
similarityTmp = zeros(lengthSrcMusic, 1, lengthYourMusic - lengthSrcMusic + 1);
for i = 1 : lengthYourMusic - lengthSrcMusic + 1
    for j = 1 : lengthSrcMusic
        %秒ごとに多次元配列化
        similarityTmp(j,1,i) = (dot(yourMusic(i+j-1,:), srcMusic(j,:))) / (normYourMusic(i+j-1,1) * normSrcMusic(j,1));
    end
end

%時刻kにおける類似度は、k+lengthSrcMusicまでの類似度の平均
similarity = zeros(lengthYourMusic - lengthSrcMusic + 1, 1);
similarity(1,1) = sum(similarityTmp(:,1,1)) / lengthSrcMusic;
for k = 2 : lengthYourMusic - lengthSrcMusic + 1
    similarity(k,1) = sum(similarityTmp(:,1,k)) / lengthSrcMusic;
end

end