training = 0   %boolean, 1 = training, 0 = testing
K = 10 %number of gaussians
t = 5e-8 %hyperparameter for test_GMM
num_train_images = 23
num_test_images = 8


warning off;

    %loads images into cell array imgs =================
    imgs = cell(num_train_images,1);
    for x = 1:num_train_images
        img = imread(strcat('./train_images/', num2str(x), '.jpg'));
        mask = imread(strcat('./train_images/mask', num2str(x), '.jpg'));
        
        mask = mask/255; %turn 255s to 1
        img = img.*mask;
        
        r = img(:,:,1);
        g =img(:,:,2);
        b = img(:,:,3);
        flattened = [r(:) g(:) b(:)];
        flattened = double(flattened);
        img = flattened;
        img( ~any(img,2), : ) = [];  %rows
        
        imgs{x} = img;
               
    end
    
    % Initialization ==================================
    init_img = imgs{1};
    % find k means. C is array of mu's
    [idx, mu, sumd, D] = kmeans(init_img, K);
    
    % Initializes all covariance matrices
    num_data_pts = length(init_img)
    
    covar = zeros(3,3,K);
    cluster_counter = zeros(1,K);
    
    for ind = 1:num_data_pts
        k = idx(ind);
        cluster_counter(k) = cluster_counter(k) + 1;
        covar(:,:,k) = covar(:,:,k) + (init_img(ind,:) - mu(k,:))' * (init_img(ind,:) - mu(k,:));
    end
	for ind = 1:K
       covar(:,:,ind) = covar(:,:,ind) ./ cluster_counter(ind);
    end

    pi = ones(K,1)./K;
    
    % Training ========================================
    clus_to_ignore = zeros(K,1);
    for x = 1:num_train_images
        [pi mu covar clus_to_ignore] = trainGMM(K, imgs{x}, pi, mu, covar, clus_to_ignore)
    end
    
%     %%
%     % Plotting
%     
%     img = imread(strcat('./train_images/', num2str(5), '.jpg'));
%     r = img(:,:,1);
%     g =img(:,:,2);
%     b = img(:,:,3);
%     orig_data = [r(:) g(:) b(:)]';
%     x = double(orig_data)/255;
% 
%     scatter3(orig_data(1,:),orig_data(2,:),orig_data(3,:));
%     hold on
%     error_ellipse(covar(:,:,1),mu(1));
%     hold off
    
% Testing ==============================================

    for x = 1:num_test_images
    img = imread(strcat('./test_images/', num2str(x), '.jpg'));
      
   cluster = testGMM(pi, mu , covar, t, K, img);
    plotGMM(img,covar,mu);
    imwrite(cluster,strcat('./results/GMM', num2str(x), '.jpg'))
    end

dist = zeros(1,num_test_images)
for m =1 :num_test_images
    result_imgs = imread(strcat('./results/GMM', num2str(m), '.jpg'));
    figure
    hold on 
    dist(m) = measureDepth(result_imgs)
    imshow(result_imgs)
    text(450 ,400, strcat(num2str(dist(m)), ' cm'),'Color', 'red') 
    hold off
end