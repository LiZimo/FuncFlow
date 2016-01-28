function [output_masks_final, output_masks_rough, output_consistentfunc] = visualize_output_masks(image_dir_name, consistent_funcs, All_eig_vecs, imgsize, superpixels, which)
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
output_masks_final = cell(1, length(images));
output_masks_rough = cell(1, length(images));
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
    final_mask = refine_consistentfunc_with_gop(consistent_func_im, image); % refined using 'gop'.  See section 6 of pdf for details.
    output_masks_final{i} = final_mask; % final mask using gop
    output_masks_rough{i} = logical(consistent_func_im); % rough mask after thresholding the consistent function
      
end

if ~isempty(which)
    figure;
end

% =======================================================
%% generate figure here if so desired

    for j = 1:length(which)
        image = imread([image_dir_name '/' images(which(j)).name]);
        segmented_image_final = mask_to_segment(output_masks_final{which(j)}, image);
        segmented_image_rough = mask_to_segment(output_masks_rough{which(j)}, image); 
        subplot(3, length(which), 0*length(which) + j); imshow(output_consistentfunc{which(j)}); colormap('hot'); title('Generated Function', 'FontSize', 7);
        subplot(3, length(which), 1*length(which) + j) ; imshow(segmented_image_rough); title('Rough Thresholding', 'FontSize', 7);
        subplot(3, length(which), 2*length(which) + j); imshow(segmented_image_final); title('Final Output', 'FontSize', 7); 
    end
% ======================================================
end