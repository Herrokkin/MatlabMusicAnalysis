%function [] = calculateAudioSimilarity()

%% ----------Main part of IFS & Band-pass filter calculation----------
% -----Functions-----
% 1)Make matrix of audio data (FFT & Band-pass filter)
% [y, result, bpm] = audioToMatrix(fname, dpath, beats, bandpassFilterRange)
%
% 2)Calculate Cosine Similarity
% similarity{} = calculateCosineSimilarity(yourMusic, sampleMusic, maxDimension)

%% -----"Music piece to be analyzed"-----
% Get a file of "Music piece to be analyzed"
% [fname_yourMusic, dpath_yourMusic]  =  uigetfile({'*.wav;*.mp3;*.au','Audio File(*.wav,*.mp3,*.au)'},'Open Audio File you want to use as reference.');

% Input meta data of "Music piece to be analyzed"
% yourMusicTitle = input('Song Title (with single quote): ');
% yourMusicArtist = input('Artist (with single quote): ');


%% Define the genre to calculate
genreName = input('Genre Name (with single quote): ');
bandpass_choice_str = {'Melody', 'Rhythm', 'Harmony', 'No Filter'};
bandpass_choice = menu('Which sections do you want to compare?','Melody','Rhythm', 'Harmony', 'No Filter');

wb_filecount = waitbar(0,'FILE COUNT'); % Progress bar
for filecount = 0 : 9
  waitbar(filecount + 1 / 10) % Progress bar
  %% -----"Music piece to be analyzed"-----
  dpath_yourMusic = ['/Users/K1/Documents/MATLAB/Audio/AudioFiles/genres/' genreName '/'];
  if filecount < 10
      fname_yourMusic = [genreName '.0000' int2str(filecount) '.wav'];
  else
      fname_yourMusic = [genreName '.000' int2str(filecount) '.wav'];
  end

  % Meta information for "Music piece to be analyzed"
  if filecount < 10
      yourMusicTitle = [genreName '.0000' int2str(filecount)];
  else
      yourMusicTitle = [genreName '.000' int2str(filecount)];
  end
  yourMusicArtist = 'genres';

  % Select sections for bandpass filter
  % bandpass_choice_str = {'Melody', 'Rhythm', 'Harmony', 'None'};
  % bandpass_choice = menu('Which sections do you want to compare?','Melody','Rhythm', 'Harmony', 'No Filter');

  % FFT & Make matrix of "Music piece to be analyzed"
  [y_yourMusic, yourMusic, bpm_yourMusic, Fs_yourMusic] = audioToMatrix(fname_yourMusic, dpath_yourMusic, 4, bandpass_choice);

  % % Plot "Music piece to be analyzed" in time-series
  % figure;
  % subplot(2, 1, 1);
  % plot(y_yourMusic(:, 1));
  % title([fname_yourMusic ' | ' bandpass_choice_str{bandpass_choice}]);
  % xlabel('Time (Seconds)');

  %% -----"Typical phrases"-----
  % Get a folder that contains "Typical phrases"
  % dpath_sampleMusic  =  uigetdir;
  % dpath_sampleMusic = [dpath_sampleMusic '/'];
  % sampleMusicDataset = input('Dataset Name: '); % Input dataset name
  dpath_sampleMusic = '/Users/K1/Documents/MATLAB/Audio/AudioFiles/experiment/cakewalk/drum_hiphop_jazz_pop_rock/';
  sampleMusicDataset = 'Cakewalk';
  D = dir([dpath_sampleMusic '*.wav']); % Search wave files
  fname_sampleMusic = cell(1, length(D)); % Cell array for legend in plot
  similarity = cell(1, length(D)); % Cell array for similarity (temporary)
  result = cell(length(D), 200); % Cell array for resut, col1-5: Meta data, col6-195: Time-series similarities
  wb = waitbar(0,'Please wait...'); % Progress bar

  % FFT > Make matrix > Calculate similarities (EACH "Typical phrase")
  for k = 1 : length(D)
      % Open a file of "Typical phrase"
      [~,name_sampleMusic,ext_sampleMusic] = fileparts(D(k).name); % Path & Filename
      fname_sampleMusic{k} = strcat(name_sampleMusic, ext_sampleMusic); % Integrate Path & Filename
      % FFT & Make matrix of "Typical phrase"
      [~, matrix_sampleMusic, ~, Fs_sampleMusic] = audioToMatrix(fname_sampleMusic{k}, dpath_sampleMusic, 4, bandpass_choice);

      % Calculate Cosine similarities
      similarity{k} = calculateCosineSimilarity(yourMusic, matrix_sampleMusic, Fs_yourMusic / 2);

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

      % % Plot(1)
      % subplot(2, 1,2);
      % plot(similarity{k}(1:length(similarity{k}) - 1), '-x')
      % xlim([1.0, length(yourMusic(:, 1)) + (length(yourMusic(:, 1)) / 50)]);
      % ylim([0.0, 1.0]);
      % hold all;

      waitbar(k / length(D)) % Progress bar
  end

  % % Plot(2)
  % title(['Time series variation of similarities (IFS & Band-pass filter) | ' fname_yourMusic]);
  % xlabel('Time (Bars)');
  % ylabel('Similarity');
  % legend(fname_sampleMusic);
  % grid minor;
  % hold off;
  close(wb) % Close progress bar


  %% -----Make a result table & Write csv-----
  resultTable = cell2table(result);
  writetable(resultTable,['similarities_IFSbandpass_' yourMusicTitle '_' bandpass_choice_str{bandpass_choice} '.csv']);

  %% -----Display max/min of genre similarity in 1 row-----
  genreOneRow = [];
  genreOneRowForTfIdf = [];
  for m = 6:200
      max_tmp = 0;
      min_tmp = 1.0;
      for l = 1:k
          if result{l,m} >= max_tmp
              max_tmp = result{l,m};
              if max_tmp == 0
                  genreOneRow{1,m-5} = [];
                  genreOneRowForTfIdf{1,m-5} = [];
              else
                  genreOneRow{1,m-5} = result{l,5};
                  genreOneRowForTfIdf{1,m-5} = result{l,5};
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
  resultTableForTfIdf = cell2table(genreOneRowForTfIdf);
  writetable(resultTableForTfIdf,['genreOneRowForTfIdf_MFCCbandpass_' yourMusicTitle '_' bandpass_choice_str{bandpass_choice} '.txt']);
end % for loop of filecount
close(wb_filecount) % Close progress bar

%end
