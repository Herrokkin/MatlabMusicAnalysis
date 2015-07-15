function [songBPM] = searchBPM(y, Fs)
% %UI�Ńt�@�C���擾
% [fname, dpath]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File');
% [y, Fs] = audioread(fullfile(dpath, fname));
% 
% %�X�e���I/���m�����ŕ���
% if length(y(1,:)) == 2 %�X�e���I��
%     %merge = (y(:, 1) - y(:, 2)); %Side����=L-R
%     merge = (y(:, 1) + y(:, 2)); %Mid����=L+R
% elseif length(y(1,:)) == 1 %���m������
%     merge = y(:, 1); %���m���������̂܂܎g�p
% end

%% ��������BPM����
%http://ism1000ch.hatenablog.com/entry/2014/07/08/164124
merge = y;
sample_total = length(merge);
ts = 1 / Fs; %�T���v�����O���g��

%�t���[�����Ƃ̉��ʃf�[�^�쐬
%�t���[���T�C�Y���̐U�����a���v�Z
frame_size = 512;
sample_max = sample_total - rem(sample_total, frame_size); %�]��t���[���͐؂�̂Ă�
frame_max = sample_max / frame_size;
amp_list = []; %���ʃf�[�^

for x = 0 : frame_max - 1
    amp_list = horzcat(amp_list, sum(merge(x * frame_size + 1 : x * frame_size + frame_size ,1) .^2));
end

%���ʂ̑����ʂ��擾
%���l��0�ɂ���
amp_diff_list = diff(amp_list);
amp_diff_list(1, find(amp_diff_list<=0)) = 0;

%bpm����
%match_list = calc_all_match(amp_diff_list, Fs);
match_list = zeros(1,59);
%bpm_iter = 60:200;

%�eBPM��match�x�v��
for bpm = 60:200
    match = calc_match_bpm(amp_diff_list, Fs, bpm);
    match_list = horzcat(match_list, match);
end

% %�v���b�g����
% plot(match_list)
% title(['BPM | ' fname]);
% xlim([60, 200]);
% grid minor;

%�v�Z����BPM��return
songBPM = find(match_list == max(match_list));

end