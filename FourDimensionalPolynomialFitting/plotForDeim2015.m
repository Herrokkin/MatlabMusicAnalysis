%Disclosure - You & Me�ǂݍ���
audioToMatrixFitting_notFunction
merge = (y(:,1) + y(:,2)) / 2;

subplot(4,2,1);
xlim([0,N]);
plot(merge);
title('Waveform | Music for analysis');
xlabel('Time (Seconds)');
ylabel('Amplitude');

subplot(4,2,3);
xlim([20,20000]);
semilogx(means_result);
title('Spectrum | Music for analysis');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

subplot(4,2,5);
xlim([20,20000]);
semilogx(fit);
title('Fourth-Degree Polynomial Fit | Music for analysis');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

clear

%�A�[�����ǂݍ���
audioToMatrixFitting_notFunction
merge = (y(:,1) + y(:,2)) / 2;

hold off;
subplot(4,2,2);
xlim([0,N]);
plot(merge);
title('Waveform | Sample phrase(s)');
xlabel('Time (Seconds)');
ylabel('Amplitude');

subplot(4,2,4);
xlim([20,20000]);
semilogx(means_result);
title('Spectrum | Sample phrase(s)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

subplot(4,2,6);
xlim([20,20000]);
semilogx(fit);
title('Fourth-Degree Polynomial Fit | Sample phrase(s)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

clear

%�ȉ��A�ގ��x�v�Z�v���O�����̃R�s�y
%�^�����������y
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File you want to use as reference ');
yourMusic = audioToMatrix(fname_yourMusic, dpath_yourMusic);

%�T���v�����y�f�B���N�g���̑I��
dpath_sampleMusic  =  uigetdir;
D = dir([dpath_sampleMusic '/*.wav']);
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
    [matrix_sampleMusic, low_index, high_index] = audioToMatrixFitting(fname_sampleMusic{k}, dpath_sampleMusic);

    %�t�B�b�e�B���O�֐��̎R�̐��ɂ���ď����𕪊�
    yourMusic_tmp = yourMusic;
    if length(low_index) == 1 %�R��1�̏ꍇ
        %�t�B���^�p���g���̐ݒ�B3�̎R�̎��g���̍���1/3���A3���ꂼ��̎R�Ƀv���}�C
        filter01 = low_index(1,1) * 2 / 3;
        filter02 = low_index(1,1) + (22050 - low_index(1,1) / 3);
        %�^�����������y���A�T���v�����̎��g���̎R�ɓY���Đ��`
        yourMusic_tmp(:, filter01 : filter02) = 0.0;
    elseif length(low_index) == 2 %�R��2�̏ꍇ
        %�t�B���^�p���g���̐ݒ�B3�̎R�̎��g���̍���1/3���A3���ꂼ��̎R�Ƀv���}�C
        filter01 = low_index(1,1) * 2 / 3;
        filter02 = low_index(1,1) + ((high_index(1,1) - low_index(1,1)) / 3);
        filter03 = low_index(1,2) - ((low_index(1,2) - high_index(1,1)) / 3);
        filter04 = low_index(1,2) + (22050 - low_index(1,2) / 3);
        %�^�����������y���A�T���v�����̎��g���̎R�ɓY���Đ��`
        yourMusic_tmp(:, filter01 : filter02) = 0.0;
        yourMusic_tmp(:, filter03 : filter04) = 0.0;
    end        

    %�R�T�C���ގ��x�v�Z
    similarity{k} = calculateCosineSimilarity(yourMusic_tmp, matrix_sampleMusic);

    %�ގ��x�����܂�ɂ��Ⴂ���̂͏��O
    if nanmedian(similarity{k}) >= 0.2
        fname_sampleMusic_legend_index = fname_sampleMusic_legend_index + 1; %�}��p�z��C���f�b�N�X�𑝉�
        fname_sampleMusic_legend{fname_sampleMusic_legend_index} = fname_sampleMusic{k}; %�}��p�z��ɒǉ�
        %�v���b�g_��������
        subplot(4,1,4);
        plot(similarity{k})
        xlim([0, length(yourMusic(:,1))]);
        ylim([0.0, 1.0]);
        hold all;
        %�v���b�g_�����܂�
    end

    waitbar(k / length(D)) %�i�s�󋵂̕\��
end

%�Ō�Ƀv���b�g
title('Time series variation of similarities | ');
xlabel('Time (Seconds)');
ylabel('Similarity');
% legend(fname_sampleMusic_legend);
grid minor;
hold off;
close(wb) %�i�s�󋵂̔�\��