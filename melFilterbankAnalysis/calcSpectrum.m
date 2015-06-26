function [ Adft ] = calcSpectrum( wavdata, fftsize, pre_emphasis )
%CALCSPECTRUM �T�E���h�f�[�^�Ƀn�����������A�v���G���t�@�V�X���ĐU���X�y�N�g�������߂�

%fftsize = 2048;                     %�t�[���G�ϊ��̎���, ���g���|�C���g�̐�
%pre_emphasis = 0.97;                %�v���G���t�@�V�X�W��

han_window = hanning(fftsize + 1);
wavdataW = han_window' .* wavdata;
wavdataWP = filter([1 (pre_emphasis*(-1))],1,wavdataW);
dft = fft(wavdataWP, fftsize);
Adft = abs(dft);
end

