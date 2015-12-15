function [X, residual] = update_X(weights, mu, alphas, img1_constraints, img2_constraints, eig_vals1, eig_vals2)
%% ===============================================================
%% given the weights, alphas, projected constraints, and eigenvalues, will optimize for functional map X.
% see section 3 of pdf in top level directory for more details
% =================================================================
%% INPUTS:
% weights - (K x K double , K is number of constraints) correspondence weights
% mu - (double)regularization constraint
% alphas - (K x K double , K is number of constraints) correspondence scaling factor
% img1_constraints - (K x M double, K is # cosntraints, M is # basis vectors) correspondences projected into reduced space for img 1
% img2_constraints - (K x M double, K is # cosntraints, M is # basis vectors) correspondences projected into reduced space for img2
% eig_vals1 - (M x M double, M is # basis vectors) eigenvalues matching to basis vectors for img 1
% eig_vals2 - (M x M double, M is # basis vectors) eigenvalues matching to basis vectors for img 2
% ==================================================================
%% OUTPUTS:
%  X - ( M x M double, M is number of basis vectors) functional map for the two images
%  residual - (double) value of the objective function being minimized by X
%% ==================================================================

img1_constraints_weighted = img1_constraints * weights;
img2_constraints_weighted = img2_constraints * weights * alphas;

num_eigenvecs = size(img1_constraints,1);
X = zeros(num_eigenvecs);

% ============================================================
%% solve for the functional map row by row
for i=1:num_eigenvecs
    A = img1_constraints_weighted * img1_constraints_weighted' + mu*diag(eig_vals1(i,i) - diag(eig_vals2)).^2;
    b = img2_constraints_weighted(i,:) * img1_constraints_weighted';
    xi = b/A;
    X(i,:) = xi;
end
%================================================================
residual = norm(X*img1_constraints - img2_constraints) + mu*norm(X*eig_vals1 - eig_vals2*X);
end