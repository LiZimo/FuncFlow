function [correspondences_orig,correspondences_flip] = get_flip_correspondences(im1)
%% ==========================================================
%% Flips an image and then builds ground truth correspondences
%% between the flipped and original
% ===========================
%% INPUTS:
% im1 - (H x W x 3 double) standard rgb image
% ============================
%% OUTPUTS:
% correspondences_orig, correspondences_flip - please refer to function 'get_pixel_correspondences' to understand the output format
%% ===========================================================


imgsize = size(im1,1);
correspondences_orig = zeros(imgsize^2, imgsize^2);
correspondences_flip = zeros(imgsize^2, imgsize^2);
entry = 1;
for i=1:imgsize
    for j=1:imgsize
      img1_indicator = zeros(imgsize);
      img1_indicator(i,j) = 1;
      img1_indicator = reshape(img1_indicator, [], 1);
      
      img2_indicator = zeros(imgsize);
      img2_indicator(i, end - j + 1) = 1;

      img2_indicator = reshape(img2_indicator, [], 1);
      
      correspondences_orig(:,entry) = img1_indicator;
      correspondences_flip(:,entry) = img2_indicator;
      entry = entry+1;
    end
end

end