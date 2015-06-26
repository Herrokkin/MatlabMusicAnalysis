clear all

N = 30;
%元データの生成
x1 = [randn(N,1)*2-1,randn(N,1)*0.3-1];
x2 = [randn(N,1)*2+1,randn(N,1)*0.5+3];

%変換前データの表示
figure(1)
clf
k = plot(x1(:,1),x1(:,2),'bo',x2(:,1),x2(:,2),'ro');
set(k,'MarkerSize',10)
xlim([-5,5]);
ylim([-5,5]);


%共分散の計算
m1 = mean(x1); m2 = mean(x2);
sw = N*cov(x1) + N*cov(x2);	 %クラス内共分散行列
sb = (m2-m1)*(m2-m1).'; %クラス間共分散行列（２クラスの場合はこう書ける）
sigma = sw^-1*sb;	%FISHER

%sigma = cov(x1,x2)	%PCAの場合

%固有値計算
[vec,val] = eig(sigma);

%固有値が最も大きな固有ベクトルを変換行列にする
[r,c] = find(val == max(val(:)));
w = vec(:,c);

%各座標を変換
x = zeros(N,2);
for i = 1:N
x(i,1) = x1(i,:) * w;
x(i,2) = x2(i,:) * w;
end

%変換後のデータを表示。yの値は 0 とする
figure(3)
clf
k = plot(x(:,1),0,'bo',x(:,2),0,'ro');
set(k,'MarkerSize',10)
xlim([-5,5]);
ylim([-5,5]);