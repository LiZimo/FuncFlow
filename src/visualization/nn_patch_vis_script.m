addpath(genpath('/home/zimo/Documents/funcflow/src'));

image_dir_name = '/home/zimo/Documents/funcflow/data/msrc/cow';
images = dir([image_dir_name '/*.jpg']);
if isempty(images)
    images = dir([image_dir_name '/*.bmp']);
end
if isempty(images)
    images = dir([image_dir_name '/*.JPEG']);
end
if isempty(images)
    images = dir([image_dir_name '/*.png']);
end

layer = 'fc7';
caffe_dir = '/home/zimo/Documents/caffe-master';
num_nn = 5;

image_id = randi([1 length(images)]);
target_id = randi([1 length(images)]);

input_img = imread([image_dir_name '/' images(image_id).name]);
target_img = imread([image_dir_name '/' images(target_id).name]);
mask = output_masks_final{image_id};
box = mask_to_box(mask);
input_patch = input_img(box(2):box(4), box(1):box(3), :);
nearest_neighbors = patch_nn(input_patch, target_img, num_nn, layer, caffe_dir);

%% 
figure;
subplot(2, num_nn, 1); imshow(input_patch);
subplot(2, num_nn, 2); imshow(mask);
subplot(2, num_nn, 3); imshow(target_img);
for i = 1:num_nn
    subplot(2, num_nn, i + num_nn); imshow(nearest_neighbors{i});
end
    
    
    