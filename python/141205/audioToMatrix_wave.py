# -*- coding: utf-8 -*-
import math
import numpy
import wave
import matplotlib.pyplot as plt

#ファイル読み込み
filename = './audio/theMechanism.wav'

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
index = 0
for t in range(1, len(merge) - Fs + 1, Fs):
    frame = numpy.array([merge[t : t + Fs]])
    fourier = numpy.fft.fft(frame)
    spectrum = numpy.abs(fourier)
    result[index,:] = spectrum
    index += 1

result[:,Fs/2:Fs] = 0
print "Sampling rate :", Fs
print "left : ", left
print "right : ", right
print "merge : ", merge
print "result : ", result

#スペクトログラムをプロット
# pxx, freq, bins, t = plt.specgram(merge,Fs = Fs)
# plt.xlabel("time [second]")
# plt.ylabel("frequency [Hz]")
# plt.show()



#n秒の周波数をプロット
plt.plot(result[0, 0:Fs])
plt.plot(result[len(result) * 1 / 4, 0:Fs])
plt.plot(result[len(result) * 3 / 4, 0:Fs])
plt.xscale('log')
plt.xlabel("frequency [Hz]")
plt.ylabel("Level")
plt.show()