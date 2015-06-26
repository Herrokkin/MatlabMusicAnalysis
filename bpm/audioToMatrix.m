function [merge, result, songBPM] = audioToMatrix(fname, dpath)
%UI�Ńt�@�C���擾
%[fname, dpath]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File');
[y, Fs] = audioread(fullfile(dpath, fname));

csvfilename = [dpath fname '_bpm.csv'];
existcsv = exist(csvfilename, 'file'); %csv�����݂��邩����

if existcsv == 2 %csv���݂���ꍇ
    result = csvread(csvfilename);
else %csv���݂��Ȃ��ꍇ=>�t�[���G�ϊ�
    %�X�e���I/���m�����ŕ���
    if length(y(1,:)) == 2 %�X�e���I��
        %merge = (y(:, 1) - y(:, 2)); %Side����=L-R
        merge = (y(:, 1) + y(:, 2)); %Mid����=L+R
    elseif length(y(1,:)) == 1 %���m������
        merge = y(:, 1); %���m���������̂܂܎g�p
    end

    %BPM����
    songBPM = searchBPM(merge, Fs);
    
    %�v���G���t�@�V�X(���拭��)
    pre_emphasis = 0.97; %�v���G���t�@�V�X�W��
    merge_emphasis = [];
    merge_emphasis(1) = merge(1);
    for countData = 2 : 1 : length(merge)
        %�v���G���t�@�V�X
        thisData = merge(countData) - (pre_emphasis * merge(countData - 1));
        merge_emphasis = [merge_emphasis; thisData];
    end

    %�����t�[���G�ϊ�
    frame_length = floor(Fs / (songBPM / 60) * 8); %�t���[����
    N = floor(length(merge_emphasis) / frame_length); %�y�ȁ��t���[����
    width_result = Fs; %�T���v�����O��
    result = zeros(N, width_result); %�Ԃ�l�ݒ�
    window = hamming(width_result); %�n�~���O���ݒ�
    index = 1;
    for t = 1 : N
        frame = merge_emphasis( (t - 1) * frame_length + 1 : (t - 1) * frame_length + width_result, 1); %�t���[���ݒ�
        frame_window = frame .* window; %�n�~���O���Ŋۂ�
        spectrum = abs(fft(frame_window)); %�����t�[���G�ϊ��ŃX�y�N�g��������
%         result(index, :) = spectrum(1:width_result, :); %�b���ƂɃX�y�N�g�������L�^�B
        result(index, :) = spectrum(1:width_result, :) - mean(spectrum(1:width_result, :)); %�b���ƂɃX�y�N�g�������L�^�B���ς������ĕW�����B
        result(index, :) = result(index, :) - min(result(index, :)); %�񕉒l�s��Ƃ��邽�߁A�S�̂ɍŏ��l���𑫂��B
        index = index + 1;
    end
%     result = diff(result); %�K���擾
%     csvwrite(csvfilename, result); %csv�����o��
end

%plot(result);
end