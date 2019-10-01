function [pi mu covar clus_to_ignore] = trainGMM(K, img, initial_pi, initial_mu, initial_covar, clus_to_ignore)  
    warning off;
    epsilon = 5;
    max_iters = 20;

    flattened = img;
    pi = initial_pi;
    mu = initial_mu;
    covar = initial_covar;
    
    j = 1;
    len = length(flattened);
    prev_mu = mu;
    a = zeros(len , K);
    it = 1;
    mu_delta = epsilon + 1; %make sure does stop on first iteration
    
    while it <= max_iters && mu_delta > epsilon
        % E-step
        for i = 1 : len % pixels
            for clus = 1 : K %each cluster
                x = flattened(i);
                N = exp((-1/2)*(x-mu(clus,:)')'*inv(covar(:,:, clus))*(x-mu(clus,:)')) / sqrt(det(covar(:,:,clus))*((2*pi(clus)).^3));
                prob = pi(clus)*N;
                a(i,clus) = prob;
            end      
        end
        
        for i = 1 : len % pixels 
            summ = 0;
            for clus = 1 : K %each cluster
                summ = summ + a(i,clus);
            end 

            for clus = 1 : K %each cluster
                a(i,clus) = a(i,clus)/summ;
            end 
        end
        
        
        % M-step
        a
        for j = 1 : K %each cluster
            if clus_to_ignore(j) == 0            
                mu_j = zeros(1,3);
                sum_a = 0;

                for i = 1 : len % pixels
                    x = flattened(i,:);
                    sum_a = sum_a + a(i, j);
                    mu_j = a(i,j) * x + mu_j;
                end
                if sum_a < 1e-15
                    clus_to_ignore(j) = 1;
                    continue;
                end
                mu(j,:) = mu_j / sum_a;
                pi(j) = sum_a / len;
            end
        end
        for j = 1 : K %each cluster
            if clus_to_ignore(j) == 0
                cov_j = zeros(3,3);
                sum_a = 0;

                for i = 1 : len % pixels
                    x = flattened(i, :);
                    sum_a = sum_a + a(i, j);
                    cov_j = a(i,j) * (x - mu(j, :))' * (x - mu(j, :)) + cov_j;
                end
                if sum_a < 1e-15
                    clus_to_ignore(j) = 1;
                    continue;
                end
                covar(:,:,j) = cov_j / sum_a;
            end
        end
          
        it = it+1;
        mu
        mu_delta = sum(sum(abs(mu - prev_mu)))
        
    end
      
end