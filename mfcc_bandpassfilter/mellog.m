function [ meldata ] = mellog( inputdata )
%MELLOG ƒƒ‹‘Î”•ÏŠ·
%Ql  http://www.asj.gr.jp/qanda/answer/35.html

meldata = (1000 / log(2)) * log(inputdata / 1000 + 1);
end