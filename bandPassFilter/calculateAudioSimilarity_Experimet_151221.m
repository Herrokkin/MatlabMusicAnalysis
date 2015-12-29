%function [] = calculateAudioSimilarity()

%% ----------n���߂��Ƃ̓�1�b�݂̂����o���A���֗ʂ��v�ʂ���v���O����----------
% -----�g�p����֐�-----
% 1)�I�[�f�B�I�f�[�^��FFT�E�}�g���N�X��
% [y, result, bpm] = audioToMatrix(fname, dpath, beats)
%
% 2)�R�T�C���ގ��x�v��
% similarity{} = calculateCosineSimilarity(yourMusic, sampleMusic)

%% -----�����p�����o�̓v���O����-----
genreName = input('Genre Name (with single quote): ');
bandpass_choice = menu('�y�Ȃ̂ǂ̕������r�ΏۂƂ������ł����H | Which sections do you want to compare?','�����f�B | Melody','���Y�� | Rhythm', '�n�[���j�[ | Harmony');
% for���[�v�̉񐔂����v�ʂ��J��Ԃ�
for filecount = 0 : 9
    
    % ���͑ΏۂƂ���y�Ȃ̑I��
    dpath_yourMusic = ['/Users/K1/Documents/MATLAB/Audio/AudioFiles/genres/' genreName '/'];
    fname_yourMusic = [genreName '.0000' int2str(filecount) '.wav'];
    % [fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'���͑ΏۂƂ���y�Ȃ�I�����Ă��������B | Open Audio File you want to use as reference.');
    % genre_choice_str = {'blues','classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
    % genre_choice_yourMusic = menu('�y�Ȃ̃W��������I�����Ă��������B | What genre is this music?','blues','classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock');

    % ���͑ΏۂƂ���y�Ȃ̃��^�^�O����
    yourMusicTitle = [genreName '.0000' int2str(filecount)];
    yourMusicArtist = 'genres';
    % yourMusicTitle = input('Song Title (with single quote): ');
    % yourMusicArtist = input('Artist (with single quote): ');

    % �o���h�p�X�t�B���^�p�Z���N�g�{�b�N�X
    bandpass_choice_str = {'Melody', 'Rhythm', 'Harmony'};
    % bandpass_choice = menu('�y�Ȃ̂ǂ̕������r�ΏۂƂ������ł����H | Which sections do you want to compare?','�����f�B | Melody','���Y�� | Rhythm', '�n�[���j�[ | Harmony');

    % ���͑ΏۂƂ���y�Ȃ�FFT�E�}�g���N�X��
    [y_yourMusic, yourMusic, bpm_yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic, 4, bandpass_choice);

    % ���͑ΏۂƂ���y�Ȃ̃v���b�g
    figure;
    subplot(2, 1, 1);
    plot(y_yourMusic(:, 1));
    title([fname_yourMusic ' | ' bandpass_choice_str{bandpass_choice}]);
    xlabel('Time (Seconds)');

    % %% -----���͑ΏۂƂ���y�Ȃ��擾�E�ϊ��E�v���b�g-----
    % % ���͑ΏۂƂ���y�Ȃ̑I��
    % [fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'���͑ΏۂƂ���y�Ȃ�I�����Ă��������B | Open Audio File you want to use as reference.');
    % % genre_choice_str = {'blues','classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
    % % genre_choice_yourMusic = menu('�y�Ȃ̃W��������I�����Ă��������B | What genre is this music?','blues','classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock');
    % 
    % % ���͑ΏۂƂ���y�Ȃ̃��^�^�O����
    % yourMusicTitle = input('Song Title (with single quote): ');
    % yourMusicArtist = input('Artist (with single quote): ');
    % 
    % % �o���h�p�X�t�B���^�p�Z���N�g�{�b�N�X
    % bandpass_choice_str = {'Melody', 'Rhythm', 'Harmony'};
    % bandpass_choice = menu('�y�Ȃ̂ǂ̕������r�ΏۂƂ������ł����H | Which sections do you want to compare?','�����f�B | Melody','���Y�� | Rhythm', '�n�[���j�[ | Harmony');
    % 
    % % ���͑ΏۂƂ���y�Ȃ�FFT�E�}�g���N�X��
    % [y_yourMusic, yourMusic, bpm_yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic, 4, bandpass_choice);
    % 
    % % ���͑ΏۂƂ���y�Ȃ̃v���b�g
    % figure;
    % subplot(2, 1, 1);
    % plot(y_yourMusic(:, 1));
    % title([fname_yourMusic ' | ' bandpass_choice_str{bandpass_choice}]);
    % xlabel('Time (Seconds)');

    %% -----�T���v�����y�f�B���N�g���̑I���E�擾�E�ϊ��E�R�T�C���ގ��x�v�ʁE�v���b�g-----
    % �T���v�����y�f�B���N�g���̑I��
    % dpath_sampleMusic  =  uigetdir;
    % dpath_sampleMusic = [dpath_sampleMusic '/'];
    bandpass_choice_str_cakewalk = {'vocal', 'drum', 'bass'};
    dpath_sampleMusic = ['/Users/K1/Documents/MATLAB/Audio/AudioFiles/experiment/cakewalk/' bandpass_choice_str_cakewalk{bandpass_choice} '/'];
    sampleMusicDataset = 'Cakewalk';
    % sampleMusicDataset = input('Dataset Name: '); % �f�[�^�Z�b�g������
    D = dir([dpath_sampleMusic '*.wav']); % wav�t�@�C������
    fname_sampleMusic = cell(1, length(D)); % �}��p�Z���z����쐬
    similarity = cell(1, length(D)); % �ގ��x�p�e���|�����Z���z��
    result = cell(length(D), 200); %�@���ʗp�Z���z��, col1-5: ���^���, col6-195: �ގ��x
    wb = waitbar(0,'Please wait...'); % �i�s�󋵂̕\��

    % �T���v�����y�f�B���N�g������wav�t�@�C�����ꂼ��ɂ��āAFFT�E�}�g���N�X���E�ގ��x�v�ʁE�v���b�g
    for k = 1 : length(D)
        % �T���v�����}�g���N�X�̍쐬
        [~,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); %�p�X�A�t�@�C�����A�g���q�̎擾
        fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); %�t�@�C�����Ɗg���q������
        % �}�g���N�X�擾
        [~, matrix_sampleMusic, ~] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic, 4, bandpass_choice);

        % �R�T�C���ގ��x�v�Z
        similarity{k} = calculateCosineSimilarity(yourMusic, matrix_sampleMusic);

        % ���ʗp�Z���z��̃f�[�^���ߍ���
        % col1-5: ���^���, col6-195: �ގ��x
        % Title, Artist, DatasetName, Part, Filename, Sim001, ..., sim195
        result{k, 1} = yourMusicTitle;
        result{k, 2} = yourMusicArtist;
        result{k, 3} = sampleMusicDataset;
        result{k, 4} = bandpass_choice_str{bandpass_choice};
        result{k, 5} = fname_sampleMusic{k};
        for result_index = 1 : length(similarity{k}(1, :))
            result{k, result_index + 5} = similarity{k}(1, result_index); % col6-195: �ގ��x���ߍ���
            % col(last)-col195��0�ɌŒ�B
            if length(similarity{k}(1, :)) + 5 + result_index <= 200
                result{k, length(similarity{k}(1, :)) + 5 + result_index} = 0;
            end
        end

        % �ގ��x�̃v���b�g(1)
        subplot(2, 1,2);
        plot(similarity{k}(1:length(similarity{k}) - 1), '-x')
        xlim([1.0, length(yourMusic(:, 1)) + 1]);
        ylim([0.0, 1.0]);
        hold all;

        waitbar(k / length(D)) % �i�s�󋵂̕\��
    end

    % �ގ��x�̃v���b�g(2)
    title(['Time series variation of similarities | ' fname_yourMusic]);
    xlabel('Time (bars)');
    ylabel('Similarity');
    legend(fname_sampleMusic);
    grid minor;
    hold off;
    close(wb) % �i�s�󋵂̔�\��


    %% -----���ʗp�Z���z��̃e�[�u���������csv�����o��-----
    resultTable = cell2table(result);
    writetable(resultTable,['similarities_' yourMusicTitle '_' bandpass_choice_str{bandpass_choice} '.csv']);

    %% -----�ő�l�̃W���������ʂ�1��ɕ\��-----
    genreOneRow = [];
    for m = 6:200
        max_tmp = 0;
        for l = 1:k
            if result{l,m} >= max_tmp
                max_tmp = result{l,m};
                if max_tmp == 0
                    genreOneRow{1,m-5} = [];
                else
                    genreOneRow{1,m-5} = result{l,5};
                end
            end
        end
    end
    resultTable = cell2table(genreOneRow);
    writetable(resultTable,['genreOneRow_' yourMusicTitle '_' bandpass_choice_str{bandpass_choice} '.csv']);

end

%end