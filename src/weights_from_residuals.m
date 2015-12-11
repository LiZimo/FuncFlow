function weights = weights_from_residuals(Residuals)

num_ims = size(Residuals,1);
flip = size(Residuals,2);
weights = exp(-Residuals/(0.1*norm(Residuals(:))));
for k = 1:num_ims
    for flips = 1:flip
        weights(k,flips,k,flips) = 0;
        weights(k,flips,k,flips) = 0;
        weights(k,flips,k,mod(flips,2) + 1) = 1;
        weights(k,mod(flips,2) + 1, k, flips) = 1;
    end
end