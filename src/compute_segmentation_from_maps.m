function segments = compute_segmentation_from_maps(All_X, All_eig_vecs, All_eig_vals, weights, regul)
num_images = size(All_X, 1);
flip = size(All_X,2);
%flip = 1;
num_eigenvecs = size(All_X,6);
big_W = zeros(flip*num_images*num_eigenvecs);

weights(1:size(weights,1)+1: size(weights,1)^2) = 0;

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
                   
                    
                    BtB = All_eig_vecs{j,j_flip}'  * All_eig_vecs{j,j_flip};
                    W_ij = regul*XtX; % + BtB*squeeze(All_eig_vals(j,j_flip,:,:));
                else
                    W_ij = -weights(j,j_flip,i,i_flip) * squeeze(All_X(j,j_flip,i,i_flip,:,:)) -weights(i,i_flip,j,j_flip) * squeeze(All_X(i,i_flip,j, j_flip,:,:))';
                    W_ij = regul*W_ij;
                    
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
[Y, eig_vals] = eigs(symmed_w, 10, 1e-20);
assert(isreal(Y));

all_segs = Y(:,end);

all_segs = reshape(all_segs,num_eigenvecs*flip, []);
segments = zeros(num_images, flip, num_eigenvecs);

segments(:,1,:) = all_segs(1:num_eigenvecs, :)';
try segments(:,2,:) = all_segs(num_eigenvecs+1:end, :)';
catch 
end
