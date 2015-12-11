addpath('./src'); addpath(genpath('./external'));

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
params.imgsize = 64;
params.image_dir_name = image_dir_name;
params.images = images;
params.num_eigenvecs = 64; % number of basis vectors to use
params.useflip = 0; % adds a flipped copy of every image into the network
params.num_basis_vecs = 1; % number of latent basis vectors to use in alternating optimization
params.gbvs_weight = 100; % weight for the graph-based visual saliency correspondences
params.num_nn = 0; % number of nearest-gist neighbors to use in image-graph; if zero, then we initialize the weights to be uniform
params.laplacian_radius = 5; % pixel radius to compute basis
params.correspondences = 'SIFTflow'; % the other option here is 'DSP'.  
%=================================================================


%% run funcflow on the image directory
funcflow_struct = run_funcflow(params);


%% 
All_func_maps_start = funcflow_struct.funcmaps_init;
All_func_maps = funcflow_struct.funcmaps_final; 
All_eig_vecs = funcflow_struct.eigvecs;
All_eig_vals = funcflow_struct.eigvals;
weights = funcflow_struct.weights_final;

rmpath(genpath('./external/dsp-code'));

%% making figures and calculating final IOU scores
segments = compute_segmentation_from_maps(All_func_maps_start, All_eig_vecs, All_eig_vals, weights, 1);
visualize_output_masks(image_dir_name, segments, All_eig_vecs, params.imgsize);
[avg, IOUs] = compute_IOUs(image_dir_name, segments, All_eig_vecs, params.imgsize);
fprintf('avg IOU: %f \n', avg);

