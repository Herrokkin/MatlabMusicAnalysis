# -*- coding: utf-8 -*-
import os
import wave
import wavio
import math
import numpy as np
import scipy.signal
# import matplotlib.pyplot as plt


# ----------各種関数の定義_ここから----------
# オーディオファイルを1秒ごとの周波数分布にフーリエ変換。返り値に行列と最頻周波数を返す
def readAudio(filepath):
    # Read WAVE file
    wf = wave.open(filepath, "rb")
    data = wf.readframes(wf.getnframes())

    # Sampling Rate
    Fs = wf.getframerate()

    # 配列の作成。"/ 2.0 ** 15"は正規化
    y = np.fromstring(data,np.int16) / 2.0 ** (16-1)

    # Stereo to Mono
    if (wf.getnchannels() == 2):
        left = y[::2] # Left Channel
        right = y[1::2] # Right Channel
        y_merge = (left + right) / 2 # Merge L&R
    elif (wf.getnchannels() == 1):
        y_merge = y

    wf.close()

    # # FFT
    # N = math.floor(len(y_merge) / Fs)
    # result = np.zeros([N, Fs])
    # maxFrequency = np.zeros([N, 1])
    # index = 0
    # for t in range(1, len(y_merge) - Fs + 1, Fs):
    #     frame = np.array([y_merge[t : t + Fs]])
    #     fourier = np.fft.fft(frame)
    #     spectrum = np.abs(fourier)
    #     result[index,:] = spectrum
    #     maxFrequency[index, 0] = np.max(spectrum)
    #     index += 1

    # print "Sampling rate :", Fs
    # print "left : ", left
    # print "right : ", right
    # print "y_merge : ", y_merge
    # print "result : ", result
    # return [result, meanFrequency]
    return y_merge, float(Fs)


# -----Pre-emphasis Filter-----
def preEmphasis(signal, p):
    # 係数 (1.0, -p) のFIRフィルタを作成
    return scipy.signal.lfilter([1.0, -p], 1, signal)

# -----Estimate beat start point-----
def searchBeatStartPoint(y, Fs):
    frame_size = 512
    frame_max = int(Fs * 0.5 / frame_size) # Use n(second) for estimation
    for peak_count in range(1, frame_max):
        if sum(y[(peak_count - 1) * frame_size : (peak_count - 1) * frame_size + frame_size]) ** 2 <= sum(y[(peak_count) * frame_size : (peak_count) * frame_size + frame_size]) ** 2 and sum(y[(peak_count) * frame_size : (peak_count) * frame_size + frame_size]) ** 2 >= sum(y[(peak_count + 1) * frame_size : (peak_count + 1) * frame_size + frame_size]) ** 2:
            startPoint = peak_count
    y_startPoint = y[startPoint * frame_size : y.size]
    return y_startPoint

# ----------BEGIN_BPM----------
# http://ism1000ch.hatenablog.com/entry/2014/07/08/164124
# -----信号とbpmのマッチ度を計算-----
def calc_match_bpm(data,Fs,bpm):
    N       = len(data)
    f_bpm   = float(bpm) / 60 # Note: FLOAT
    f_frame = Fs / 512

    phase_array = np.arange(N) * 2 * np.pi * f_bpm / f_frame
    # sin_match   = (1/N) * sum( data * np.sin(phase_array))
    sin_match   = sum( data * np.sin(phase_array)) / N
    # cos_match   = (1/N) * sum( data * np.cos(phase_array))
    cos_match   = sum( data * np.cos(phase_array)) / N
    return np.sqrt(sin_match ** 2 + cos_match ** 2)

# -----各bpmでのマッチ度リストを返す-----
def calc_all_match(data,Fs):
    match_list = []
    bpm_iter   = range(60,300)

    # 各bpmにおいてmatch度を計算する
    for bpm in bpm_iter:
        match = calc_match_bpm(data,Fs,bpm)
        match_list.append(match)

    return match_list

# -----Estimate BPM-----
def searchBPM(y, Fs):
    sample_total = y.size
    ts       = 1 / Fs # サンプリング周期[t]

    # フレームごとの音量データ作成
    # フレームサイズ分，振幅二乗和を計算，
    frame_size = 512
    sample_max = sample_total - (sample_total % frame_size) #余りフレームは切り捨てる
    frame_max  = sample_max / frame_size
    frame_list = np.hsplit(y[:sample_max],frame_max)
    amp_list   = np.array([np.sqrt(sum(x ** 2)) for x in frame_list])

    # 音量の増加量を取得.
    # 負値はゼロにする.
    amp_diff_list = amp_list[1:] - amp_list[:-1]
    # amp_diff_list = np.vectorize(max)(amp_diff_list,0) # np.vectorizeは関数をndarrayの各要素に適用可能にする
    for element in xrange(amp_diff_list.size):
        if amp_diff_list[element] <= 0:
            amp_diff_list[element] = 0


    # bpm推定
    match_list = calc_all_match(amp_diff_list,Fs)      # 各bpmのマッチ度を計算
    most_match = match_list.index(max(match_list))  # マッチ度最大のindexを取得
    # print(most_match+60)                            # bpmに変換
    songBPM = most_match + 60

    # 計算したBPMをreturn
    return songBPM
