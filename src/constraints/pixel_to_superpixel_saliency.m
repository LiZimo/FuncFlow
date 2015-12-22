
function superpixel_saliency = pixel_to_superpixel_saliency(pixel_saliency, superpixel_labels)
%% =======================================================================
%% changes pixel saliency map into superpixel saliency map
% Does so by aggregating average pixel saliency in each superpixel
% ========================================================================
%% INPUTS:
% pixel_saliency - (H x W double) saliency map of an image
% superpixel_labels - (H x W double) labels of an image
% ======================================================================
%% OUTPUTS:
%superpixel_saliency - (N x 1 double, N is number of superpixels) an array that gives the object saliency of each suerpixel
%% ==========================================================================
    imgsize = sqrt(length(pixel_saliency));
    pixel_saliency_square = reshape(pixel_saliency, imgsize, imgsize);
    superpixel_labels_resized = imresize(superpixel_labels, [imgsize imgsize], 'nearest');
    regions = unique(superpixel_labels);
    superpixel_saliency = zeros(length(regions),1);
    
    for i = 1:length(regions)
       mask_i = double(logical(superpixel_labels_resized == i));
       superpixel_saliency(i) =  sum(sum(pixel_saliency_square .* mask_i));
    end
   

end