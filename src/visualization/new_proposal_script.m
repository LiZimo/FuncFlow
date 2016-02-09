
warning('off', 'all');
addpath(genpath('/home/zimo/Documents/funcflow/src'));
addpath(genpath('./external'));

image_dir_name = '/home/zimo/Documents/funcflow/data/msrc/cow';
images = dir([image_dir_name '/*.JPEG']);
if isempty(images)
    images = dir([image_dir_name '/*.bmp']);
end
if isempty(images)
    images = dir([image_dir_name '/*.jpg']);
end
if isempty(images)
    images = dir([image_dir_name '/*.png']);
end


layer = 'fc7';
caffe_dir = '/home/zimo/Documents/caffe-master';
num_nn = 5;

proposal_scores =  calculate_new_proposal_scores_w_caffenet_features(image_dir_name, all_caffenet_features, output_masks_final, caffe_dir);
%%
new_proposals = generate_new_proposals(proposal_scores, all_proposals);

for i = 1:length(new_proposals)
    img = imread([image_dir_name '/' images(i).name]);
    segment = mask_to_segment(new_proposals{i}, img);
    figure; 
    imshow(segment);
    input(' ');
    
end