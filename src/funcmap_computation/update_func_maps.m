function [All_func_maps, Residuals] = update_func_maps( All_eig_vals, All_constraints, latent_bases, latent_weight,...
flip, prev_resids, prev_func_maps, saliency_weight, graph_weights)
%% =============================================================
%% Update functional maps between all image pairs using correspondences
% for details on the optimization, please refer to section 3 and section 5 of the pdf in the uppermost directory level
%===============================================================
%% INPUTS:
% All_eig_vals - (N x F cell, N is #images, F is flip) each entry has all the eigenvalues for an image along the diagonal of a square matrix.  The values correspond to eigenvector entires
% All_constraints - (N x F x N x F cell, N is #images, F is flip) contains the correspondences between each image-pair projected into reduced space
% flip - (int) 1 (no flipped copies) or 2 (flipped copies)
% saliency_weight - (float) the weight assigned to aligning the saliency correspondences derived from 'GBVS' through the fmaps
% graph_weights - (N x F x N x F double, N is #images, F is flip) numerical array giving the weight between image i and image j
% prev_resids - (N x F x N x F double) contains the value of objective function for each pair of images' functional map computation from previous iteration
% prev_func_maps - (N x F x N x F x S x S double, N is #images, F is flip, S is reshaped imgsize) all functional maps between each pair from previous iteration
% saliency_ weight - (double) weight for the graph-based visual saliency correspondences;
% latent_bases - (M*N*F x V double, M is number of basis vectors, N is number of images, F is flip (either 0 or 1), V is number of latent vectors) latent basis
% e.g. To find the corresponding latent basis for image i and flip f, we simply look at latent_bases(  M *[(i - 1)*f + f-1] : M * [(i - 1) * f + f], :)

% latent_weight - importance assigned to aligning latent bases with funcmaps
% ===============================================================
%% OUTPUTS:
% All_func_maps - (N x F x N x F x S x S double, N is #images, F is flip, S is reshaped imgsize)
% e.g. All_func_maps(i,1,j,2,:,:) is the functional map between the original image i and flipped image j

% Residuals - (N x F x N x F double) contains the value of objective function for each pair of images' functional map computation
%% ===============================================================

num_eigenvecs = size(All_eig_vals{1,1}, 2);
num_images = size(All_eig_vals, 1);
All_func_maps = prev_func_maps;
Residuals = prev_resids;
for z = 1:num_images
    for z_flip = 1:flip
        eig_vals1 = All_eig_vals{z,z_flip};
        for y = 1:num_images
            for y_flip = 1:flip       
                if graph_weights(z, z_flip, y,y_flip) == 0
                    continue; % if no weight, don't update map
                end
                eig_vals2 = All_eig_vals{y,y_flip};
                % =======================================================================
                %% Load all constraints for both images
                basis_constraints1 = squeeze(latent_bases((flip*(z-1) + z_flip - 1)*num_eigenvecs + 1:(flip*(z-1) + z_flip)*num_eigenvecs, :));
                basis_constraints2 = squeeze(latent_bases((flip*(y-1) + y_flip - 1)*num_eigenvecs + 1:(flip*(y-1) + y_flip)*num_eigenvecs, :));
                constraints_1 = All_constraints{z, z_flip, y, y_flip,1};
                constraints_2 = All_constraints{z, z_flip, y, y_flip,2};
                constraints_1(:, end) = constraints_1(:, end)*saliency_weight;
                constraints_2(:, end) = constraints_2(:,end)*saliency_weight;               
                % =========================================================================
                %% add latent bases into optimization
                total_constraints_1 = [constraints_1    latent_weight*basis_constraints1];
                total_constraints_2 = [constraints_2    latent_weight*basis_constraints2];
                % ==========================================================================
                %% Compute Functional Map here
                mu = 1000;    
                num_constraints = size(total_constraints_1,2);
                weights = eye(num_constraints);
                alphas = eye(num_constraints);
               
                % alphas and weights were used in an earlier version, read
                % the comments for 'unused section' below for details
                [X, residual] = update_X(weights, mu, alphas, total_constraints_1, total_constraints_2, eig_vals1, eig_vals2);
               
                
                % =======================================================================
                %% unused section; this optimizes each functional map to reweight the correspondences based on residuals. Takes
                %%  a lot longer and doesn't really do much
                %=====================================================================
                %lambda = 10;
                %sig = 1;
                %weights = update_weights(X, sig, img1_projected_indicators, img2_projected_indicators, alphas);
                % alphas = update_alpha(weights, lambda, X, img1_projected_indicators, img2_projected_indicators);
                %===========================================================================          
                All_func_maps{z,z_flip,y,y_flip} = X;
                Residuals(z,z_flip,y,y_flip) = residual;
          
            end
        end
    end

end
end