# -*- coding: utf-8 -*-
import os
import wave
import math
import numpy as np
import scipy.signal
import matplotlib.pyplot as plt


# ----------各種関数の定義_ここから----------
# オーディオファイルを1秒ごとの周波数分布にフーリエ変換。返り値に行列と最頻周波数を返す
def audioToMatrix(filename):
    # waveでwav読み込み
    wav_file = wave.open(filename,'rb')
    data = wav_file.readframes(wav_file.getnframes())

    # サンプリングレートの取得
    Fs = wav_file.getframerate()

    # 配列の作成。"/ 2.0 ** 15"は正規化
    y = np.fromstring(data,np.int16) / 2.0 ** 15

    #LR振り分け
    if (wav_file.getnchannels() == 2):
        # 左チャンネル
        left = y[::2]
        # 右チャンネル
        right = y[1::2]

    wav_file.close()

    #LR結合
    y_merge = (left + right) / 2

    N = math.floor(len(y_merge) / Fs)
    result = np.zeros([N, Fs])
    maxFrequency = np.zeros([N, 1])
    index = 0
    for t in range(1, len(y_merge) - Fs + 1, Fs):
        frame = np.array([y_merge[t : t + Fs]])
        fourier = np.fft.fft(frame)
        spectrum = np.abs(fourier)
        result[index,:] = spectrum
        maxFrequency[index, 0] = np.max(spectrum)
        index += 1

    # print "Sampling rate :", Fs
    # print "left : ", left
    # print "right : ", right
    # print "y_merge : ", y_merge
    # print "result : ", result

    #オーディオファイルの最頻周波数の平均
    meanFrequency = np.mean(maxFrequency)
    #可聴域以外の高域(22050-44100Hz)を0に
    result[:, Fs/2:Fs] = 0.0
    #可聴域以外の低域(0-20Hz)を0に
    result[:, 0:20] = 0.0
    return [result, meanFrequency]

#ハイパスフィルタ
def highPassFilter(fouriermatrix, threshold):
    length = len(fouriermatrix)
    result = np.zeros([length, 44100])
    for count in range(0, length):
        #0Hz〜(threshold)までをカット
        fouriermatrix[count, 0:threshold] = 0.0
        result[count,:] = fouriermatrix[count,:]
    return result

#ローパスフィルタ
def lowPassFilter(fouriermatrix, threshold):
    length = len(fouriermatrix)
    result = np.zeros([length, 44100])
    for count in range(0, length):
        #(threshold)〜44100Hz(インデックス上は44099)までをカット
        fouriermatrix[count, threshold:44099] = 0.0
        result[count,:] = fouriermatrix[count,:]
    return result

#バンドパスフィルタ
def bandPassFilter(fouriermatrix, lowThreshold, highThreshold):
    length = len(fouriermatrix)
    result = np.zeros([length, 44100])
    for count in range(0, length):
        #0Hz〜(lowThreshold)までをカット
        fouriermatrix[count, 0:lowThreshold] = 0.0
        #(highThreshold)〜44100Hz(インデックス上は44099)までをカット
        fouriermatrix[count, highThreshold:44099] = 0.0
        result[count,:] = fouriermatrix[count,:]
    return result

#バンドストップフィルタ
def bandStopFilter(fouriermatrix, lowThreshold, highThreshold):
    length = len(fouriermatrix)
    result = np.zeros([length, 44100])
    for count in range(0, length):
        #(lowThreshold)〜(highThreshold)までをカット
        fouriermatrix[count, lowThreshold:highThreshold] = 0.0
        result[count,:] = fouriermatrix[count,:]
    return result

