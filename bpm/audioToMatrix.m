function [merge, result, songBPM] = audioToMatrix(fname, dpath, frame_beats)
%UI�Ńt�@�C���擾
%[fname, dpath]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File');
[y, Fs] = audioread(fullfile(dpath, fname));

csvfilename = [dpath fname '_bpm.csv'];
existcsv = exist(csvfilename, 'file'); %csv�����݂��邩����

if existcsv == 2 %csv���݂���ꍇ
    result = csvread(csvfilename);
else %csv���݂��Ȃ��ꍇ=>�t�[���G�ϊ�
    % %�X�e���I/���m�����ŕ���
    if length(y(1,:)) == 2 %�X�e���I��
        %merge = (y(:, 1) - y(:, 2)); %Side����=L-R
        merge = (y(:, 1) + y(:, 2)); %Mid����=L+R
    elseif length(y(1,:)) == 1 %���m������
        merge = y(:, 1); %���m���������̂܂܎g�p
    end

    %% BPM����
    songBPM = searchBPM(merge, Fs);
    
    %% �v���G���t�@�V�X(���拭��)
    pre_emphasis = 0.97; %�v���G���t�@�V�X�W��
    merge_high_emphasis = [];
    merge_high_emphasis(1) = merge(1);
    for countData = 2 : 1 : length(merge)
        %�v���G���t�@�V�X
        thisData = merge(countData) - (pre_emphasis * merge(countData - 1));
        merge_high_emphasis = [merge_high_emphasis; thisData];
    end
    
    %% ���̐擪�𐄒�
    peak_count_frame_size = 512;
    peak_count_frame_max = Fs * 0.5 / peak_count_frame_size; %�ŏ���n�b�Ԃ��g�p
    for peak_count = 1 : peak_count_frame_max - 1
        if sum(merge_high_emphasis((peak_count - 1) * peak_count_frame_size + 1 : (peak_count - 1) * peak_count_frame_size + peak_count_frame_size, 1)) .^2 <= sum(merge_high_emphasis(peak_count * peak_count_frame_size + 1 : peak_count * peak_count_frame_size + peak_count_frame_size, 1)) .^2 && sum(merge_high_emphasis(peak_count * peak_count_frame_size + 1 : peak_count * peak_count_frame_size + peak_count_frame_size, 1)) .^2 >= sum(merge_high_emphasis((peak_count + 1) * peak_count_frame_size + 1 : (peak_count + 1) * peak_count_frame_size + peak_count_frame_size, 1)) .^2
            peak_count_start = peak_count;
        end
    end
    merge_starttime = merge_high_emphasis(peak_count_start * peak_count_frame_size : length(merge_high_emphasis),1);
    
    %% �����t�[���G�ϊ�
    frame_length = floor(Fs / (songBPM / 60) * frame_beats); %�t���[�����B�Ō�Ɋ|����̂̂̓r�[�g��
    N = floor(length(merge_starttime) / frame_length); %�y�ȁ��t���[����
    width_result = 11025; %�T���v�����O���BFs���ƍ������B
    result = zeros(N, width_result); %�Ԃ�l�ݒ�
    window = hamming(width_result); %�n�~���O���ݒ�
    index = 1;
    for t = 1 : N
        frame = merge_starttime( (t - 1) * frame_length + 1 : (t - 1) * frame_length + width_result, 1); %�t���[���ݒ�
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