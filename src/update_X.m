function [X, residual] = update_X(weights, mu, alphas, img1_projected_indicators, img2_projected_indicators, eig_vals1, eig_vals2)
%% given the weights, alphas, projected indicators, and eigenvalues, will optimize for 
%% functional map X.  
% tic;

img1_projected_indicators_weighted = img1_projected_indicators * weights;
img2_projected_indicators_weighted = img2_projected_indicators * weights * alphas;

num_eigenvecs = size(img1_projected_indicators,1);
X = zeros(num_eigenvecs);

for i=1:num_eigenvecs
    
    
    A = img1_projected_indicators_weighted * img1_projected_indicators_weighted' + mu*diag(eig_vals1(i,i) - diag(eig_vals2)).^2;
    b = img2_projected_indicators_weighted(i,:) * img1_projected_indicators_weighted';
     
    xi = b/A;
    X(i,:) = xi;

end
% toc;
% fprintf('Finished one map \n');
residual = norm(X*img1_projected_indicators - img2_projected_indicators) + mu*norm(X*eig_vals1 - eig_vals2*X);
end