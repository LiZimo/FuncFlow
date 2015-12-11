function funcflow_struct = run_funcflow(params)

imgsize = params.imgsize;
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
initweights = weights;
%% Initializing f-maps
 tic;
 fprintf('Computing all image bases \n');
 [All_eig_vecs, All_eig_vals, All_superpixels] = compute_image_basis(image_dir_name, num_eigenvecs,imgsize,flip, radius, 0, 'pixel'); % superpixel option to come later
 
 fprintf('Computing constraints \n');
 [All_constraints] = compute_funcmap_constraints(image_dir_name, imgsize,flip, All_eig_vecs, All_superpixels, correspondence_type);
 
 fprintf('Initializing Functional Maps \n');
 [All_func_maps, Residuals] = initialize_func_maps( All_eig_vals, All_constraints,flip, gbvs_weight, weights);
 

 All_func_maps_start = All_func_maps;
 Resid_init = Residuals;
 toc;
 
 
 %% Alternating optimization
 fprintf('alternating between Latent Basis and F-map computation \n ');
 for iters = 1:5
     latent_constraint = 1000;
     [latent_bases, big_W] = compute_latent_basis(All_func_maps, weights, num_basis_vecs);
     [All_func_maps, Residuals] = update_func_maps(All_eig_vals, All_constraints, latent_bases, latent_constraint,flip, Residuals, All_func_maps, gbvs_weight, weights);
     weights = weights_from_residuals(Residuals);
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
 


