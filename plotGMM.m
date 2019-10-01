function plotGMM(img, covar, mu)
    r = img(:,:,1);
    g =img(:,:,2);
    b = img(:,:,3);
    flattened = [r(:) g(:) b(:)];
    data = double(flattened);
    figure
    hold on
    scatter3(data(:,1),data(:,2),data(:,3));
    temp = size(covar);
    for i=1:temp(1,3)
    error_ellipse(covar(:,:,i),mu(i,:));
    end
    hold off
    
end
