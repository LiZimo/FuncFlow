function weights = init_weights(image_dir_name, flip)
%% =================================================================
%% This initializes weights between all images to be the same, except
%% an image and its flipped version will have a higher weight 
%% because the correspondences there are ground-truth
% ====================================================================
%% INPUTS: 
%image_dir_name - (str) the path of the image directory we are working on
%flip - (int) either 1 (not using flipped images) or 2 (using flipped images)
% ====================================================================
%% OUTPUTS:
% weights - (N x F x N x F double , N is #images, F is flip)numerical array giving the weight between image i and image j
% e.g.
% weights(i, 1, j, 1) is the weight between the original image i and j
% weights(i, 1, j, 2) is the weight between flipped image i and original j
% weights(i, 2, j, 2) is the weight between flipped image i and flipped j
%% ======================================================================

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
weights = zeros(length(images), flip, length(images),flip);
for x = 1:length(images)
    for x_flip = 1:flip
        for p = 1:length(images)
            for p_flip = 1:flip
                
                if x == p && x_flip ~= p_flip
                    weights(x,x_flip,p,p_flip) = 1;
                elseif x==p && x_flip == p_flip
                    weights(x,x_flip,p,p_flip) = 0;
                else
                    weights(x,x_flip,p,p_flip) = 0.2;
                    
                end
            end
        end
    end
end
end