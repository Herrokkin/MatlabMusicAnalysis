%function [] = calculateAudioSimilarity()

%% ----------Main part of MFCC & Band-pass filter calculation----------
% -----Functions-----
% 1)Make matrix of audio data (FFT & Band-pass filter)
% [y, result, bpm] = audioToMatrix(fname, dpath, beats, bandpassFilterRange)
%
% 2)Calculate Cosine Similarity
% similarity{} = calculateCosineSimilarity(yourMusic, sampleMusic, maxDimension)
%
% 3)Make MFCC matrix of audio data
% [AdftSum] = melFilterbankAnalysis(Fs, Adft, melFilterNumOfDimensions)

%% -----"Music piece to be analyzed"-----
% Get a file of "Music piece to be analyzed"
[fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference.');

% Input meta data of "Music piece to be analyzed"
yourMusicTitle = input('Song Title (with single quote): ');
yourMusicArtist = input('Artist (with single quote): ');

% Select sections for bandpass filter
bandpass_choice_str = {'Melody', 'Rhythm', 'Harmony', 'No Filter'};
bandpass_choice = menu('Which sections do you want to compare?','Melody','Rhythm', 'Harmony', 'No Filter');

% FFT & Make matrix of "Music piece to be analyzed"
[y_yourMusic, yourMusic, bpm_yourMusic, Fs_yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic, 4, bandpass_choice);

% Plot "Music piece to be analyzed" in time-series
figure;
subplot(2, 1, 1);
plot(y_yourMusic(:, 1));
title(['Waveform | ' yourMusicArtist ' - ' yourMusicTitle ' (' bandpass_choice_str{bandpass_choice} ')']);
xlabel('Time (Bars)');
ylabel('Amplitude');
ax = gca;
x_tick = [];
x_tick_label = [];
for x_tick_index = 0 : floor( (length(yourMusic(:,1))) / 10 )
    x_tick_new = (60 / bpm_yourMusic * 4) * Fs_yourMusic * x_tick_index * 10;
    x_tick = [x_tick x_tick_new];    
    x_tick_label = [x_tick_label x_tick_index *10];
end
set(ax,'XTick',x_tick);
set(ax,'XTickLabel',x_tick_label);
grid on;


% Make MFCC matrix of "Music piece to be analyzed"
melFilterNum = 20; % Number of dimension (MFCC)
cpst = 12; % ?????????????????????????????????????????????????????????????????????
yourMusic_mel = zeros(length(yourMusic(:,1)), melFilterNum);
wb = waitbar(0,'Loading Audio Data...'); % Progress bar
for i = 1 : length(yourMusic(:,1))
    % yourMusic_mel(i,:) = melFilterbankAnalysis(Fs_yourMusic, yourMusic(i,:), melFilterNum);
    [yourMusic_adftSum(i,:), yourMusic_mel(i,:)] = melFilterbankAnalysis(length(yourMusic(i,:)), yourMusic(i,:), melFilterNum);
    waitbar((i / length(yourMusic(:,1)))) % Progress bar
end
yourMusic_mel = yourMusic_mel(:, 1:cpst);
close(wb) % Close progress bar

%% -----"Typical phrases"-----
% Get a folder that contains "Typical phrases"
dpath_sampleMusic  =  uigetdir;
dpath_sampleMusic = [dpath_sampleMusic '/'];
sampleMusicDataset = input('Dataset Name: '); % Input dataset name
D = dir([dpath_sampleMusic '*.wav']); % Search wave files
fname_sampleMusic = cell(1, length(D)); % Cell array for legend in plot
similarity = cell(1, length(D)); % Cell array for similarity (temporary)
result = cell(length(D), 200); % Cell array for resut, col1-5: Meta data, col6-195: Time-series similarities
wb = waitbar(0,'Please wait...'); % Progress bar

% FFT > Make matrix > MFCC > Calculate similarities (EACH "Typical phrase")
for k = 1 : length(D)
    % Open a file of "Typical phrase"
    [~,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); % Path & Filename
    fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); % Integrate Path & Filename
    % FFT & Make matrix of "Typical phrase"
    [~, matrix_sampleMusic, ~, Fs_sampleMusic] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic, 4, bandpass_choice);

    % Make MFCC matrix of "Typical phrase"
    matrix_sampleMusic_mel = zeros(length(matrix_sampleMusic(:,1)), melFilterNum);
    for j = 1 : length(matrix_sampleMusic(:,1))
        % matrix_sampleMusic_mel(j,:) = melFilterbankAnalysis(Fs_sampleMusic, matrix_sampleMusic(j,:), melFilterNum);
        [matrix_sampleMusic_adftSum(j,:), matrix_sampleMusic_mel(j,:)] = melFilterbankAnalysis(length(matrix_sampleMusic(j,:)), matrix_sampleMusic(j,:), melFilterNum);
    end
    matrix_sampleMusic_mel = matrix_sampleMusic_mel(:, 1:cpst);

    % Calculate Cosine similarities
    similarity{k} = calculateCosineSimilarity(yourMusic_mel, matrix_sampleMusic_mel, cpst);

    % Make cell array for result
    % col1-5: Meta data, col6-195: Time-series similarities
    % Title, Artist, DatasetName, Part, Filename, Sim001, ..., sim195
    result{k, 1} = yourMusicTitle;
    result{k, 2} = yourMusicArtist;
    result{k, 3} = sampleMusicDataset;
    result{k, 4} = bandpass_choice_str{bandpass_choice};
    result{k, 5} = fname_sampleMusic{k};
    for result_index = 1 : length(similarity{k}(1, :))
        result{k, result_index + 5} = similarity{k}(1, result_index); % col6-195: Time-series similarities
        % Set 0 in col(last)-col195
        if length(similarity{k}(1, :)) + 5 + result_index <= 200
            result{k, length(similarity{k}(1, :)) + 5 + result_index} = 0;
        end
    end

    % Plot(1)
    subplot(2, 1, 2);
    plot(similarity{k}(1:length(similarity{k}) - 1), '-x')
    xlim([1.0, length(yourMusic(:, 1)) + (length(yourMusic(:, 1)) / 50)]);
    ylim([0.5, 1.0]);
    hold all;

    waitbar(k / length(D)) % Progress bar