#類似度計算
def calculateSimilarity(yourMusic, srcMusic):
    #それぞれの行数取得
    lenYourMusic = len(yourMusic)
    lenSrcMusic = len(srcMusic)

    #各行ごとに真似したい側ノルムの作成
    normYourMusic = np.zeros([lenYourMusic, 1])
    for countNormYourMusic in range(0, lenYourMusic):
        normYourMusic[countNormYourMusic,0] = np.linalg.norm(yourMusic[countNormYourMusic,:])

    #各行ごとにサンプル側ノルムの作成
    normSrcMusic = np.zeros([lenSrcMusic, 1])
    for countNormSrcMusic in range(0, lenSrcMusic):
        normSrcMusic[countNormSrcMusic,0] = np.linalg.norm(srcMusic[countNormSrcMusic,:])

    #ずらしながらコサイン類似度算出
    similarityTmp = np.zeros([lenSrcMusic, 1, lenYourMusic - lenSrcMusic + 1])
    for i in range(0, lenYourMusic - lenSrcMusic + 1):
        for j in range(0, lenSrcMusic):
            #秒ごとに多次元配列化
            similarityTmp[j,0,i] = (np.dot(yourMusic[i+j-1,:], srcMusic[j,:])) / (normYourMusic[i+j-1,0] * normSrcMusic[j,0])

    similarity = np.zeros([lenYourMusic - lenSrcMusic + 1, 1])
    for k in range(0, lenYourMusic - lenSrcMusic + 1):
        similarity[k,0] = np.sum(similarityTmp[:,0,k]) / lenSrcMusic

    return(similarity)
# ----------各種関数の定義_ここまで----------


if __name__ == "__main__":
    #具体的なオーディオファイルの選択
    #真似したい楽曲
    yourMusic_path = "./audio/youAndMe.wav"
    yourMusic, yourMusic_Freq = audioToMatrix(yourMusic_path)
    yourMusic_row, yourMusic_collum = yourMusic.shape

    #サンプルファイル
    amen_path = "./audio/amen4bars.wav"
    amen, amen_freq = audioToMatrix(amen_path)
    fourbeat_path = "./audio/DHG3_122_Drum_Allin_01_16bit.wav"
    fourbeat, fourbeat_freq = audioToMatrix(fourbeat_path)
    kikokiko_path = "./audio/BedSqueak.wav"
    kikokiko, kikokiko_freq = audioToMatrix(kikokiko_path)
    blueFunk_path = "./audio/BS_90_BlueFunk_1_16bit.wav"
    blueFunk, blueFunk_freq = audioToMatrix(blueFunk_path)

    #サンプル側の最頻を配列化
    sampleMusicArray = np.array([amen_freq, fourbeat_freq, kikokiko_freq, blueFunk_freq])
    #print sampleMusicArray

    #ハイパスとローパスを足し合わせる
    yourMusic_highPass = np.zeros([yourMusic_row, yourMusic_collum, len(sampleMusicArray)])
    yourMusic_lowPass = np.zeros([yourMusic_row, yourMusic_collum, len(sampleMusicArray)])
    yourMusic_highPlusLow = np.zeros([yourMusic_row, yourMusic_collum, len(sampleMusicArray)])

    for passIndex_high in range(0, len(sampleMusicArray)):
        yourMusic_highPass[:, :, passIndex_high] = highPassFilter(yourMusic, sampleMusicArray[passIndex_high] / 64)

    for passIndex_low in range(0, len(sampleMusicArray)):
        yourMusic_lowPass[:, :, passIndex_low] = lowPassFilter(yourMusic, (sampleMusicArray[passIndex_low] * 8).clip(0, 44100))

    yourMusic_highPlusLow = yourMusic_highPass + yourMusic_lowPass
    #print yourMusic_highPass[:, 0:22050]
    #print yourMusic_lowPass[:, 0:22050]
    #print yourMusic_bandPass[:, 0:22050]
    #print yourMusic_bandStop[:, 0:22050]


    audioSimilarity_amen = calculateSimilarity(yourMusic_highPlusLow[:, :, 0], amen)
    audioSimilarity_4beat = calculateSimilarity(yourMusic_highPlusLow[:, :, 1], fourbeat)
    audioSimilarity_kikokiko = calculateSimilarity(yourMusic_highPlusLow[:, :, 2], kikokiko)
    audioSimilarity_blueFunk = calculateSimilarity(yourMusic_highPlusLow[:, :, 3], blueFunk)

    # print(audioSimilarity_amen)
    # print(audioSimilarity_4beat)
    # print(audioSimilarity_kikokiko)

    #プロット
    plt.plot(audioSimilarity_amen, label=os.path.basename(amen_path))
    plt.plot(audioSimilarity_4beat, label=os.path.basename(fourbeat_path))
    plt.plot(audioSimilarity_kikokiko, label=os.path.basename(kikokiko_path))
    plt.plot(audioSimilarity_blueFunk, label=os.path.basename(blueFunk_path))
    plt.legend()
    plt.title(os.path.basename(yourMusic_path))
    plt.xlabel("Seconds")
    plt.ylabel("Similarity")
    plt.show()
