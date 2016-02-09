function funcflow_struct = run_funcflow(params)
% ===============================================
%% Function to run the funcflow algorithm
% ===============================================
%% INPUTS:
% params - (struct) ...
% params.reshaped_imgsize - (int) the imgisze we rescale to when we run the algorithm.  
% params.image_dir_name -(str) image directory name
% params.images - images (struct) directory structure holding images
% params.num_eigenvecs - (int) dimension of reduced space
% params.useflip - (logical) adds a flipped copy of every image into the network if 1
% params.num_basis_vecs - (int) number of latent basis vectors to use in alternating optimization.  Should be less than the dimension of the reduced space
% params.gbvs_weight - (double) weight for the graph-based visual saliency correspondences
% params.num_nn - (int) number of nearest-gist neighbors to use in image-graph; if zero, then we initialize the weights to be uniform
% params.laplacian_radius - (int) pixel radius to compute basis
% params.correspondences - (str) 'SIFTflow' or 'DSP' correspondences.  
% params.domain - (str) 'pixel' or 'superpixel' domain for basis
% params.feat_type - (str) either 'sift', 'conv4', or a double representing a weighted combination of both feature types; for flow-field computation
% params.caffe_dir = '/home/zimo/Documents/caffe-master'; % the caffe directory on local machine if you want to use caffenet features to compute correspondences
% params.nn_feat_type = 'caffenet'; % either 'caffenet' or 'gist' for which features to use when connecting image graph nearest neighbors
% ===============================================
%% OUTPUTS
% funcflow_struct - (struct) ...
% funcflow_struct.funcmaps_init -(N x F x N x F x S x S double, N is #images, F is flip, S is reshaped imgsize), all initial functional maps
% funcflow_struct.funcmaps_final -(N x F x N x F x S x S double, N is #images, F is flip, S is reshaped imgsize), all final functional maps
% funcflow_struct.eigvecs - (N x F cell, N is #images, F is flip) each entry has all the eigenvectors for an image arranged in columns
% funcflow_struct.eigvals - (N x F cell, N is #images, F is flip) each entry has all the eigenvalues for an image along the diagonal of a square matrix.  The values correspond to eigenvector entries
% funcflow_struct.weights_init - (N x F x N x F double , N is #images, F is flip)numerical array giving the initial weight between image i and image j
% funcflow_struct.weights_final - (N x F x N x F double , N is #images, F is flip)numerical array giving the final weight between image i and image j
% funcflow_struct.funcmap_constraints - (N x F x N x F cell, N is #images, F is flip) contains the correspondences between each image-pair projected into reduced space
% funcflow_struct.superpixels - (N x 1 struct) contains superpixel labels for all the images
% funcflow_struct.latent_bases -  (M*N*F x V double, M is number of basisvectors, N is number of images, F is flip (either 0 or 1), V is number oflatent vectors) all latent bases
% funcflow_struct.optical_flow - (struct) contains all the data for the final derived optical flow fields from the functional maps.  See flow_from_functional_map.m for details
%% ===============================================
%% Initializing weights
graph_weights = init_weights(params.image_dir_name, params.flip+1);
if params.num_nn > 0
    graph_weights = init_graph_nn(params.image_dir_name, params.imgsize, params.num_nn, params.flip+1, params.nn_feat_type, params.caffe_dir);
end
initweights = graph_weights; % save initial weights
%===========================================================================
%% Initializing f-maps
 tic;
 fprintf('Computing all image bases \n');
 [All_eig_vecs, All_eig_vals, All_superpixels] = compute_image_basis(params.image_dir_name, params.num_eigenvecs, ... 
     params.imgsize,params.flip+1, params.laplacian_radius, params.num_superpix, params.domain);
 
 fprintf('Computing constraints \n');
 [All_constraints] = compute_funcmap_constraints(params.image_dir_name, params.imgsize,  ...
     params.flip + 1, All_eig_vecs, All_superpixels, graph_weights, params.correspondence_type, params.feat_type, params.caffe_dir);
 
 fprintf('Initializing Functional Maps \n');
 [All_func_maps, Residuals] = initialize_func_maps( All_eig_vals, All_constraints,params.flip+1, params.gbvs_weight, graph_weights);
 

 All_func_maps_start = All_func_maps; % save the funcmap initialization
 Resid_init = Residuals; % save the residual initializaiton
 toc;
% ==========================================================================
 %% Alternating optimization
 fprintf('alternating between Latent Basis and F-map computation \n ');
 for iters = 1:5
     latent_constraint = 1000;
     [latent_bases, big_W] = compute_latent_basis(All_func_maps, graph_weights, params.num_latent_vecs);
     [All_func_maps, Residuals] = update_func_maps(All_eig_vals, All_constraints, latent_bases, ...
         latent_constraint,params.flip+1, Residuals, All_func_maps, params.gbvs_weight, graph_weights);
     graph_weights = weights_from_residuals(Residuals, graph_weights); % updating the weights of the image graph based on Residuals of the functional maps
     fprintf('Finished Iteration %d \n', iters);
 end
 
 % ================================================================
%% Computing pair-wise optical flows from functional maps
% only valid for pixel-basis
optical_flow = flow_from_functional_map(All_func_maps, All_eig_vecs, params.imgsize, params.imgsize);
% ==========================================================================
 %% Save results
funcflow_struct = struct;
funcflow_struct.funcmaps_init = All_func_maps_start;
funcflow_struct.funcmaps_final = All_func_maps;
funcflow_struct.eigvecs = All_eig_vecs;
funcflow_struct.eigvals = All_eig_vals;
funcflow_struct.weights_init = initweights;
funcflow_struct.weights_final = graph_weights;
funcflow_struct.funcmap_constraints = All_constraints;
funcflow_struct.superpixels = All_superpixels;
funcflow_struct.latent_bases = latent_bases;
funcflow_struct.optical_flow = optical_flow;
% ==========================================================================
end
 


