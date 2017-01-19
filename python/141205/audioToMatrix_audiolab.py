# -*- coding: utf-8 -*-
import math
import numpy
from scikits.audiolab import wavread

#ファイル読み込み
filename = 'amen4bars.wav'

#cikits.audiolabでwav読み込み
data, Fs, enc = wavread(filename)

#LR振り分け
if (data.shape[1] == 2):
    left = data[:, 0]
    right = data[:, 1]

#LR結合
merge = (left + right) / 2

N = math.floor(len(data) / Fs)
result = numpy.zeros([N, Fs])
index = 0
for t in range(1, len(merge) - Fs + 1, Fs):
    frame = numpy.array([merge[t : t + Fs]])
    fourier = numpy.fft.fft(frame)
    spectrum = numpy.abs(fourier)
    result[index,:] = spectrum
    index += 1

print "Sampling rate :", Fs
print "left : ", left
print "right : ", right
print "merge : ", merge
print "result : ", result