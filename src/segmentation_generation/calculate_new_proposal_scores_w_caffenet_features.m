function [proposal_scores] = calculate_new_proposal_scores_w_caffenet_features(image_dir_name, all_caffenet_features, old_proposals, caffe_dir)
% ======================================================================
% given old proposal masks, generates new proposal masks that are better
% =====================================================================

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


%[all_proposals, all_caffenet_features] = get_proposals_and_features(image_dir_name, caffe_dir, layer);

proposal_scores = cell(length(images), length(images));
for i = 1:length(images)
     feats_img_i_props = cell2mat(all_caffenet_features{i});
    parfor j = 1:length(images)
        img_j = imread([image_dir_name '/' images(j).name]);
        old_mask_j = old_proposals{j};
        box = mask_to_box(old_mask_j);
        
        xmin = box(1);
        ymin = box(2);
        xmax = box(3);
        ymax = box(4);
    
        patch = img_j(ymin:ymax, xmin:xmax, :);
        feats_j_patch = compute_caffenet_features(patch, layer, caffe_dir);
        
        distances_ij = pdist2(feats_img_i_props', feats_j_patch');
        proposal_scores{i, j} = distances_ij;
        fprintf('finished %d \n', j);
    end
end



fprintf('hi');
end