end

% Plot(2)
title(['Time series variation of similarities | ' yourMusicArtist ' - ' yourMusicTitle ' (' bandpass_choice_str{bandpass_choice} ')']);
xlabel('Time (Bars)');
ylabel('Similarity');
legend(fname_sampleMusic);
grid minor;
hold off;
close(wb) % Close progress bar


%% -----Make a result table & Write csv-----
resultTable = cell2table(result);
writetable(resultTable,['similarities_MFCCbandpass_' yourMusicTitle '_' bandpass_choice_str{bandpass_choice} '.csv']);

%% -----Display max/min of genre similarity in 1 row-----
genreOneRow = [];
for m = 6:200
    max_tmp = 0;
    min_tmp = 1.0;
    for l = 1:k
        if result{l,m} >= max_tmp
            max_tmp = result{l,m};
            if max_tmp == 0
                genreOneRow{1,m-5} = [];
            else
                genreOneRow{1,m-5} = result{l,5};
            end
        end
        if result{l,m} <= min_tmp
            min_tmp = result{l,m};
            if min_tmp == 1.0 & min_tmp ~= 0.0
                genreOneRow{2,m-5} = [];
            else
                genreOneRow{2,m-5} = result{l,5};
            end
        end
    end
end
resultTable = cell2table(genreOneRow);
writetable(resultTable,['genreOneRow_MFCCbandpass_' yourMusicTitle '_' bandpass_choice_str{bandpass_choice} '.csv']);

%end
