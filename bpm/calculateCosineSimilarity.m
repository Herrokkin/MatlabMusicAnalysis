function [similarity] = calculateCosineSimilarity(yourMusic, srcMusic)
%���ꂼ��̍s���擾
lengthYourMusic = length(yourMusic(:,1));
lengthSrcMusic = length(srcMusic(:,1));

%�e�s���Ƃɐ^�����������m�����̍쐬
normYourMusic = zeros(lengthYourMusic, 1);
for countNormYourMusic = 1 : lengthYourMusic
    normYourMusic(countNormYourMusic,1) = norm(yourMusic(countNormYourMusic, 1:22050)); %20-20000Hz�̂݌v�Z�Ώ�
end

%�e�s���ƂɃT���v�����m�����̍쐬
normSrcMusic = zeros(lengthSrcMusic, 1);
for countNormSrcMusic = 1 : lengthSrcMusic
    normSrcMusic(countNormSrcMusic,1) = norm(srcMusic(countNormSrcMusic, 1:22050)); %20-20000Hz�̂݌v�Z�Ώ�
end

%���炵�Ȃ���R�T�C���ގ��x�Z�o
similarityTmp = zeros(lengthSrcMusic, 1, lengthYourMusic - lengthSrcMusic + 1);
for i = 1 : lengthYourMusic - lengthSrcMusic + 1
    for j = 1 : lengthSrcMusic
        %�b���Ƃɑ������z��
        similarityTmp(j,1,i) = (dot(yourMusic(i+j-1, 1:22050), srcMusic(j, 1:22050))) / (normYourMusic(i+j-1,1) * normSrcMusic(j,1)); %20-20000Hz�̂݌v�Z�Ώ�
    end
end

%����k�ɂ�����ގ��x�́Ak+lengthSrcMusic�܂ł̗ގ��x�̕���
%��1�s�ɂ́A臒l�����J�E���g���i�[���邽�߁A+1�B
similarity = zeros(lengthYourMusic - lengthSrcMusic + 1 + 1, 1);
%similarity(1,1) = sum(similarityTmp(:,1,1)) / lengthSrcMusic;
for k = 1 : lengthYourMusic - lengthSrcMusic + 1
    similarity(k,1) = sum(similarityTmp(:,1,k)) / lengthSrcMusic;
end
% similarity(lengthYourMusic - lengthSrcMusic + 1 + 1,1) = sum(similarity > 0.30);
end