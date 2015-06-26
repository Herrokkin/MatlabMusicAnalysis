function [ meldata ] = mellog( inputdata )
%MELLOG メル対数変換
%参考  http://www.asj.gr.jp/qanda/answer/35.html

meldata = (1000 / log(2)) * log(inputdata / 1000 + 1);
end