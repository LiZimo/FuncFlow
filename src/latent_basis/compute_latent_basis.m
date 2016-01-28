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
% Y - (M*N*F x V double, M is number of basis vectors, N is number of images, F is flip (either 0 or 1), V is number of latent vectors) latent basis
% e.g. To find the corresponding latent basis for image i and flip f, we simply look at Y(  M *[(i - 1)*f + f-1] : M * [(i - 1) * f + f], :)

% big_W - block matrix corresponding to big_W in report.  See section 3 and 5 therein
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
                            XtX = XtX + weights(i,i_flip,z,z_flip)*(All_X{i,i_flip,z,z_flip}'... 
                                * All_X{i,i_flip,z,z_flip}) + weights(z, z_flip,i, i_flip)*eye(num_eigenvecs);
                        end
                    end
                    assert(isreal(XtX));
                    W_ij = XtX;
                else
                    W_ij = -weights(j,j_flip,i,i_flip) * All_X{j,j_flip,i,i_flip} -weights(i,i_flip,j,j_flip) * All_X{i,i_flip,j, j_flip}';  
                end
                big_W((flip*(i-1) + i_flip - 1)*num_eigenvecs + 1:(flip*(i-1) + i_flip)*num_eigenvecs, (flip*(j-1) + j_flip - 1) ... 
                    *num_eigenvecs + 1:(flip*(j-1) + j_flip )*num_eigenvecs) = W_ij;
            end            
        end
    end
end

symtest = (big_W + big_W')/2 - big_W;
assert(isreal(big_W));
%assert(norm(symtest) < 0.001);

symmed_w = (big_W + big_W')/2;

opts.issym = 1;
opts.isreal = 1;
[Y, ~] = eigs(symmed_w, num_latent_vecs, 1e-5, opts);
assert(isreal(Y));

end
