function [nearest_neighbors, all_props, input_patch_feats, mat_all_patch_feats, IDX, all_dists] = patch_nn(input_patch, target_img, num_nn, layer, caffe_dir)
% =========================================================================
% given a patch, or image, "input_patch", returns a set of patch proposals
% from "input_img" that are the nearest neighbors to it in the alexnet
% embedding space.  caffe_dir is the local address of the caffe directory
% to compute neural-network features.
% =========================================================================
%init geodesic object proposals
% =========================================================================
init_gop;
gop_mex( 'setDetector', 'MultiScaleStructuredForest("/home/zimo/Documents/dense_functional_map_matching/external/gop_1.3/data/sf.dat")' );

p = Proposal('max_iou', 1.0,...
    'unary', 10, 2, 'seedUnary()', 'backgroundUnary({0,15})',...
    'unary', 0, 4, 'zeroUnary()', 'backgroundUnary({0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15})' ...
    );
% =========================================================================
os = OverSegmentation(target_img );
props = p.propose( os );
fprintf('%d proposals generated \n', size(props,1));


All_patch_features = cell(size(props,1),1);
parfor i=1:size(props,1)
    mask = props(i,:);
    mask = double(uint8(mask( os.s()+1 )));
    box = mask_to_box(mask);
    xmin = box(1);
    ymin = box(2);
    xmax = box(3);
    ymax = box(4);
    
    mask_image = target_img;
    mask_image(mask == 0) = 0;
    m = mask_image(ymin:ymax, xmin:xmax, :);
    
    
    %segmented_mask = mask_to_segment(mask, target_img);
    %figure; subplot(1,2,1); imshow(m); subplot(1,2,2); imshow(segmented_mask); input( ' ' );
    proposal_features = compute_caffenet_features(m, layer, caffe_dir);
    
    
    All_patch_features{i} = proposal_features';
    fprintf('computed features for patch %d \n', i);
end

% =========================================
%% Find nearest neighbors for the input patch

input_patch_feats = compute_caffenet_features(input_patch, layer, caffe_dir);
input_patch_feats = input_patch_feats';
mat_all_patch_feats = cell2mat(All_patch_features(:));


[IDX, distances] = knnsearch(mat_all_patch_feats, input_patch_feats, 'K', num_nn + 1);
all_dists = pdist2(mat_all_patch_feats, input_patch_feats);

nearest_neighbors = cell(1,num_nn);
for j = 1:num_nn
    mask = props(IDX(j),:);
    m = double(uint8(mask( os.s()+1 ))); 
    nearest_neighbors{j} = m;
end

all_props = cell(1, size(props,1));
for k = 1:size(props,1);
    mask = props(k,:);
    m = double(uint8(mask( os.s()+1 ))); 
    all_props{k} = m;
end
end
