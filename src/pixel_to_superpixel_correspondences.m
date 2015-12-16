function [superpixel_C, superpixel_D] = pixel_to_superpixel_correspondences(D, superpixel_labels_start, superpixel_labels_end)
%% ================================================================================
%% Converts pixel correspondences to superpixel correspondences
% this function is a bit confusing.  Essentially, we are moving pixel
% correspondences to the resolution of superpixels by aggregating them.
% The format is very similar to 'get_pixel_correspondences.m'.  Read that
% if interested.
% ================================================================================
%% INPUTS:
% D - the pixel correspondences for the second image, arranged as indicator functions in columns.
% For more info on the format, refer to the function 'get_pixel_correspondences.m'
% 
% superpixel_labels_start - (H1 x W1 double, height and width of image 1) the superpixel labelling of the first image in the image-pair correspondnece
% superpixels_labels_end - (H2 x W2 double, height and width of image 2) the superipxel labelling of second image

% ================================================================================
%% OUTPUTS:
% superpixel_C - (N1 x N1 double, N1 number of superpixels for image 1) correspondences for first image's superpixels; columns correspond to the columns in superpixel_D
% superpixel_D - (N2 x N2 double, N2 number of superpixels for image 2) correspondences for second image's superpixels
%% ================================================================================================================================================================
    % first, we resize all the superpixels to be the imgsize we used in 
    % obtaining the sift flow correspondences
    imgsize = sqrt(size(D,1));
    superpixel_labels_start_resized = imresize(superpixel_labels_start, [imgsize imgsize], 'nearest');
    superpixel_labels_end_resized = imresize(superpixel_labels_end, [imgsize imgsize], 'nearest');
    num_superpix_start = length(unique(superpixel_labels_start));
    num_superpix_end = length(unique(superpixel_labels_end));

    superpixel_C = zeros(num_superpix_start, num_superpix_start);
    superpixel_D = zeros(num_superpix_end, num_superpix_start);
    %% ===================================================================
    % in the forloop, we are iterating through all the superpixels in the
    % first image, and see which superpixels in the second image they are
    % sent to through sift flow.  The corresponding superpixels in image 2
    % can be as many superpixels as are targeted, weighted by the number of
    % pixels sent therein
    for j = 1:num_superpix_start
        superpixel_indicator_start = double(logical(superpixel_labels_start_resized == j));

        num_pix_j = sum(superpixel_indicator_start(:));
        corresponding_indices = find(superpixel_indicator_start');
        sift_correspondence_indicators = D(:, corresponding_indices); % find corresponding pixels on the other side of the superpixel we are iterating on
        pixel_saliency= sum(sift_correspondence_indicators, 2); % gather all those pixels up into a saliency map
        superpixel_saliency_end = pixel_to_superpixel_saliency(pixel_saliency, superpixel_labels_end_resized); % change pixel saliency map to superpixel saliency map
        
        superpixel_indicator_start = zeros(1,num_superpix_start);
        superpixel_indicator_start(j) = num_pix_j;
        superpixel_C(:,j) = superpixel_indicator_start;
        superpixel_D(:,j) = superpixel_saliency_end;
    end
    %% =================================================================
end

