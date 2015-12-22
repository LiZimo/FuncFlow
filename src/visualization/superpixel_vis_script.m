% A short script which breaks up an image into superpixels, and visualizes
% the first "num_basis" eigenvectors of the laplacian for the image;
% Also displays the projection of the ground truth into this basis
% along with projection error.  
% =======================================================================
addpath(genpath('../../src')); 
addpath(genpath('../../external'));
rmpath(genpath('../../external/dsp-code'));
%% set parameters
num_basis = 64; % # basis vectors to compute
num_display = 10; % # basis vectors to display
num_superpixels = 500;
img = imread('../../data/iCoseg/icoseg/skate2/2116024165_5e4138ba98.jpg');
ground_truth = imread('../../data/iCoseg/icoseg/skate2/GroundTruth/2116024165_5e4138ba98.png');

% =============================================================================================
%% Compute superpixel basis and calculate borders of superpixels for the figure
[Laplacian_n, labels, eigenvectors, eigenvalues] = compute_superpixel_basis(img, num_superpixels, num_basis);
[vals, sorted_eigenvalue_indices] = sort(diag(eigenvalues));
eigenvalues = diag(vals);
eigenvectors = eigenvectors(:,sorted_eigenvalue_indices);
[gx,gy] = gradient(double(labels));
lblImg = double(labels);
lblImg((gx.^2+gy.^2)==0) = 0;

% ===============================================================================================
figure; 
colormap('hot');
set(gcf,'name','Smallest Eigenvectors w/ intensity as Laplacian weight','numbertitle','off')

subplot(2,num_display,1:num_display);
out_im = img;
out_im(lblImg ~= 0) = 0;
imshow(out_im); % display original image broken into superpixels


% ================================================================================================
%% Display each basis element.

for j = 1:num_display 
    
eig_vec = eigenvectors(:,j);
eig_vec = (eig_vec - min(eig_vec))/(max(eig_vec) - min(eig_vec));
eig_vis = double(labels);
for i = 1:length(eig_vec)
    eig_vis(eig_vis == i) = eig_vec(i);
end
ax = subplot(2,num_display,j +num_display);
imshow(eig_vis); colormap('hot');
end

% =================================================================================================
%% Show Projected Ground Truth in Basis
superpix_indicators = ground_truth_to_superpixels(labels, ground_truth);

projected_gt_coeffs = superpix_indicators * eigenvectors; % project gt onto the basis
projected_gt = eigenvectors * projected_gt_coeffs';

gt_vis = double(labels);  % change the projected superpixel indicators back to an image
for i = 1:size(eigenvectors,1);
    gt_vis(gt_vis == i) = projected_gt(i);
end

level = graythresh(gt_vis); % use otsu method to threshold
gt_vis_thresh = gt_vis;
gt_vis_thresh(gt_vis < level) = 0;
gt_vis_thresh(gt_vis >= level) = 1;

intersection = ground_truth(:,:,1) .* gt_vis_thresh; % calculate projection error
union = logical(ground_truth(:,:,1) + gt_vis_thresh);
error = 1 - sum(intersection(:))/sum(union(:));

figure; 
str=sprintf('Final Projection Error after Thresholding: %f', error);
subplot(3,1,1); imshow(ground_truth); title('Ground-Truth segmentation'); colormap('hot'); 
subplot(3,1,2); imshow(gt_vis); title('Projected into basis'); colormap('hot'); subplot(3,1,3); imshow(gt_vis_thresh); title(str); colormap('hot');
