#coding:utf-8

import MeCab
import math

# single quote & comma separated
sentence = ['', '', '', '', '', '', '', '', '', '']

num = len(sentence)
result = []

for i in range(num):         #文章の分解
    tagger = MeCab.Tagger()
    result.append(tagger.parse(sentence[i]))


wordCount = {}
allCount = {}
sub_tfstore = {}
tfcounter = {}
tfstore = {}
sub_idf = {}
idfstore = {}
merge_idf = {}
tfidf = {}
merge_tfidf = {}
wordList = []
sum = 0

for i in range(num):
    wordList.append(result[i].split()[:-1:2])    #wordListに分解された単語要素のみを格納

for i in range(num):
    for word in wordList[i]:
        allCount[i] = wordCount.setdefault(word,0)
        wordCount[word]+=1
    allCount[i] = wordCount       #単語出現回数を文章ごとに格納。tfの分母に相当
    wordCount = {}

for i in range(num):                             # tfの分母を計算
    for word in allCount[i]:
        sum = sum + allCount[i][word]
    sub_tfstore[i] = sum
    sum = 0

for i in range(num):                     # tf値を計算し文章ごとに辞書に格納
    for word in allCount[i]:
        tfcounter[word] = allCount[i][word]*1.0/sub_tfstore[i]
    tfstore[i] = tfcounter
    tfcounter = {}

for i in range(num):
    for word in wordList[i]:
        wordCount.setdefault(word,0)
    for word in allCount[i]:
        wordCount[word] += 1
    sub_idf = wordCount                  #ある単語の文章あたりの出現回数を辞書に格納

for i in range(num):
    for word in allCount[i]:
        idfstore[word] = math.log(1.0*math.fabs(num)/math.fabs(sub_idf[word]))
    merge_idf[i] = idfstore
    idfstore = {}

for i in range(num):           #tfidfの計算
    for word in allCount[i]:
        tfidf[word] = tfstore[i][word]*merge_idf[i][word]
    merge_tfidf[i] = tfidf
    tfidf = {}

for i in range(num):          #降順に出力する
    for word,count in sorted(merge_tfidf[i].items(),key = lambda x:x[1],reverse = True):
        if count > 0.00:
            print 'text%d: %-16s %2.3f' % (i+1,word,count)
