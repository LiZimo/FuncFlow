function W = update_weights(X, sig, img1_projected_indicators, img2_projected_indicators, alphas)
%% Given the f-map X, the scalings alphas, and the correspondences, updates the weights to be
%% the new residuals

new_diffs = X*img1_projected_indicators - img2_projected_indicators*alphas;

distances = diag(new_diffs'*new_diffs);

distances_mod = sig + distances;

W = diag(sig ./ distances_mod);


end