[fname, dpath]  =  uigetfile({'*.wav;*.mp3','Audio File(*.wav,*.mp3)'},'Open Audio File');
[y, Fs] = audioread(fullfile(dpath, fname));

 % �����g�`�̒���������؂�o���āA�U���X�y�N�g�������߂�
 cuttime = 1.0;                         % �؂�o������[s]
 timeScale = 0 : 1/Fs : length(y)/Fs;
 pre_emphasis = 0.97;                    % �v���G���t�@�V�X�W��
 fftsize = 2048;                         % �t�[���G�ϊ��̎���, ���g���|�C���g�̐�
 fscale = linspace(0, Fs/2, fftsize/2);  % ���g���X�P�[���i0�`Fs/2��fftsize/2�ɕ����j
 center = fix(length(y) / 2);
 wavdata = y(center-fix(cuttime/2*Fs) : center+fix(cuttime/2*Fs));
 time = timeScale(center-fix(cuttime/2*Fs) : center+fix(cuttime/2*Fs));
 Adft = calcSpectrum( wavdata, fftsize, pre_emphasis );
 Adft_log = log10(Adft);
 figure(1); subplot(4,1,1); semilogx(fscale, Adft(1:fftsize/2));
 xlim([0,20000]); title(strcat('���Ƃ̉����g�`�̐U���X�y�N�g��'));

 % �����t�B���^�o���N�̊J�n�E�I�����g�������߂�
 melFilterNum = 20;                      % �t�B���^�o���N�̕�����
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
%      figure(2); subplot((filtersize/4),4,count);
%      plot(fscale(1:fftsize/2), AdftFilterBank); xlim([0,20000]);

     % �a���Ƃ�
     AdftSum = [AdftSum sum(AdftFilterBank)];
 end

 % �t�B���^�o���N�ɂ���� melFilterNum �����Ɉ��k���ꂽ�ΐ��U���X�y�N�g�������߂�
 bandpassMedianFreq = median(bandpassFreq,2);    % �o���h�p�X�t�B���^�̒��S���g��
 figure(1); subplot(4,1,2);
 semilogx(bandpassMedianFreq, AdftSum, '.', bandpassMedianFreq, AdftSum, '-');
 xlim([0,20000]); title(strcat(int2str(melFilterNum),' �����Ɉ��k���ꂽ�U���X�y�N�g��'));
 AdftSum_log = log10(AdftSum);
 figure(1); subplot(4,1,3);
 semilogx(bandpassMedianFreq, AdftSum_log, '.', bandpassMedianFreq, AdftSum_log, '-');
 xlim([0,20000]); title(strcat(int2str(melFilterNum),' �����Ɉ��k���ꂽ�ΐ��U���X�y�N�g��'));

 % �R�T�C���ϊ�
 cpst = 12;      % �P�v�X�g�����W���i�᎟���������������o�����j
 AdftCpst = dct(AdftSum_log);
 AdftCpst_low = AdftCpst(1:cpst);
 figure(1); subplot(4,1,4);
 semilogx(AdftCpst, '.'); hold on; semilogx(AdftCpst_low, 'r.');
 xlabel('�P�t�����V�['); title('�������g���P�v�X�g�����W��');