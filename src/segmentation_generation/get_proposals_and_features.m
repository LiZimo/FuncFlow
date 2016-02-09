function [all_proposals, all_caffenet_features] ... 
    = get_proposals_and_features(image_dir_name, caffe_dir, layer)
% ====================================================================
%% compute object proposals and the caffenet features for the bounding boxes
%% of those proposals
% ====================================================================
%% INPUTS:
% image_dir_name - (str), name of the image directory
% caffe-dir - (str), location of caffe directory
% layer - (str), the layer name we are extracting features for
% ====================================================================
%% OUTPUTS
% all_proposals - (nested cell), many proposal masks for every image in the image directory
% all_caffenet_Features (nested cell), same structure: features for every proposal for every image in target direc
% ====================================================================


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


all_proposals = cell(1, length(images));
all_caffenet_features = cell(1,length(images));

parfor i = 1:length(images)
    
    init_gop;
    gop_mex( 'setDetector', 'MultiScaleStructuredForest("/home/zimo/Documents/dense_functional_map_matching/external/gop_1.3/data/sf.dat")' );

    p = Proposal('max_iou', 1.0,...
    'unary', 4, 2, 'seedUnary()', 'backgroundUnary({0,15})',...
    'unary', 0, 4, 'zeroUnary()', 'backgroundUnary({0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15})' ...
    );


    img = imread([image_dir_name '/' images(i).name]);
    os = OverSegmentation( img );
    props = p.propose( os );
    prop_masks = cell(1, size(props,1));
    caffenet_feats = cell(1,size(props,1));
    fprintf('starting image %d \n', i);
    for j = 1:size(props,1)
        
        % =====get the mask for the proposal
        mask = props(j,:);
        m = double(uint8(mask( os.s()+1 )));
%         masked_img = img;
%         masked_img(:,:,1) = masked_img(:,:,1) .* uint8(m);
%         masked_img(:,:,2) = masked_img(:,:,2).* uint8(m);
%         masked_img(:,:,3) = masked_img(:,:,3).* uint8(m);
        
        % compute the caffenet fc7 features for this patch
        box = mask_to_box(m);
        xmin = box(1);
        ymin = box(2);
        xmax = box(3);
        ymax = box(4);

        patch = img(ymin:ymax, xmin:xmax, :);
        %segment = masked_img(ymin:ymax, xmin:xmax, :);
        
        patch_feats = compute_caffenet_features(patch, layer, caffe_dir);
        %segment_feats = compute_caffenet_features(segment, layer, caffe_dir);
        caffenet_feats{j} = patch_feats; % ; segment_feats];
        % save the proposal mask
        
        prop_masks{j} = m;
        %fprintf('finished proposal %d \n', j);
    end
    all_proposals{i} = prop_masks;
    all_caffenet_features{i} = caffenet_feats;
end




end
