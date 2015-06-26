function [] = pca(data, base_num)
[N, dim] = size(data);
data_m = mean(data);
for data_mean_count = 1 : N;
    data_new(data_mean_count,:) = data(data_mean_count,:) - data_m;
end
cov_mat_vm = (data_new.' * data_new) / N;
[vm ,d] = eig(cov_mat_vm);

cov_mat = (data_new * data_new.') / N;
l = eig(cov_mat).';
[v ,d] = eig(cov_mat);



end