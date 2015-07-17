%function [] = calculateAudioSimilarity()

%% n���߂��Ƃ̓�1�b�݂̂����o���A���֗ʂ��v�ʂ���v���O���� %%%%%%%%%%
%%%% functions %%%%
%%% [y, result, bpm] = audioToMatrix(fname, dpath, beats) %%%
%%% similarity{} = calculateCosineSimilarity(yourMusic, sampleMusic) %%%

%% �^�����������y���擾�E�ϊ��E�v���b�g
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference ');
[y_yourMusic, yourMusic, bpm_yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic, 8);
figure;
subplot(2,1,1);
plot(y_yourMusic(:, 1));
title(fname_yourMusic);
xlabel('Time (Seconds)');

%% �T���v�����y�f�B���N�g���̑I���E�擾�E�ϊ��E�R�T�C���ގ��x�v�ʁE�v���b�g
dpath_sampleMusic  =  uigetdir;
dpath_sampleMusic = [dpath_sampleMusic '/'];
D = dir([dpath_sampleMusic '*.wav']);
fname_sampleMusic = cell(1, length(D));
fname_sampleMusic_legend = []; %�}��p�z����쐬
fname_sampleMusic_legend_index = 0; %�}��p�z��C���f�b�N�X���쐬
similarity = cell(1, length(D));
wb = waitbar(0,'Please wait...'); %�i�s�󋵂̕\��

for k = 1 : length(D)
    %�T���v�����}�g���N�X�̍쐬
    [~,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); %�p�X�A�t�@�C�����A�g���q�̎擾
    fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); %�t�@�C�����Ɗg���q������
    %�}�g���N�X�擾
    [~, matrix_sampleMusic, ~] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic, 4);

    %�R�T�C���ގ��x�v�Z
    similarity{k} = calculateCosineSimilarity(yourMusic, matrix_sampleMusic);
    
    %�v���b�g�֘A
    subplot(2,1,2);
    fname_sampleMusic_legend_index = fname_sampleMusic_legend_index + 1; %�}��p�z��C���f�b�N�X�𑝉�
    fname_sampleMusic_legend{fname_sampleMusic_legend_index} = fname_sampleMusic{k}; %�}��p�z��ɒǉ�
    %�v���b�g_��������
    plot(similarity{k}(1:length(similarity{k}) - 1), '-x')
    xlim([1.0, length(yourMusic(:,1)) + 1]);
    ylim([0.0, 1.0]);
    hold all;
    %�v���b�g_�����܂�

    waitbar(k / length(D)) %�i�s�󋵂̕\��
end

title(['Time series variation of similarities | ' fname_yourMusic]);
xlabel('Time (bars)');
ylabel('Similarity');
legend(fname_sampleMusic_legend);
grid minor;
hold off;
close(wb) %�i�s�󋵂̔�\��

%% �W����������
%�y�ȑS��
fname_genre_all_mean = fname_sampleMusic_legend{1};
index_genre_all_mean = 1;
index_min_similarity_length = 1;
for loop_genre_all = 2: length(similarity)
    if mean(similarity{index_genre_all_mean}) <= mean(similarity{loop_genre_all}) %���ς��g�p
        fname_genre_all_mean = fname_sampleMusic_legend{loop_genre_all};
        index_genre_all_mean = loop_genre_all;
    end
    %�e�ގ��x�̒����ŏ��l�擾�Btf�l�p�B
    if length(similarity{index_min_similarity_length}) >= length(similarity{loop_genre_all})
        min_similarity_length = length(similarity{loop_genre_all});
    end
end

%���n��ω�
%disp(min_similarity_length);
%fname_genre_part = fname_sampleMusic_legend{1};
fname_genre_part = [];
index_genre_part_x = 1;
index_genre_part_y = 1;
for loop_genre_part_x = 2: length(similarity)
    for loop_genre_part_y = 2: min_similarity_length
        if similarity{index_genre_part_x}(index_genre_part_y,1) <= similarity{loop_genre_part_x}(loop_genre_part_y,1)
            fname_genre_part{loop_genre_part_y} = fname_sampleMusic_legend{loop_genre_part_x};
        end
    end
end

%tf-idf�v�Z
fname_genre_part(find(cellfun('isempty',fname_genre_part))) = []; %�Z����[]�������폜
tf_idf_cell = cell(length(fname_sampleMusic_legend), 3); %tf-idf�i�[�p�ϐ�
fname_genre_all_tf = fname_sampleMusic_legend{1};
index_genre_all_tf = 1;
for tf_idf_cell_x = 1 : 3
    for tf_idf_cell_y = 1 : length(fname_sampleMusic_legend)
        tf_idf_cell{tf_idf_cell_y, 1} = fname_sampleMusic_legend{tf_idf_cell_y};
        tf_temp = strfind(fname_genre_part, fname_sampleMusic_legend{tf_idf_cell_y});
        tf_temp(find(cellfun('isempty',tf_temp))) = []; %�Z����[]�������폜
        tf_idf_cell{tf_idf_cell_y, 2} = length(tf_temp);
        if tf_idf_cell{index_genre_all_tf, 2} <= tf_idf_cell{tf_idf_cell_y, 2}
            fname_genre_all_tf = fname_sampleMusic_legend{tf_idf_cell_y};
            index_genre_all_tf = tf_idf_cell_y;
        end
        tf_idf_cell{tf_idf_cell_y, 3} = 0;
    end
end

disp(['Genre: ' fname_genre_all_mean ', Mean: ' num2str(mean(similarity{index_genre_all_mean}))]); %mean�ŏo�����W��������\��
disp(['Genre: ' fname_genre_all_tf ', TF: ' num2str(tf_idf_cell{index_genre_all_tf, 2}) '/' num2str(length(fname_sampleMusic_legend)) ' (' num2str(tf_idf_cell{index_genre_all_tf, 2} / length(fname_sampleMusic_legend) * 100) '%)']); %TF�ŏo�����W��������\��



%end