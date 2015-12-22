function final_weights = init_graph_gist_nn(image_dir_name, imgsize, num_nn, flip)
%% ===================================================
%% computes weights in image graph based on gist distance.  
% See <http://people.csail.mit.edu/torralba/code/spatialenvelope/> for more
% info
% Graph connects each image with its num_nn nearest neighbors in gist space
%
% The weight is given by exp( -gist_distance/(sqrt(2)*sigma))
% where sigma is the median of all gist_distances
% ===================================================
%% INPUTS:
% image_dir_name - (str) path of image directory to use
% imgsize - (int) reshape size to perfrom gist on
% flip - either 1 (not using flipped images) or 2 (using flipped images)
% num_nn - number of nearest neighbors to use for the image graph
%=====================================================
%% OUTPUTS
% weights - (N x F x N x F double, N is #images, F is flip) numerical array giving the weight between image i and image j

% e.g.
% weights(i, 1, j, 1) is the weight between the original image i and j
% weights(i, 1, j, 2) is the weight between flipped image i and original j
% weights(i, 2, j, 2) is the weight between flipped image i and flipped j
%% =====================================================
%% load images
images = dir([image_dir_name '/*.JPEG']);
if isempty(images)
    images = dir([image_dir_name '/*.bmp']);
end
if isempty(images)
    images = dir([image_dir_name '/*.jpg']);
end
% =======================================
%% set gist params
param.imageSize = imgsize; % it works also with non-square images
param.orientationsPerScale = [8 8 8 8];
param.numberBlocks = 4;
param.fc_prefilt = 4;
% =======================================
%% Compute and store all gist_descriptors
all_gists = cell(length(images),flip);

for k = 1:flip
for i = 1:length(images)
    img = imread([image_dir_name '/' images(i).name]);
    if k == 2
        img = flip_image(img);
    end
    
    [gist, param] = LMgist(img, '', param);
    all_gists{i,k} = gist;
end
end
% =========================================
%% Find gist nearest neighbors for each image
mat_all_gists_original = cell2mat(all_gists(:,1));
mat_all_gists_flip = cell2mat(all_gists(:,flip));


[IDX_orig, Distances_orig] = knnsearch(mat_all_gists_original,mat_all_gists_original, 'K', num_nn + 1);
[IDX_flip, Distances_flip] = knnsearch(mat_all_gists_flip, mat_all_gists_original, 'K', num_nn + 1);

All_dists = [Distances_orig(:); Distances_flip(:)];
All_dists(All_dists == 0) = [];
sigma = median(All_dists); % sigma is given by the median of all gist-distances
% =============================================
%% Set the weights based on distance
weights_orig = zeros(length(images));
for n = 1:length(images)
    for m = 1:num_nn - 1
        neighbor = IDX_orig(n, m + 1);
        weights_orig(n,neighbor) = exp( -norm(all_gists{n,1} - all_gists{neighbor,1})/(sqrt(2)*sigma));
    end
end

weights_flip = zeros(length(images));
for n = 1:length(images)
    for m = 1:num_nn
        neighbor = IDX_flip(n, m + 1);
        weights_flip(n,neighbor) = exp( -norm(all_gists{n,flip} - all_gists{neighbor,flip})/(sqrt(2)*sigma));
    end
end
% ============================================

final_weights = zeros(length(images), flip, length(images), flip);
final_weights(:,1,:,1) = weights_orig;
final_weights(:,flip,:,flip) = weights_orig;
final_weights(:,flip,:,1) = weights_flip;
final_weights(:,1,:,flip) = weights_flip;

end 
