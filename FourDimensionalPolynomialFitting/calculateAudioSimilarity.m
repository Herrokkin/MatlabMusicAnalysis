%function [] = calculateAudioSimilarity()

%�^�����������y
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference ');
[y_yourMusic, yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic);
subplot(2,1,1);
plot(y_yourMusic(:, 1));
title(fname_yourMusic);
xlabel('Time (Seconds)');

%�T���v�����y�f�B���N�g���̑I��
dpath_sampleMusic_tmp  =  uigetdir;
dpath_sampleMusic = [dpath_sampleMusic_tmp '/'];
D = dir([dpath_sampleMusic '*.au']);
fname_sampleMusic = cell(1, length(D));
fname_sampleMusic_legend = []; %�}��p�z����쐬
fname_sampleMusic_legend_index = 0; %�}��p�z��C���f�b�N�X���쐬
similarity = cell(1, length(D));
wb = waitbar(0,'Please wait...'); %�i�s�󋵂̕\��

for k = 1 : length(D)
    %�T���v�����}�g���N�X�̍쐬
    [pathstr_sampleMusic,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); %�p�X�A�t�@�C�����A�g���q�̎擾
    fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); %�t�@�C�����Ɗg���q������
    %�}�g���N�X�ƃt�B�b�e�B���O�������g���̎R���擾
    [~, matrix_sampleMusic, low_index, high_index] = audioToMatrixFitting(fname_sampleMusic{k}, dpath_sampleMusic);

    %�t�B�b�e�B���O�֐��̎R�̐��ɂ���ď����𕪊�
    yourMusic_tmp = yourMusic;
    if length(low_index) == 1 %�R��1�̏ꍇ
        %�t�B���^�p���g���̐ݒ�B3�̎R�̎��g���̍���1/3���A3���ꂼ��̎R�Ƀv���}�C
        filter01 = low_index(1,1) * 2 / 3;
        filter02 = low_index(1,1) + ((20000 - low_index(1,1)) / 3);
        %�^�����������y���A�T���v�����̎��g���̎R�ɓY���Đ��`
        yourMusic_tmp(:, filter01 : filter02) = 0.0;
    elseif length(low_index) == 2 %�R��2�̏ꍇ
        %�t�B���^�p���g���̐ݒ�B3�̎R�̎��g���̍���1/3���A3���ꂼ��̎R�Ƀv���}�C
        filter01 = low_index(1,1) * 2 / 3;
        filter02 = low_index(1,1) + ((high_index(1,1) - low_index(1,1)) / 3);
        filter03 = low_index(1,2) - ((low_index(1,2) - high_index(1,1)) / 3);
        filter04 = low_index(1,2) + ((20000 - low_index(1,2)) / 3);
        %�^�����������y���A�T���v�����̎��g���̎R�ɓY���Đ��`
        yourMusic_tmp(:, filter01 : filter02) = 0.0;
        yourMusic_tmp(:, filter03 : filter04) = 0.0;
    end        

    %�R�T�C���ގ��x�v�Z
    similarity{k} = calculateCosineSimilarity(yourMusic_tmp, matrix_sampleMusic);

    %�ގ��x�����܂�ɂ��Ⴂ���̂͏��O
    subplot(2,1,2);
    if nanmedian(similarity{k}) >= 0.0
        fname_sampleMusic_legend_index = fname_sampleMusic_legend_index + 1; %�}��p�z��C���f�b�N�X�𑝉�
        fname_sampleMusic_legend{fname_sampleMusic_legend_index} = fname_sampleMusic{k}; %�}��p�z��ɒǉ�
        %�v���b�g_��������
        plot(similarity{k})
        xlim([0, length(yourMusic(:,1))]);
        ylim([0.0, 1.0]);
        hold all;
        %�v���b�g_�����܂�
    end

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