sigma_orig = zeros(3,3);
mu_orig = zeros(3,1);
num_train_images = 23
num_test_images = 8

%Training ========================================
for img_no = 1:num_train_images
    img = imread(strcat('./train_images/', num2str(img_no), '.jpg'));
    mask = imread(strcat('./train_images/mask', num2str(img_no), '.jpg'));
    mask = mask/255;
    img = img.*mask;
    threshold = 0.15;
    r = img(:,:,1);
    g =img(:,:,2);
    b = img(:,:,3);
    data = [r(:) g(:) b(:)]';
    data = double(data);
    data(:, ~any(data,1)) = [];  
    data = data/255;
    mu = sum(data,2)/ length(data);
    sigma = zeros(3,3);
    for i = 1 : length(data)
    sigma = sigma + (data(:, i) - mu) * (data(:, i) - mu)';
    end
    sigma = sigma / length(data)
    
        mu_orig = mu_orig + mu/num_train_images;
        sigma_orig = sigma_orig + sigma/num_train_images;
   

end

sigma = sigma_orig;
mu = mu_orig;

for img_no = 1:num_test_images
img = imread(strcat('./test_images/', num2str(img_no), '.jpg'));
r = img(:,:,1);
g =img(:,:,2);
b = img(:,:,3);
orig_data = [r(:) g(:) b(:)]';
x = double(orig_data)/255;

arr_temp = zeros(1,length(orig_data));
for i = 1: length(orig_data)
    temp = 0.5*exp(-.5 * (x(:,i) - mu)' * inv(sigma) * (x(:,i) - mu))/(sqrt(2 * pi.^3* det(sigma)));
    if temp < threshold
        arr_temp(1,i) = 0;
    else
        arr_temp(1,i) = 1;
    end
end

scatter3(data(1,:),data(2,:),data(3,:));
hold on
error_ellipse(sigma,mu);
hold off
figure

data_filtered = double(orig_data).* arr_temp;
[rows cols depth] = size(img)
filtered_img = zeros(rows,cols);
for l = 1:cols
    for m = 1:rows
        filtered_img(m,l) = arr_temp((l-1)*rows + m);
    end
end
imwrite(filtered_img,strcat('./results/Single', num2str(img_no), '.jpg'))
end
