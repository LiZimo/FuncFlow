function funcflow_struct = run_funcflow(params)
% ===============================================
%% Function to run the funcflow algorithm
% ===============================================
%% INPUTS:
% params - (struct) ...
% params.reshaped_imgsize = (int) the imgisze we rescale to when we run the algorithm.  
% params.image_dir_name (str) image directory name
% params.images = images (struct) directory structure holding images
% params.num_eigenvecs = (int) dimension of reduced space
% params.useflip = (logical) adds a flipped copy of every image into the network if 1
% params.num_basis_vecs = (int) number of latent basis vectors to use in alternating optimization.  Should be less than the dimension of the reduced space
% params.gbvs_weight = (double) weight for the graph-based visual saliency correspondences
% params.num_nn = (int) number of nearest-gist neighbors to use in image-graph; if zero, then we initialize the weights to be uniform
% params.laplacian_radius = (int) pixel radius to compute basis
% params.correspondences = (str) 'SIFTflow' or 'DSP' correspondences.  
% ===============================================
%% OUTPUTS
% funcflow_struct - (struct) ...
% funcflow_struct.funcmaps_init -(N x F x N x F x S x S double, N is #images, F is flip, S is reshaped imgsize), all initial functional maps
% funcflow_struct.funcmaps_final -(N x F x N x F x S x S double, N is #images, F is flip, S is reshaped imgsize), all final functional maps
% funcflow_struct.eigvecs = (N x F cell, N is #images, F is flip) each entry has all the eigenvectors for an image arranged in columns
% funcflow_struct.eigvals = (N x F cell, N is #images, F is flip) each entry has all the eigenvalues for an image along the diagonal of a square matrix.  The values correspond to eigenvector entries
% funcflow_struct.weights_init = (N x F x N x F double , N is #images, F is flip)numerical array giving the initial weight between image i and image j
% funcflow_struct.weights_final = (N x F x N x F double , N is #images, F is flip)numerical array giving the final weight between image i and image j
% funcflow_struct.funcmap_constraints = (N x F x N x F cell, N is #images, F is flip) contains the correspondences between each image-pair projected into reduced space
%% ===============================================

imgsize = params.reshaped_imgsize;
image_dir_name = params.image_dir_name;
num_eigenvecs = params.num_eigenvecs;
flip = params.useflip + 1;
num_basis_vecs = params.num_basis_vecs;
gbvs_weight = params.gbvs_weight;
num_nn = params.num_nn;
radius = params.laplacian_radius;
correspondence_type = params.correspondences;
 
weights = init_weights(image_dir_name, flip);
if params.num_nn > 0
    weights = init_graph_gist_nn(image_dir_name, imgsize, num_nn, flip); 
end
initweights = weights; % save initial weights
%===========================================================================
%% Initializing f-maps
 tic;
 fprintf('Computing all image bases \n');
 [All_eig_vecs, All_eig_vals, All_superpixels] = compute_image_basis(image_dir_name, num_eigenvecs,imgsize,flip, radius, 0, 'pixel'); % superpixel option to come later
 
 fprintf('Computing constraints \n');
 [All_constraints] = compute_funcmap_constraints(image_dir_name, imgsize,flip, All_eig_vecs, All_superpixels, correspondence_type);
 
 fprintf('Initializing Functional Maps \n');
 [All_func_maps, Residuals] = initialize_func_maps( All_eig_vals, All_constraints,flip, gbvs_weight, weights);
 

 All_func_maps_start = All_func_maps; % save the funcmap initialization
 Resid_init = Residuals; % save the residual initializaiton
 toc;
% ==========================================================================
 
 %% Alternating optimization
 fprintf('alternating between Latent Basis and F-map computation \n ');
 for iters = 1:5
     latent_constraint = 1000;
     [latent_bases, big_W] = compute_latent_basis(All_func_maps, weights, num_basis_vecs);
     [All_func_maps, Residuals] = update_func_maps(All_eig_vals, All_constraints, latent_bases, latent_constraint,flip, Residuals, All_func_maps, gbvs_weight, weights);
     weights = weights_from_residuals(Residuals); % updating the weights of the image graph based on Residuals of the functional maps
     fprintf('Finished Iteration %d \n', iters);
 end
 
funcflow_struct = struct;
funcflow_struct.funcmaps_init = All_func_maps_start;
funcflow_struct.funcmaps_final = All_func_maps;
funcflow_struct.eigvecs = All_eig_vecs;
funcflow_struct.eigvals = All_eig_vals;
funcflow_struct.weights_init = initweights;
funcflow_struct.weights_final = weights;
funcflow_struct.funcmap_constraints = All_constraints;
end
 


