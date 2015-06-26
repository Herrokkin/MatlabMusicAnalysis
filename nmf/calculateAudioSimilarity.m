%function [] = calculateAudioSimilarity()

%�^�����������y
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference ');
[y_yourMusic, yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic);
[W_yourMusic, H_yourMusic] = nnmf(yourMusic,1);
subplot(2,1,1);
plot(y_yourMusic(:, 1));
title(fname_yourMusic);
xlabel('Time (Seconds)');

%�T���v�����y�f�B���N�g���̑I��
dpath_sampleMusic_tmp  =  uigetdir;
dpath_sampleMusic = [dpath_sampleMusic_tmp '/'];
D = dir([dpath_sampleMusic '*.wav']);
fname_sampleMusic = cell(1, length(D));
fname_sampleMusic_legend = []; %�}��p�z����쐬
fname_sampleMusic_legend_index = 0; %�}��p�z��C���f�b�N�X���쐬
similarity = cell(1, length(D));
wb = waitbar(0,'Please wait...'); %�i�s�󋵂̕\��

for k = 1 : length(D)
    %�T���v�����}�g���N�X�̍쐬
    [pathstr_sampleMusic,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); %�p�X�A�t�@�C�����A�g���q�̎擾
    fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); %�t�@�C�����Ɗg���q������
    %�}�g���N�X�擾
    [~, matrix_sampleMusic] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic);
    
    %NMF�Ŋ��E�W�������A�W�����̂݌v�Z�ɗ��p
    [W_matrix_sampleMusic, H_matrix_sampleMusic] = nnmf(matrix_sampleMusic,1);

    %�R�T�C���ގ��x�v�Z
    similarity_W = calculateCosineSimilarity(W_yourMusic, W_matrix_sampleMusic) * 0.6;
    similarity_H = calculateCosineSimilarity(yourMusic, H_matrix_sampleMusic) * 0.4;
    similarity{k} = similarity_W + similarity_H;

    %�v���b�g�֘A
    subplot(2,1,2);
    fname_sampleMusic_legend_index = fname_sampleMusic_legend_index + 1; %�}��p�z��C���f�b�N�X�𑝉�
    fname_sampleMusic_legend{fname_sampleMusic_legend_index} = fname_sampleMusic{k}; %�}��p�z��ɒǉ�
    %�v���b�g_��������
    plot(similarity{k})
    xlim([0, length(yourMusic(:,1))]);
    ylim([0.0, 1.0]);
    hold all;
    %�v���b�g_�����܂�

    waitbar(k / length(D)) %�i�s�󋵂̕\��
end

title(['Time series variation of similarities | ' fname_yourMusic]);
xlabel('Time (Seconds)');
ylabel('Similarity');
legend(fname_sampleMusic_legend);
grid minor;
hold off;
close(wb) %�i�s�󋵂̔�\��

%end