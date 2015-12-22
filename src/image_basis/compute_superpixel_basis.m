function [Laplacian_n, superpixels, eigenvectors, eigenvalues] = compute_superpixel_basis(img, numpix, num_eigenvecs)
%% ==========================================
%% Breaks image into superpixels and computes basis in that domain
% For more info, refer to section 2 of the attached pdf
% and <http://ttic.uchicago.edu/~huangqx/whg-icsfm-13.pdf>
% ===========================================
%% INPUTS:
% img - (H x W x 3) rgb image, can also work with grayscale
% numpix - (int) number of superpixels to use.  Actual number of superpixels will be approximate
% num_eigenvecs - number of eigenvectors to find.  Must be less than number of superpixels.  
% ============================================
%% OUTPUTS:
% Laplacian_n - (numpix x numpix double) normalized Laplacian matrix
% superpixels - (H x W double) labels each pixel of input image with its superpixel cluster
% eigenvectors - (numpix x num_eigenvecs double) stores eigenvectors of laplacian as columns
% eigenvalues - (num_eigenvecs x num_eigenvecs double) stores corresponding eigenvalues of the eigenvectors along the diagonal of a square matrrix
%% ============================================
%% first get the superpixels
[labels, num] = slicomex(img, numpix); %% first parameter is number of superpixels, second parameter is how "square" the superpixels are.  Higher means more square

labels = labels + 1; % the smallest region is indexed by 0, but we want it to be 1
superpixels = labels;
%===============================================================
%% next calculate 2 adjacency matrices of the superpixels: one for 
%% boundary length and one for average intensity.  I've tried doing
%% elementwise multiplication of these for the final Laplacian, but 
%% I have found using average intensity alone works better
% ================================================================
adj_mat_boundary = adj_from_superpixels(labels, 'boundary');
adj_mat_intensity = adj_from_superpixels(labels, 'intensity', img);
sigma_bnd = median(adj_mat_boundary(adj_mat_boundary~=0)); %% sigma vales are the medians of the non zero values of these two adjacency matrices
sigma_intns = median(adj_mat_intensity(adj_mat_intensity~=0));

%========================== change the values of the adjacency matrix to be gaussians of the
%non-zero values.  Zero-valued weights remain zero
adj_mat_bnd_exp = exp(adj_mat_boundary^2/sigma_bnd);
adj_mat_bnd_exp(adj_mat_boundary == 0) = 0;
adj_mat_intns_exp = exp(-adj_mat_intensity/sigma_intns);
adj_mat_intns_exp(adj_mat_intensity == 0) = 0;
adj_mat_whole = adj_mat_intns_exp;  % use just average intensity laplacian in the end

%========Calculate normalized laplacian from the adjacency============================================
Diagonal = diag(sum(adj_mat_whole));
d = diag(Diagonal);
D_neghalf = diag(1./sqrt(d));
Laplacian = Diagonal - adj_mat_whole;
Laplacian_n = D_neghalf * Laplacian * D_neghalf;
Laplacian_n = (Laplacian_n + Laplacian_n')/2;
assert(issymmetric(Laplacian_n));


%% calculate eignvectors and values and sort them
opts.issym = 1;
opts.isreal = 1;
[eigenvectors, eigenvalues] = eigs(Laplacian_n, num_eigenvecs, 1e-10, opts);
[vals, sorted_eigenvalue_indices] = sort(diag(eigenvalues));
eigenvalues = diag(vals);
eigenvectors = eigenvectors(:,sorted_eigenvalue_indices);

end
