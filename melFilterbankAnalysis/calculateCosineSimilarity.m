function [similarity] = calculateCosineSimilarity(yourMusic, srcMusic)

%���ꂼ��̍s���擾
lengthYourMusic = length(yourMusic(:,1));
lengthSrcMusic = length(srcMusic(:,1));

%�e�s���Ƃɐ^�����������m�����̍쐬
normYourMusic = zeros(lengthYourMusic, 1);
for countNormYourMusic = 1 : lengthYourMusic
    normYourMusic(countNormYourMusic,1) = norm(yourMusic(countNormYourMusic,:)); %20-20000Hz�̂݌v�Z�Ώ�
end

%�e�s���ƂɃT���v�����m�����̍쐬
normSrcMusic = zeros(lengthSrcMusic, 1);
for countNormSrcMusic = 1 : lengthSrcMusic
    normSrcMusic(countNormSrcMusic,1) = norm(srcMusic(countNormSrcMusic,:)); %20-20000Hz�̂݌v�Z�Ώ�
end

%���炵�Ȃ���R�T�C���ގ��x�Z�o
similarityTmp = zeros(lengthSrcMusic, 1, lengthYourMusic - lengthSrcMusic + 1);
for i = 1 : lengthYourMusic - lengthSrcMusic + 1
    for j = 1 : lengthSrcMusic
        %�b���Ƃɑ������z��
        similarityTmp(j,1,i) = (dot(yourMusic(i+j-1,:), srcMusic(j,:))) / (normYourMusic(i+j-1,1) * normSrcMusic(j,1)); %20-20000Hz�̂݌v�Z�Ώ�
    end
end

%����k�ɂ�����ގ��x�́Ak+lengthSrcMusic�܂ł̗ގ��x�̕���
similarity = zeros(lengthYourMusic - lengthSrcMusic + 1, 1);
similarity(1,1) = sum(similarityTmp(:,1,1)) / lengthSrcMusic;
for k = 2 : lengthYourMusic - lengthSrcMusic + 1
    %1�O�̗ގ��x�Ƃ̍���
    distance = (sum(similarityTmp(:,1,k)) / lengthSrcMusic) - (sum(similarityTmp(:,1,k-1)) / lengthSrcMusic);
    similarity(k,1) = sum(similarityTmp(:,1,k)) / lengthSrcMusic;
%     if distance >= 0.1 %臒l�ȏ�̎�
%         similarity(k,1) = (sum(similarityTmp(:,1,k)) / lengthSrcMusic) + distance; %������ǉ�
%     else %����ȊO�̎�
%         similarity(k,1) = sum(similarityTmp(:,1,k)) / lengthSrcMusic; %���̂܂�
%     end
end

end