function [similarity] = calculateCosineSimilarity(yourMusic, srcMusic)
%それぞれの行数取得
lengthYourMusic_col = length(yourMusic(1,:));
lengthSrcMusic_col = length(srcMusic(1,:));
length_row = length(srcMusic(:,1));
%ずらしながらコサイン類似度算出
similarity = zeros(1, lengthYourMusic_col - lengthSrcMusic_col + 1);
for col_count_all = 1 : lengthYourMusic_col - lengthSrcMusic_col + 1
        for row_count = 1 : length_row
            %秒ごとに多次元配列化
            similarity(1,col_count_all) = sum(dot(yourMusic(row_count,col_count_all:col_count_all+lengthSrcMusic_col-1), srcMusic(row_count,:))) / (norm(yourMusic(row_count,col_count_all:col_count_all+lengthSrcMusic_col-1)) * norm(srcMusic(row_count,:)));
        end
end

%時刻kにおける類似度は、k+lengthSrcMusicまでの類似度の平均
similarity = similarity / length_row;

end