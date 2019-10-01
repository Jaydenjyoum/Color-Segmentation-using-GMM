function cluster =  testGMM(pi, mu , sigma, t, K, img)
[rows cols d] = size(img);
img = double(img);


for i = 1 : rows  % 1:307k  
    for j = 1 : cols
        sum = 0;
        for clus = 1 : length(pi) %each cluster
            prob = 0;
            x = reshape(img(i,j,:), [1, 3]);
            N = exp((-1/2)*(x-mu(clus,:)')'*inv(sigma(:,:, clus))*(x-mu(clus,:)')) / sqrt(det(sigma(:,:,clus))*((2*pi(clus)).^3));
            prob = pi(clus)*N;
            sum = sum + prob;
        end
        sum = sum/K;
        if sum < t 
            img(i,j,:) = zeros(1,1,3);
        end

    end
end
cluster = uint8(img);

end