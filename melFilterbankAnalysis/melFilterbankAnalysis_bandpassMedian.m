function [AdftSum, bandpassMedianFreq] = melFilterbankAnalysis_bandpassMedian(Fs, Adft, melFilterNum)
fftsize = Fs;                         % �t�[���G�ϊ��̎���, ���g���|�C���g�̐�
fscale = linspace(0, Fs/2, fftsize/2);  % ���g���X�P�[���i0�`Fs/2��fftsize/2�ɕ����j
Adft_log = log10(Adft);

% �����t�B���^�o���N�̊J�n�E�I�����g�������߂�
%  melFilterNum = 20;                      % �t�B���^�o���N�̕�����
melScale = mellog(fscale);              % �����X�P�[����
melWidth = max(melScale) / ( melFilterNum / 2 + 0.5 );  %�t�B���^�o���N�̕�
%  �����X�P�[����œ��Ԋu�A�����������ׂ͗Əd�����Ă���̂�(������/2+0.5)�Ŋ���
%  �Ō�ɑ���0.5�͉E�[�̎O�p���̉E�����̒���
bandpassFreq = [];
countFilterNum = 0;
for count = min(melScale) : melWidth/2 : max(melScale)
    countFilterNum = countFilterNum + 1;
    if countFilterNum <= melFilterNum
        startMel = count;               % ���̃t�B���^�̊J�n�����l
        endMel = count + melWidth;      % ���̃t�B���^�̏I�������l
        % �x�N�g��melScale�̒��ŁAstartMel�ɍł��߂��l�̔ԍ��𓾂�
        [startNum startData] = getNearNum(melScale, startMel);
        % �x�N�g��melScale�̒��ŁAendMel�ɍł��߂��l�̔ԍ��𓾂�
        [endNum endData] = getNearNum(melScale, endMel);
        % ���g���X�P�[���ɕϊ�
        bandpassFreq = [bandpassFreq ; fscale(startNum) fscale(endNum)];
    end
end
% �����t�B���^�o���N�̗��z���������
mBank = [];
for count = 1 : 1 : length(bandpassFreq)
    % ���g���X�P�[���̊Ԋu�����߂�
    fScaleInterval = Fs / fftsize;
    % �O�p���̃Q�C�����������
    startFreq = bandpassFreq(count,1);
    endFreq = bandpassFreq(count,2);
    % fScaleInterval[Hz]�����ɁA����(endFreq - startFreq)Hz�̎O�p�������
    triWin = triang((endFreq - startFreq)/fScaleInterval)';
    % �Q�C���̒l��������
    m = zeros(1,length(fscale));
    % startFreqHz����endFreqHz�̋�Ԃ̃Q�C���� triWin �ɒu������
    m(ceil(startFreq/fScaleInterval):ceil(endFreq/fScaleInterval-1)) = triWin;
    mBank = [mBank ; m];
end

% ���z�����̃����t�B���^�o���N�ɐU���X�y�N�g�����|�����킹�āA�e�ш��
% �X�y�N�g���̘a�����߁A�U���X�y�N�g����20�����Ɉ��k����
filtersize = length(bandpassFreq);              % �t�B���^�̐�
AdftSum = [];
for count = 1 : 1 : filtersize
    % �t�B���^��������
    AdftFilterBank = Adft(1:fftsize/2) .* mBank(count,1:fftsize/2);
    % �a���Ƃ�
    AdftSum = [AdftSum sum(AdftFilterBank)];
end

% �t�B���^�o���N�ɂ���� melFilterNum �����Ɉ��k���ꂽ�ΐ��U���X�y�N�g�������߂�
bandpassMedianFreq = median(bandpassFreq,2);    % �o���h�p�X�t�B���^�̒��S���g��

% AdftSum_log = log10(AdftSum);
% 
% % �R�T�C���ϊ�
% cpst = 12;      % �P�v�X�g�����W���i�᎟���������������o�����j
% AdftCpst = dct(AdftSum_log);
end