function consistent_funcs = compute_consistentfunc_from_maps(All_X, weights)
%% ===========================================================
%% Computes most consistent functions
% for more information please refer to section 3 and section 5
% of the pdf attached at top level directory

% this function is essentially the same as "compute_latent_basis"
% I made this a new function for clarity of reading, since I didn't
% want to add a bunch of options in the other function
% ============================================================
%% INPUTS:
% All_X - (N x F x N x F x S x S double, N is #images, F is flip, S is reshaped imgsize), all functional maps
% weights - (N x F x N x F double , N is #images, F is flip)numerical array giving the weight between image i and image j
% ============================================================
%% OUTPUTS:
% consistent_funcs - (N x F x M double, N is #images, F is flip, M is#basisvecs)the most consistently aligned function between all images, in reduced basis

% e.g., consisten_funcs(i, 1, :) are the coefficients in basis 'i' of the consistent function, for the unflipped original image i
%% ============================================================

num_images = size(All_X, 1);
flip = size(All_X,2);
num_eigenvecs = size(All_X{1,1,2,1},2);
big_W = zeros(flip*num_images*num_eigenvecs);

for i = 1:num_images
    for i_flip = 1:flip
        for j = 1:num_images
            for j_flip = 1:flip
                
                if i == j && i_flip == j_flip
                    XtX = zeros(num_eigenvecs);
                    for z = 1:num_images
                        for z_flip = 1:flip
                        XtX = XtX + weights(i,i_flip,z,z_flip)*All_X{i,i_flip,z,z_flip}' * All_X{i,i_flip,z,z_flip} + weights(z, z_flip,i, i_flip)*eye(num_eigenvecs);
                        end
                    end
                    assert(isreal(XtX));   
                    W_ij = XtX; 
                else
                    W_ij = -weights(j,j_flip,i,i_flip) * All_X{j,j_flip,i,i_flip} -weights(i,i_flip,j,j_flip) * All_X{i,i_flip,j, j_flip}';
                end                
                big_W((flip*(i-1) + i_flip - 1)*num_eigenvecs + 1:(flip*(i-1) + i_flip)*num_eigenvecs, (flip*(j-1) + j_flip - 1)*num_eigenvecs + 1:(flip*(j-1) + j_flip )*num_eigenvecs) = W_ij;
            end
            
        end
    end
end
symtest = (big_W + big_W')/2 - big_W;
assert(isreal(big_W));
%assert(norm(symtest) < 0.01);

symmed_w = (big_W + big_W')/2;
[Y, eig_vals] = eigs(symmed_w, 10, 1e-20);
assert(isreal(Y));

all_consistentfuncs = Y(:,end);

all_consistentfuncs = reshape(all_consistentfuncs,num_eigenvecs*flip, []);
consistent_funcs = zeros(num_images, flip, num_eigenvecs);

consistent_funcs(:,1,:) = all_consistentfuncs(1:num_eigenvecs, :)';
try consistent_funcs(:,2,:) = all_consistentfuncs(num_eigenvecs+1:end, :)';
catch 
end
