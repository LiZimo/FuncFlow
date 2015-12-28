% Short script to visualize eigenvectors of the image laplacian for a
% given image.  Also displays projection error
% of ground-truth segmentation into the basis.

% These are the basis vectors we use in the optimization of
% the functional maps.  To run the script on a different image, specify
% a new image_name and gt_name.
% =========================================================================
addpath(genpath('../../src'));
addpath(genpath('../../external'));
rmpath(genpath('../../external/dsp-code'));
%% Set Parameters
image_name = '../../data/iCoseg/icoseg/skate2/2116024165_5e4138ba98.jpg';
gt_name = '../../data/iCoseg/icoseg/skate2/GroundTruth/2116024165_5e4138ba98.png';
img = imread(image_name);
num_display_vecs = 5; % number of basis vectors to visualize
num_basis_vecs = 32; % how many basis vectors to compute
Laplacian_radius = 5; % radius for laplacian n-cut
imgsize = 64; % reshape image to square of this size
img1 = double(imresize(img, [imgsize, imgsize]));

% =========================================================================
%% Calculate Laplacian and compute the eigenvectors
sigmax = sqrt(size(img1, 1)^2 + size(img1,2)^2)/10; % sigmax 1/10 of the diagonal
intnsty = sum(img1.^2,3).^(0.5);
all_diffs = pdist2(intnsty(:), intnsty(:));
sigmav = sqrt(median(all_diffs(:))); % sigmav the median of all intensity value differences



[laplcn_img, D_half] = ICS_laplacian_nf(img1, Laplacian_radius, sigmax, sigmav);
[laplcn_logical, ~] = ICS_laplacian_nf(zeros(imgsize), 1, 1, 1);
%==================================================
%% compute the smallest eigenvectors of the laplcn
%% This is the reduced functional space we will be optimizing in
opts.issym = 1;
opts.isreal = 1;
[eig_vecs_img, eig_vals_img] = eigs(laplcn_img, num_basis_vecs, 1e-10,opts);
[eig_vecs_logical, eig_vals_logical] = eigs(laplcn_logical, num_basis_vecs, 1e-10, opts);
eig_vals = diag([diag(eig_vals_img); diag(eig_vals_logical)]);
eig_vecs = [eig_vecs_img eig_vecs_logical];

[vals,sorted_eig_val_indices] = sort(diag(eig_vals));


eig_vals = diag(vals);
eig_vecs = eig_vecs(:,sorted_eig_val_indices);

% =========================================================================
%% Visualize each basis element
figure;
set(gcf,'name','Smallest Eigenvectors of Laplacian','numbertitle','off')
subplot(2,num_display_vecs, 1:num_display_vecs);
imshow(img);
for i = 1:num_display_vecs
    
    eig_vec = eig_vecs(:,i);
    eig_vec = (eig_vec - min(eig_vec))/(max(eig_vec) - min(eig_vec)); % scale image to be in [0,1]
    eig_vec = reshape(eig_vec, [imgsize imgsize]);
    subplot(2,num_display_vecs, i + num_display_vecs);
    imshow(eig_vec); colormap('hot');
    
end
% =========================================================================
%% Show projected Ground Truth in this basis

gt_seg = imread(gt_name);

proj = get_projected_image(eig_vecs(:,1:num_basis_vecs), imresize(gt_seg, [imgsize imgsize])); % project image into the basis
proj = imresize(proj, [size(img,1) size(img,2)], 'bilinear');
proj = reshape(proj, 1, []);
[id, c] = kmeans(proj',2); % use kmeans to threshold the image into binary
[~, maxid] = max(c);
proj_thresh = zeros(size(proj));
proj_thresh(id == maxid) = 1;

proj = reshape(proj, size(img,1),size(img,2));
proj_thresh = reshape(proj_thresh, size(img,1), size(img,2));

intersection = gt_seg(:,:,1) .* proj_thresh; % compute the projection error here
union = logical(gt_seg(:,:,1) + proj_thresh);
error = 1 - sum(intersection(:))/sum(union(:));

figure;
str=sprintf('Final Projection Error after Thresholding: %f', error);
subplot(3,1,1); imshow(gt_seg); title('Ground-Truth segmentation'); colormap('hot');
subplot(3,1,2); imshow(proj); title('Projected into basis'); colormap('hot'); subplot(3,1,3); imshow(proj_thresh); title(str); colormap('hot');
