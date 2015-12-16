%% ===================================================================
%% This is a demonstration of the funcflow algorithm for computing
%% consistent segmentations.  If you are interested in the code, hopefully
%% the comments I have added will be sufficient to explain the functions.
%% For further details, please refer to the pdf in the same directory
%% as this demo.  If you have further questions, please contact me
%% at zimoli@uchicago.edu
%%
%% Check the license for redistribution details.
%%
%% Copyright (c) 2015, Zimo Li
%% All rights reserved.
%% ====================================================================
%
%
%
addpath('./src'); 
addpath(genpath('./external'));

%% setting up parameter values
params = struct;
image_dir_name = 'data/iCoseg/icoseg/skate2';
images = dir([image_dir_name '/*.jpg']);
if isempty(images)
    images = dir([image_dir_name '/*.bmp']);
end
if isempty(images)
    images = dir([image_dir_name '/*.JPEG']);
end
if isempty(images)
    images = dir([image_dir_name '/*.png']);
end

%================================================================
params.imgsize = 64; % the imgisze we rescale to when we run the algorithm.  
params.image_dir_name = image_dir_name;
params.images = images;
params.num_eigenvecs = 64; % number of basis vectors to use
params.flip = 0; % adds a flipped copy of every image into the network
params.num_latent_vecs = 1; % number of latent basis vectors to use in alternating optimization.  Should be less than the dimension of the reduced space
params.gbvs_weight = 100; % weight for the graph-based visual saliency correspondences
params.num_nn = 0; % number of nearest-gist neighbors to use in image-graph; if zero, then we initialize the weights to be uniform
params.laplacian_radius = 5; % pixel radius to compute basis
params.correspondence_type = 'SIFTflow'; % the other option here is 'DSP'.  
params.domain = 'pixel'; % either 'pixel' or 'superpixel'.  pixel works better in my experience, but both follow the same principle.
params.num_superpix = 80; % number of superpixels to use if using superpixels.  Should not be greater than sqrt(total number of pixels).
%=================================================================
%% run funcflow on the image directory
funcflow_struct = run_funcflow(params);
% ================================================================
%% making segmentation figures and calculating final IOU scores

rmpath(genpath('./external/dsp-code')); % I use the matlab kmeans; there is a different implementation in dsp which conflicts.
consistent_funcs = compute_consistentfunc_from_maps(funcflow_struct.funcmaps_final, funcflow_struct.weights_final);
[output_masks_final, output_masks_rough, output_consistentfunc] = ... 
    visualize_output_masks(image_dir_name, consistent_funcs, funcflow_struct.eigvecs, params.imgsize, funcflow_struct.superpixels,[1 2 3 4 5]);
[avg, IOUs] = compute_IOUs(image_dir_name, output_masks_final); % final intersection over union score
fprintf('avg IOU: %f \n', avg);

