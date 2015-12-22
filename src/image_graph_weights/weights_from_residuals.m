function weights = weights_from_residuals(Residuals)
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
weights = exp(-Residuals/(median(Residuals(:))^2));
for k = 1:num_ims
    for flips = 1:flip
        weights(k,flips,k,flips) = 0;
        weights(k,flips,k,flips) = 0;
        weights(k,flips,k,mod(flips,2) + 1) = 1;
        weights(k,mod(flips,2) + 1, k, flips) = 1;
    end
end