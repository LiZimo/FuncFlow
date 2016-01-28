function weights = weights_from_residuals(Residuals, prev_weights)
%% ==========================================
%% Compute weights from the residuals of the functional maps
% images and their flips are given a weight of 1
% all other images are given a weight of exp(-residual/median(all_residuals)^2)
% ===========================================
%% INPUTS
% Residuals - (N x F x N x F double) contains the value of objective function for each pair of images' functional map computation
% ===========================================
%% OUTPUTS
% weights - (N x F x N x F double, N is #images, F is flip) numerical array giving the weight between image i and image j
%% ============================================

num_ims = size(Residuals,1);
flip = size(Residuals,2);
weights = exp(-Residuals/(median(Residuals(Residuals ~= 0))^2));

for k = 1:num_ims
    weights(k,1,k,1) = 0;
end

if flip == 2
    for j = 1:num_ims
        weights(j,1,j,2) = 1;
        weights(j,2,j,1) = 1;
        weights(k,2,k,2) = 0;
    end
end

weights(prev_weights == 0) = 0;

end