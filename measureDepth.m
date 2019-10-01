function distance = measureDepth(img)
area = zeros(1, 23);
dist = zeros(1,23);
expression = '\d+';
folder_dist = './train_images/dist_images/';
filePattern = fullfile(folder_dist, '*.jpg');
jpgFiles = dir(filePattern);
for k = 1:length(jpgFiles)
%   returns 1x1 cell of matched string needs curly braces to access cell
%   data
    baseFileName = regexp(jpgFiles(k).name,expression,'match');
    dist(k) = str2num(baseFileName{1,1});
end
dist = sort(dist);
for i = 1 :23
    mask = imread(strcat('./train_images/mask', num2str(i), '.jpg'));
    stats = regionprops('table',mask,'Centroid','MajorAxisLength','MinorAxisLength');
    radius = (stats.MajorAxisLength + stats.MinorAxisLength)/4;
    area(i) = pi*(radius(1).^2);
end 
fitobject = fit(area',dist','poly2');

img = im2bw(img,0.1);
img = bwmorph(img,'clean');
stats_inputs = regionprops('table',img,'Centroid','MajorAxisLength','MinorAxisLength');

input_rad = (max(stats_inputs.MajorAxisLength) + max(stats_inputs.MinorAxisLength))/4;
input_area = pi * input_rad^2

distance = feval(fitobject,input_area)

end