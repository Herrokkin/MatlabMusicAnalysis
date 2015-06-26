function [similarity] = calculateCosineSimilarity(yourMusic, srcMusic)
%���ꂼ��̍s���擾
lengthYourMusic_col = length(yourMusic(1,:));
lengthSrcMusic_col = length(srcMusic(1,:));
length_row = length(srcMusic(:,1));
%���炵�Ȃ���R�T�C���ގ��x�Z�o
similarity = zeros(1, lengthYourMusic_col - lengthSrcMusic_col + 1);
for col_count_all = 1 : lengthYourMusic_col - lengthSrcMusic_col + 1
        for row_count = 1 : length_row
            %�b���Ƃɑ������z��
            similarity(1,col_count_all) = sum(dot(yourMusic(row_count,col_count_all:col_count_all+lengthSrcMusic_col-1), srcMusic(row_count,:))) / (norm(yourMusic(row_count,col_count_all:col_count_all+lengthSrcMusic_col-1)) * norm(srcMusic(row_count,:)));
        end
end

%����k�ɂ�����ގ��x�́Ak+lengthSrcMusic�܂ł̗ގ��x�̕���
similarity = similarity / length_row;

end