# ----------END_BPM----------

# ----------BEGIN_Frequency Filtering----------
# http://aidiary.hatenablog.com/entry/20110514/1305377659
# Band-pass Filter

# ----------END_Frequency Filtering----------

#類似度計算
def calculateSimilarity(targetMusic, typicalPhrase):
    #それぞれの行数取得
    lenTargetMusic = len(targetMusic)
    lenTypicalPhrase = len(typicalPhrase)

    #各行ごとに真似したい側ノルムの作成
    normTargetMusic = np.zeros([lenTargetMusic, 1])
    for countNormTargetMusic in range(0, lenTargetMusic):
        normTargetMusic[countNormTargetMusic,0] = np.linalg.norm(targetMusic[countNormTargetMusic,:])

    #各行ごとにサンプル側ノルムの作成
    normTypicalPhrase = np.zeros([lenTypicalPhrase, 1])
    for countNormTypicalPhrase in range(0, lenTypicalPhrase):
        normTypicalPhrase[countNormTypicalPhrase,0] = np.linalg.norm(typicalPhrase[countNormTypicalPhrase,:])

    #ずらしながらコサイン類似度算出
    similarityTmp = np.zeros([lenTypicalPhrase, 1, lenTargetMusic - lenTypicalPhrase + 1])
    for i in range(0, lenTargetMusic - lenTypicalPhrase + 1):
        for j in range(0, lenTypicalPhrase):
            #秒ごとに多次元配列化
            similarityTmp[j,0,i] = (np.dot(targetMusic[i+j-1,:], typicalPhrase[j,:])) / (normTargetMusic[i+j-1,0] * normTypicalPhrase[j,0])

    similarity = np.zeros([lenTargetMusic - lenTypicalPhrase + 1, 1])
    for k in range(0, lenTargetMusic - lenTypicalPhrase + 1):
        similarity[k,0] = np.sum(similarityTmp[:,0,k]) / lenTypicalPhrase

    return(similarity)
# ----------各種関数の定義_ここまで----------


if __name__ == "__main__":
    # ----------BEGIN_Target Music----------
    targetMusic_path = "./audio/NAO-FoolToLove.wav"
    # targetMusic, targetMusic_Freq = readAudio(targetMusic_path)
    # targetMusic_row, targetMusic_collum = targetMusic.shape
    targetMusic_y, targetMusic_Fs = readAudio(targetMusic_path) # Read Audio
    targetMusic_y_preEmphasis = preEmphasis(targetMusic_y, 0.97) # Pre-emphasis filter
    targetMusic_y_startPoint = searchBeatStartPoint(targetMusic_y_preEmphasis, targetMusic_Fs) # Estimate beat start point
    targetMusic_BPM = searchBPM(targetMusic_y_startPoint, targetMusic_Fs) # Estimate BPM

    print "Y: ", targetMusic_y
    print "Fs: ", targetMusic_Fs
    print "BPM: ", targetMusic_BPM


    # ----------END_Target Music----------

    # # ----------BEGIN_Typical Phrase----------
    # #サンプルファイル
    # amen_path = "./audio/amen4bars.wav"
    # amen, amen_freq = readAudio(amen_path)
    # fourbeat_path = "./audio/DHG3_122_Drum_Allin_01_16bit.wav"
    # fourbeat, fourbeat_freq = readAudio(fourbeat_path)
    # kikokiko_path = "./audio/BedSqueak.wav"
    # kikokiko, kikokiko_freq = readAudio(kikokiko_path)
    # blueFunk_path = "./audio/BS_90_BlueFunk_1_16bit.wav"
    # blueFunk, blueFunk_freq = readAudio(blueFunk_path)
    #
    # #サンプル側の最頻を配列化
    # sampleMusicArray = np.array([amen_freq, fourbeat_freq, kikokiko_freq, blueFunk_freq])
    # #print sampleMusicArray
    # # ----------END_Typical Phrase----------
    #
    #
    # audioSimilarity_amen = calculateSimilarity(targetMusic_highPlusLow[:, :, 0], amen)
    # audioSimilarity_4beat = calculateSimilarity(targetMusic_highPlusLow[:, :, 1], fourbeat)
    # audioSimilarity_kikokiko = calculateSimilarity(targetMusic_highPlusLow[:, :, 2], kikokiko)
    # audioSimilarity_blueFunk = calculateSimilarity(targetMusic_highPlusLow[:, :, 3], blueFunk)
    #
    # # print(audioSimilarity_amen)
    # # print(audioSimilarity_4beat)
    # # print(audioSimilarity_kikokiko)
    #
    # #プロット
    # plt.plot(audioSimilarity_amen, label=os.path.basename(amen_path))
    # plt.plot(audioSimilarity_4beat, label=os.path.basename(fourbeat_path))
    # plt.plot(audioSimilarity_kikokiko, label=os.path.basename(kikokiko_path))
    # plt.plot(audioSimilarity_blueFunk, label=os.path.basename(blueFunk_path))
    # plt.legend()
    # plt.title(os.path.basename(targetMusic_path))
    # plt.xlabel("Seconds")
    # plt.ylabel("Similarity")
    # plt.show()
