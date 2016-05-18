function [ outputNum, outputAnearB ] = getNearNum( a, b )
%GETNEARNUM 指定したベクトルの中で、指定した値に一番近い値の番号を出力する
%【使用例】
%  a = [1 4 6 8 10 12 14];
%  b = 5.2;
%  [outputNum, outputAnearB] = getNearNum(a,b)
%    outputNum =
         3
%    outputAnearB =
%        6
% ※ なお、同じ距離の数値が複数あったら、両方出力します。

maxNum = min(find(a>b));
minNum = max(find(a<b));
% a(maxNum) か、a(minNum) のどちらかが b に一番近い値

if ( a(maxNum) - b ) > ( b - a(minNum) )
    outputNum = minNum;
    outputAnearB = a(minNum);
elseif ( a(maxNum) - b ) < ( b - a(minNum) )
    outputNum = maxNum;
    outputAnearB = a(maxNum);
else
    % 最も近い値が複数あったとき
    outputNum = [minNum maxNum];
    outputAnearB = [a(minNum) a(maxNum)];
end

end

