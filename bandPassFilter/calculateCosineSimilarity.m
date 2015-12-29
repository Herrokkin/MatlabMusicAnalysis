function [similarity] = calculateCosineSimilarity(yourMusic, srcMusic)
%‚»‚ê‚¼‚ê‚Ìs”æ“¾
lengthYourMusic = length(yourMusic(:,1));
lengthSrcMusic = length(srcMusic(:,1));

%ŒvZü”g”w’è
lowFrequency = 1;
highFrequency = 10000;

%Šes‚²‚Æ‚É^—‚µ‚½‚¢‘¤ƒmƒ‹ƒ€‚Ìì¬
normYourMusic = zeros(lengthYourMusic, 1);
for countNormYourMusic = 1 : lengthYourMusic
    normYourMusic(countNormYourMusic,1) = norm(yourMusic(countNormYourMusic, lowFrequency:highFrequency)); %lowFrequency-highFrequency(Hz)‚Ì‚İŒvZ‘ÎÛ
end

%Šes‚²‚Æ‚ÉƒTƒ“ƒvƒ‹‘¤ƒmƒ‹ƒ€‚Ìì¬
normSrcMusic = zeros(lengthSrcMusic, 1);
for countNormSrcMusic = 1 : lengthSrcMusic
    normSrcMusic(countNormSrcMusic,1) = norm(srcMusic(countNormSrcMusic, lowFrequency:highFrequency)); %lowFrequency-highFrequency(Hz)‚Ì‚İŒvZ‘ÎÛ
end

%‚¸‚ç‚µ‚È‚ª‚çƒRƒTƒCƒ“—Ş—“xZo
similarityTmp = zeros(lengthSrcMusic, 1, lengthYourMusic - lengthSrcMusic + 1);
for i = 1 : lengthYourMusic - lengthSrcMusic + 1
    for j = 1 : lengthSrcMusic
        %•b‚²‚Æ‚É‘½ŸŒ³”z—ñ‰»
        similarityTmp(j,1,i) = (dot(yourMusic(i+j-1, lowFrequency:highFrequency), srcMusic(j, lowFrequency:highFrequency))) / (normYourMusic(i+j-1,1) * normSrcMusic(j,1)); %lowFrequency-highFrequency(Hz)‚Ì‚İŒvZ‘ÎÛ
    end
end

%k‚É‚¨‚¯‚é—Ş—“x‚ÍAk+lengthSrcMusic‚Ü‚Å‚Ì—Ş—“x‚Ì•½‹Ï
%‘æ1s‚É‚ÍAè‡’l’´‚¦ƒJƒEƒ“ƒg‚ğŠi”[‚·‚é‚½‚ßA+1B
similarity = zeros(1, lengthYourMusic - lengthSrcMusic + 1 + 1);
%similarity(1,1) = sum(similarityTmp(:,1,1)) / lengthSrcMusic;
for k = 1 : lengthYourMusic - lengthSrcMusic + 1
    similarity(1, k) = sum(similarityTmp(:,1,k)) / lengthSrcMusic;
    if isnan(similarity(1, k)) == 1
        similarity(1, k) = 0;
    end
end
% similarity(lengthYourMusic - lengthSrcMusic + 1 + 1,1) = sum(similarity > 0.30);
end