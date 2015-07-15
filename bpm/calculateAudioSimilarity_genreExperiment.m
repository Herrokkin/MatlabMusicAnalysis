%function [] = calculateAudioSimilarity_genreExperiment()

%% n���߂��Ƃ̓�1�b�݂̂����o���A���֗ʂ��v�ʂ���v���O���� %%%%%%%%%%
%%%% functions %%%%
%%% [y, result, bpm] = audioToMatrix(fname, dpath, beats) %%%
%%% similarity{} = calculateCosineSimilarity(yourMusic, sampleMusic) %%%

%% �^�����������y���擾�E�ϊ��E�v���b�g
%[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference ');
dpath_yourMusic = uigetdir;
dpath_yourMusic = [dpath_yourMusic '/'];
D_yourMusic = dir([dpath_yourMusic '.au']);
fname_yourMusic = cell(1, length(D_yourMusic));
fname_yourMusic_legend = []; %�}��p�z����쐬
% fname_yourMusic_legend_index = 0; %�}��p�z��C���f�b�N�X���쐬
% [y_yourMusic, yourMusic, bpm_yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic, 16);

dpath_sampleMusic  =  uigetdir;

index = 1;
for k = 1 : length(D_yourMusic)
    %�T���v�����}�g���N�X�̍쐬
    [~,name_yourMusic,ext_yourMusic] = fileparts(D_yourMusic(k).name); %�p�X�A�t�@�C�����A�g���q�̎擾
    fname_yourMusic{k} = strcat(name_yourMusic, ext_yourMusic); %�t�@�C�����Ɗg���q������
    %�}�g���N�X�擾
    [~, yourMusic{k}, ~] = audioToMatrix(fname_yourMusic{k}, dpath_yourMusic, 16);
    
    [similarity_tmp{k}, tf_idf_cell_tmp{k}] = calculateSimilarityAndTfInSampleMusicDirectory(yourMusic{k}, dpath_sampleMusic);
end

% figure;
% subplot(2,1,1);
% plot(y_yourMusic(:, 1));
% title(fname_yourMusic);
% xlabel('Time (Seconds)');

%% �T���v�����y�f�B���N�g���̑I���E�擾�E�ϊ��E�R�T�C���ގ��x�v�ʁE�v���b�g
% dpath_sampleMusic  =  uigetdir;



%end