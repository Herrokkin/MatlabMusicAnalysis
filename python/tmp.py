# -*- coding: utf-8 -*-
import wave
import math
import numpy
import matplotlib.pyplot as plt


# ----------各種関数の定義_ここから----------
#オーディオファイルを1秒ごとの周波数分布にフーリエ変換
def audioToMatrix(filename):
    #waveでwav読み込み
    wav_file = wave.open(filename,'rb')
    data = wav_file.readframes(wav_file.getnframes())

    #サンプリングレートの取得
    Fs = wav_file.getframerate()

    #配列の作成。"/ 2.0 ** 15"は正規化
    y = numpy.fromstring(data,numpy.int16) / 2.0 ** 15

    #LR振り分け
    if (wav_file.getnchannels() == 2):
        # 左チャンネル
        left = y[::2]
        # 右チャンネル
        right = y[1::2]

    wav_file.close()

    #LR結合
    merge = (left + right) / 2

    N = math.floor(len(merge) / Fs)
    result = numpy.zeros([N, Fs])
    maxFrequency = numpy.zeros([N, 1])
    index = 0
    for t in range(1, len(merge) - Fs + 1, Fs):
        frame = numpy.array([merge[t : t + Fs]])
        fourier = numpy.fft.fft(frame)
        spectrum = numpy.abs(fourier)
        result[index,:] = spectrum
        maxFrequency[index, 0] = numpy.max(spectrum)
        index += 1

    # print "Sampling rate :", Fs
    # print "left : ", left
    # print "right : ", right
    # print "merge : ", merge
    # print "result : ", result

    #オーディオファイルの最頻周波数の平均
    meanFrequency = numpy.mean(maxFrequency)
    #可聴域以外の帯域(22050-44100Hz)を0に
    result[:, Fs/2:Fs] = 0.0
    return [result, meanFrequency]



yourMusic, yourMusic_Freq = audioToMatrix('./audio/04 The Mechanism - Original.wav')
amen, amen_freq = audioToMatrix('./audio/amen4bars.wav')
fourbeat, fourbeat_freq = audioToMatrix('./audio/DHG3_122_Drum_Allin_01_16bit.wav')
kikokiko, kikokiko_freq = audioToMatrix('./audio/BedSqueak.wav')

yourMusic_row, yourMusic_collum = yourMusic.shape

sampleMusicArray = numpy.array([amen_freq, fourbeat_freq, kikokiko_freq])

print sampleMusicArray
print yourMusic
print yourMusic_Freq
print yourMusic_row
print yourMusic_collum
print amen