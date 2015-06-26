function [y, result] = audioToMatrix(fname, dpath)
%UI�Ńt�@�C���擾
%[fname, dpath]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File');
[y, Fs] = audioread(fullfile(dpath, fname));

csvfilename = [dpath fname '.csv'];
existcsv = exist(csvfilename, 'file'); %csv�����݂��邩����

if existcsv == 2 %csv���݂���ꍇ
    result = csvread(csvfilename);
else %csv���݂��Ȃ��ꍇ=>�t�[���G�ϊ�
    %�X�e���I/���m�����ŕ���
    if length(y(1,:)) == 2 %�X�e���I��
        merge = (y(:, 1) - y(:, 2)); %Side����=L-R
%         merge = (y(:, 1) + y(:, 2)); %Mid����=L+R
    elseif length(y(1,:)) == 1 %���m������
        merge = y(:, 1); %���m���������̂܂܎g�p
    end

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
    N = floor(length(merge_emphasis) / Fs); %�y�Ȃ̕b���擾
    result = zeros(N, Fs); %�Ԃ�l�ݒ�
    window = hamming(Fs); %�n�~���O���ݒ�
    index = 1;
    for t = 1 : Fs : length(merge_emphasis) - Fs
        frame = merge_emphasis(t : t + Fs - 1, 1); %�t���[���ݒ�
        frame_window = frame .* window; %�n�~���O���Ŋۂ�
        spectrum = abs(fft(frame_window)); %�����t�[���G�ϊ��ŃX�y�N�g��������
        result(index, :) = spectrum; %�b���ƂɃX�y�N�g�������L�^
        index = index + 1;
    end
    csvwrite(csvfilename, result); %csv�����o��
end

%plot(result);
end