function [bpm_match] = calc_match_bpm(data, Fs ,bpm)
N = length(data);
f_bpm = bpm /60;
f_frame = Fs / 512;

phrase_array = 0:N-1;
phrase_array = phrase_array  * 2 * pi * f_bpm / f_frame;
sin_match = (1/N) * sum( data .* sin(phrase_array));
cos_match = (1/N) * sum( data .* cos(phrase_array));
bpm_match = sqrt(sin_match^2 + cos_match^2);
end