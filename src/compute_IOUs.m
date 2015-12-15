function [avg, IOUs] = compute_IOUs(image_dir_name, all_masks)
%% =================================
%% Computes Intersection over Union Scores
%===================================
% Self explanatory
%% =================================
gtmasks = dir([image_dir_name '/GroundTruth/*.JPEG']);
if isempty(gtmasks)
    gtmasks = dir([image_dir_name '/GroundTruth/*.bmp']);
end
if isempty(gtmasks)
    gtmasks = dir([image_dir_name '/GroundTruth/*.jpg']);
end
if isempty(gtmasks)
    gtmasks = dir([image_dir_name '/GroundTruth/*.png']);
end


IOUs = zeros(1, length(gtmasks));
for i = 1:length(gtmasks)
    
    gt_seg = imread([image_dir_name '/GroundTruth/', gtmasks(i).name]);
    gt_seg = squeeze(gt_seg(:,:,1));
    final_mask = all_masks{i};
    
    union = logical(final_mask + double(gt_seg));
    intersection = logical(final_mask .* double(gt_seg));
    
    IOUs(i) = sum(intersection(:))/sum(union(:));
end
avg = mean(IOUs);

end