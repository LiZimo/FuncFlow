function [Y, big_W] = compute_latent_basis(All_X, weights, num_basis_vecs)
% All_X contains functional maps for every pair of images in the network.
% It is 6 dimensional:
% All_X(i, i_flip, j, j_flip:,:) is the functional map from i to j.  If
% i_flip is 1, then it is the original image i.  If i_flip is 2, then it is
% the flipped version of i.  

num_images = size(All_X, 1);
flip = size(All_X,2);
num_eigenvecs = size(All_X,6);
big_W = zeros(flip*num_images*num_eigenvecs);

%weights(1:size(weights,1)+1: size(weights,1)^2) = 0;

assert(isreal(All_X));

for i = 1:num_images
    for i_flip = 1:flip
        for j = 1:num_images
            for j_flip = 1:flip
                
                if i == j && i_flip == j_flip
                    %All_X_blocks = zeros(num_eigenvecs, num_eigenvecs*num_images);
                    XtX = zeros(num_eigenvecs);
                    for z = 1:num_images
                        for z_flip = 1:flip
                        %All_X_blocks(:, (z-1)*num_eigenvecs + 1:z*num_eigenvecs) = sqrt(weights(i,j))*squeeze(All_X(i,z,:,:))';
                        XtX = XtX + weights(i,i_flip,z,z_flip)*(squeeze(All_X(i,i_flip,z,z_flip,:,:))' * squeeze(All_X(i,i_flip,z,z_flip,:,:))) + weights(z, z_flip,i, i_flip)*eye(num_eigenvecs);
                        end
                    end
                    assert(isreal(XtX));
                    %             total_weights = sum(weights,2);
                    %             total_weights_for_i = total_weights(i);
                    %             W_ij = All_X_blocks * All_X_blocks' + total_weights_for_i * eye(num_eigenvecs);
                    W_ij = XtX;
                else
                    W_ij = -weights(j,j_flip,i,i_flip) * squeeze(All_X(j,j_flip,i,i_flip,:,:)) -weights(i,i_flip,j,j_flip) * squeeze(All_X(i,i_flip,j, j_flip,:,:))';
                    
                    
                end
                
                big_W((flip*(i-1) + i_flip - 1)*num_eigenvecs + 1:(flip*(i-1) + i_flip)*num_eigenvecs, (flip*(j-1) + j_flip - 1)*num_eigenvecs + 1:(flip*(j-1) + j_flip )*num_eigenvecs) = W_ij;
            end
            
        end
    end
end

symtest = (big_W + big_W')/2 - big_W;
assert(isreal(big_W));
assert(norm(symtest) < 0.001);

symmed_w = (big_W + big_W')/2;

opts.issym = 1;
opts.isreal = 1;
[Y, ~] = eigs(symmed_w, num_basis_vecs, 1e-10, opts);
assert(isreal(Y));

end
