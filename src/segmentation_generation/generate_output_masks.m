function [output_masks_mrf, output_masks_unary, output_masks_rough, All_IOUS, output_consistentfunc] = ... 
    generate_output_masks(image_dir_name, consistent_funcs, All_eig_vecs, imgsize, superpixels, proposals, caffenet_features)
%% ===============================================================
%% Computes final mask and creates figures
% for more information on how the rough and final masks are generated,
% please refer to section 6 of the attached pdf and 
% <http://vladlen.info/publications/geodesic-object-proposals/>
% ================================================================
%% INPUTS:
% image_dir_name - (str) image directory name
% consistent_funcs - (N x F x M double, N is #images, F is flip, M is#basisvecs)the most consistently aligned function between all images, in reduced basis
% All_eig_vecs - (N x F cell, N is #images, F is flip) each entry has all the eigenvectors for an image arranged in columns
% imgsize - (int) imgsize we rehaped to in optimization
% superpixels - (struct) holds the superpixels labels for all images
% which - (L x 1 int) which images to visualize final segments for.  if 0,no visualization made
% ================================================================
%% OUTPUTS:
% output_masks_final - (N x 1 cell) each entry contains final generated binary mask after 'GOP' refinement
% output_masks_rough - (N x 1 cell) each entry contains binary mask after rough kmeans thresholding of final consistent func
% output_consistentfunc - (N x 1 cell) entry entry contains a heatmap representing the most consistently aligned function across all images
%% ===================================================================
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

output_consistentfunc = cell(1, length(images));
output_masks_unary = cell(1, length(images));
output_masks_rough = cell(1, length(images));

All_IOUS = cell(1, length(images));
for i = 1:length(images)

    image = imread([image_dir_name '/' images(i).name]);
    consistent_func = squeeze(consistent_funcs(i,1,:));
    consistent_func_im = All_eig_vecs{i,1} * consistent_func; % represent consistent_func into the proper basis  
    
    % ==========================================
    %% If using superpixels, we must color the superpixels back in before postprocessing
    if iscell(superpixels)
        labels = superpixels{i,1};
        regions = length(unique(labels));
        superpixel_consistent_func_im = zeros(size(image,1), size(image,2));
        for e = 1:regions
            superpixel_consistent_func_im(labels == e) = consistent_func_im(e);
        end
        consistent_func_im = superpixel_consistent_func_im;
    end
    % ===========================================
    
    consistent_func_im = remove_bg(consistent_func_im); % eliminate the background using kmeans on the heatmap values
    
    if ~iscell(superpixels)
        % if we are in the pixel basis, we must reshape and rescale
        % everything back to the original size
        consistent_func_im = reshape(consistent_func_im, [imgsize imgsize]);
        consistent_func_im = double(imresize(consistent_func_im, [size(image,1) size(image,2)], 'bilinear'));
    end
    
    output_consistentfunc{i} = consistent_func_im;
    %[final_mask1, IOUs1] = refine_consistentfunc_with_gop(consistent_func_im, image); % refined using 'gop'.  See section 6 of pdf for details.
    [mask_unary, IOUs] = refine_consistentfunc_with_proposals(consistent_func_im, image, proposals{i});
    All_IOUS{i} = IOUs;
    output_masks_unary{i} = mask_unary; % final mask using gop
    output_masks_rough{i} = logical(consistent_func_im); % rough mask after thresholding the consistent function
    
end

output_masks_mrf = obtain_best_segment_via_mrf(proposals, caffenet_features, All_IOUS, 0.5, 0.1);
% ======================================================
end