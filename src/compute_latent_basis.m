function [Y, big_W] = compute_latent_basis(All_X, weights, num_latent_vecs)
%% ===========================================================
%% Compute latent basis given funcitonal maps
% for more information please refer to section 3 and section 5
% of the pdf attached at top level directory
% ============================================================
%% INPUTS:
% All_X - (N x F x N x F x S x S double, N is #images, F is flip, S is reshaped imgsize), all functional maps
% weights - (N x F x N x F double , N is #images, F is flip)numerical array giving the weight between image i and image j
% num_latent_vecs - (int) number of latent vectors to compute
% ============================================================
%% OUTPUTS:
% Y - latent basis
% big_W - block matrix corresponding to big_W in report
%% ============================================================

num_images = size(All_X, 1);
flip = size(All_X,2);
num_eigenvecs = size(All_X,6);
big_W = zeros(flip*num_images*num_eigenvecs);
assert(isreal(All_X));

for i = 1:num_images
    for i_flip = 1:flip
        for j = 1:num_images
            for j_flip = 1:flip
                if i == j && i_flip == j_flip
                    XtX = zeros(num_eigenvecs);
                    for z = 1:num_images
                        for z_flip = 1:flip
                            XtX = XtX + weights(i,i_flip,z,z_flip)*(squeeze(All_X(i,i_flip,z,z_flip,:,:))'... 
                                * squeeze(All_X(i,i_flip,z,z_flip,:,:))) + weights(z, z_flip,i, i_flip)*eye(num_eigenvecs);
                        end
                    end
                    assert(isreal(XtX));
                    W_ij = XtX;
                else
                    W_ij = -weights(j,j_flip,i,i_flip) * squeeze(All_X(j,j_flip,i,i_flip,:,:)) -weights(i,i_flip,j,j_flip) * squeeze(All_X(i,i_flip,j, j_flip,:,:))';  
                end
                big_W((flip*(i-1) + i_flip - 1)*num_eigenvecs + 1:(flip*(i-1) + i_flip)*num_eigenvecs, (flip*(j-1) + j_flip - 1) ... 
                    *num_eigenvecs + 1:(flip*(j-1) + j_flip )*num_eigenvecs) = W_ij;
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
[Y, ~] = eigs(symmed_w, num_latent_vecs, 1e-10, opts);
assert(isreal(Y));

end
