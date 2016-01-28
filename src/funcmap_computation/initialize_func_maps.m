function [All_func_maps, Residuals] = initialize_func_maps( All_eig_vals, All_constraints,...
flip, saliency_weight, graph_weights)
%% =============================================================
%% Initialize functional maps between all image pairs using correspondences
% for details on the optimization, please refer to section 3 of the pdf in the uppermost directory level
%===============================================================
%% INPUTS:
% All_eig_vals - (N x F cell, N is #images, F is flip) each entry has all the eigenvalues for an image along the diagonal of a square matrix.  The values correspond to eigenvector entires
% All_constraints - (N x F x N x F cell, N is #images, F is flip) contains the correspondences between each image-pair projected into reduced space
% flip - (int) 1 (no flipped copies) or 2 (flipped copies)
% saliency_weight - (float) the weight assigned to aligning the saliency correspondences derived from 'GBVS' through the fmaps
% graph_weights - (N x F x N x F double, N is #images, F is flip) numerical array giving the weight between image i and image j
% ===============================================================
%% OUTPUTS:
% All_func_maps - (N x F x N x F x S x S double, N is #images, F is flip, S is reshaped imgsize)
% e.g. All_func_maps(i,1,j,2,:,:) is the functional map between the original image i and flipped image j

% Residuals - (N x F x N x F double) contains the value of objective function for each pair of images' functional map computation
%% ===============================================================

num_eigenvecs = size(All_eig_vals{1,1}, 2);
num_images = size(All_eig_vals, 1);
All_func_maps = cell(size(All_eig_vals,1),flip, size(All_eig_vals,1),flip); 
Residuals = zeros(size(All_eig_vals,1),flip, size(All_eig_vals,1),flip);
for z = 1:num_images
    for z_flip = 1:flip
        eig_vals1 = All_eig_vals{z, z_flip};
        for y = 1:num_images
            for y_flip = 1:flip
                if graph_weights(z, z_flip, y,y_flip) == 0
                    if z ==y && z_flip == y_flip
                        All_func_maps{z, z_flip, y, y_flip} = eye(num_eigenvecs);
                    else
                    All_func_maps{z, z_flip, y, y_flip} = zeros(num_eigenvecs); % if no weight, don't update map
                    end
                    continue;
                end
                eig_vals2 = All_eig_vals{y,y_flip};
                % ================================================
                %% Load all constraints for the image pair
                constraints_1 = All_constraints{z, z_flip, y, y_flip,1};
                constraints_2 = All_constraints{z, z_flip, y, y_flip,2};
                constraints_1(:, end) = constraints_1(:, end)*saliency_weight; % multiply the saliency constraint by specified weight
                constraints_2(:, end) = constraints_2(:,end)*saliency_weight;
                % =================================================
                %% Compute Functional Map here
                mu = 1000;    
                num_constraints = size(constraints_1,2);
                weights = eye(num_constraints);
                alphas = eye(num_constraints);
               
                % alphas and weights were used in an earlier version, read
                % the comments for 'unused section' below for details
                [X, residual] = update_X(weights, mu, alphas, constraints_1, constraints_2, eig_vals1, eig_vals2);
               
                
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
    %fprintf('Finished updating all functional maps for image (%d / %d) \n', z, length(images));
end
end