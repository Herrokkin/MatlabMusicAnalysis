%Disclosure - You & Me�ǂݍ���
audioToMatrix_notFunction
melFilterNum = 20;
merge = (y(:,1) + y(:,2)) / 2;
[result_mel(1,:), bandpassMedianFreq] = melFilterbankAnalysis_bandpassMedian(Fs, result(1,:), melFilterNum);

subplot(4,2,1);
xlim([0,N]);
plot(merge);
title('Waveform | Music for analysis');
xlabel('Time (Seconds)');
ylabel('Amplitude');

subplot(4,2,3);
xlim([20,20000]);
semilogx(result(1,:));
title('Spectrum | Music for analysis');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

subplot(4,2,5);
xlim([20,20000]);
semilogx(bandpassMedianFreq, result_mel, '.');
title('Dimension Reduction | Music for analysis');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

clear

%�A�[�����ǂݍ���
audioToMatrix_notFunction
merge = (y(:,1) + y(:,2)) / 2;
melFilterNum = 20;
[result_mel(1,:), bandpassMedianFreq] = melFilterbankAnalysis_bandpassMedian(Fs, result(1,:), melFilterNum);

hold off;
subplot(4,2,2);
xlim([0,N]);
plot(merge);
title('Waveform | Sample phrase(s)');
xlabel('Time (Seconds)');
ylabel('Amplitude');

subplot(4,2,4);
semilogx([20,20000]);
semilogx(result(1,:));
title('Spectrum | Sample phrase(s)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

subplot(4,2,6);
semilogx([20,20000]);
plot(bandpassMedianFreq, result_mel, '.');
title('Dimension Reduction | Sample phrase(s)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

clear

%�ȉ��A�ގ��x�v�Z�v���O�����̃R�s�y
%�Q�l����URL
%http://shower.human.waseda.ac.jp/~m-kouki/pukiwiki_public/73.html#v962bcc1

melFilterNum = 20;

%�^�����������y
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File you want to use as reference ');
wb = waitbar(0,'Loading Audio Data...'); %�i�s�󋵂̕\��
[yourMusic, Fs] = audioToMatrix(fname_yourMusic, dpath_yourMusic);
%melFilterNum�����Ɉ��k�����}�g���N�X�̍쐬
yourMusic_mel = zeros(length(yourMusic(:,1)), melFilterNum);
for i = 1 : length(yourMusic(:,1))
    yourMusic_mel(i,:) = melFilterbankAnalysis(Fs, yourMusic(i,:), melFilterNum);
    waitbar((i / length(yourMusic(:,1))) / 2) %�i�s�󋵂̕\��
end
close(wb) %�i�s�󋵂̔�\��

%�T���v�����y�f�B���N�g���̑I��
dpath_sampleMusic  =  uigetdir;
D = dir([dpath_sampleMusic '/*.wav']);
fname_sampleMusic = cell(1, length(D));
fname_sampleMusic_legend = []; %�}��p�z����쐬
fname_sampleMusic_legend_index = 0; %�}��p�z��C���f�b�N�X���쐬
similarity = cell(1, length(D));
wb = waitbar(1/2,'Calculating Similarities...'); %�i�s�󋵂̕\��

for k = 1 : length(D)
    %�T���v�����}�g���N�X�̍쐬
    [pathstr_sampleMusic,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); %�p�X�A�t�@�C�����A�g���q�̎擾
    fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); %�t�@�C�����Ɗg���q������
    %���g���X�y�N�g�����擾
    [matrix_sampleMusic, Fs] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic);
    %melFilterNum�����Ɉ��k�����}�g���N�X�̍쐬
    matrix_sampleMusic_mel = zeros(length(matrix_sampleMusic(:,1)), melFilterNum);
    for j = 1 : length(matrix_sampleMusic(:,1))
        matrix_sampleMusic_mel(j,:) = melFilterbankAnalysis(Fs, matrix_sampleMusic(j,:), melFilterNum);
    end

    %�R�T�C���ގ��x�v�Z
    similarity{k} = calculateCosineSimilarity(yourMusic_mel, matrix_sampleMusic_mel);

    %�ގ��x�����܂�ɂ��Ⴂ���̂͏��O
    if nanmedian(similarity{k}) >= 0.0
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

    waitbar(1/2 + (k / length(D)) / 2) %�i�s�󋵂̕\��
end

%�Ō�Ƀv���b�g
title('Time series variation of similarities');
xlabel('Time (Seconds)');
ylabel('Similarity');
% legend(fname_sampleMusic_legend);
grid minor;
hold off;
close(wb) %�i�s�󋵂̔�\��