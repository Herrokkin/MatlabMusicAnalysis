clear all

N = 30;
%���f�[�^�̐���
x1 = [randn(N,1)*2-1,randn(N,1)*0.3-1];
x2 = [randn(N,1)*2+1,randn(N,1)*0.5+3];

%�ϊ��O�f�[�^�̕\��
figure(1)
clf
k = plot(x1(:,1),x1(:,2),'bo',x2(:,1),x2(:,2),'ro');
set(k,'MarkerSize',10)
xlim([-5,5]);
ylim([-5,5]);


%�����U�̌v�Z
m1 = mean(x1); m2 = mean(x2);
sw = N*cov(x1) + N*cov(x2);	 %�N���X�������U�s��
sb = (m2-m1)*(m2-m1).'; %�N���X�ԋ����U�s��i�Q�N���X�̏ꍇ�͂���������j
sigma = sw^-1*sb;	%FISHER

%sigma = cov(x1,x2)	%PCA�̏ꍇ

%�ŗL�l�v�Z
[vec,val] = eig(sigma);

%�ŗL�l���ł��傫�ȌŗL�x�N�g����ϊ��s��ɂ���
[r,c] = find(val == max(val(:)));
w = vec(:,c);

%�e���W��ϊ�
x = zeros(N,2);
for i = 1:N
x(i,1) = x1(i,:) * w;
x(i,2) = x2(i,:) * w;
end

%�ϊ���̃f�[�^��\���By�̒l�� 0 �Ƃ���
figure(3)
clf
k = plot(x(:,1),0,'bo',x(:,2),0,'ro');
set(k,'MarkerSize',10)
xlim([-5,5]);
ylim([-5,5]);