function [All_eig_vecs, All_eig_vals, All_superpixels] = compute_image_basis(image_dir_name, num_eigenvecs,imgsize,flip, radius, numpix, type)
%% ================================================================
%% Function computes the reduced basis for each image, at either the pixel or superpixel resolution.
% For more info, refer to section 2 of the attached pdf
% and <http://ttic.uchicago.edu/~huangqx/whg-icsfm-13.pdf>
%==================================================================
%% INPUTS:
% image_dir_name - (str) name of image directory
% num_eigenvecs - (int) dimension of reduced space to use
% imgsize - (int) reshaped image size to use
% flip - 1 (no flipped copies) or 2 (flipped copies)
% radius - (int) radius to use when computing laplacian for image
% numpix - (int) number of superpixels to use (only valid for superpixels)
% type - (str) either 'pixel' or 'superpixel'
%==================================================================
%% OUTPUTS:
% All_eig_vecs - (N x F cell, N is #images, F is flip) each entry has all the eigenvectors for an image arranged in columns
% All_eig_vals - (N x F cell, N is #images, F is flip) each entry has all the eigenvalues for an image along the diagonal of a square matrix.  The values correspond to eigenvector entries
% All_superpixels - (N x F cell, N is #images, F is flip) if type == superpixels, then this contains superpixel labels for each image
%===================================================================
% NOTE: if flip is used, then there will also be entries for each flipped copy.
% e.g. All_eig_vecs{i,1} will be the basis vectors for the original image and
% All_eig_vecs{i,2} will be the basis vectors for the flipped image
%% ==================================================================

images = dir([image_dir_name '/*.JPEG']);
if isempty(images)
    images = dir([image_dir_name '/*.bmp']);
end
if isempty(images)
    images = dir([image_dir_name '/*.jpg']);
end

All_eig_vecs = cell(length(images),flip);
All_eig_vals = cell(length(images),flip);
%All_superpixels = cell(length(images), flip);


% We use both the eigenvectors of the logical laplacian, and the image
% laplacian, in the optimization
opts.issym = 1;
opts.isreal = 1;
[laplcn_logical_pix, ~] = ICS_laplacian_nf(zeros(imgsize), 1, 1, 1);
[eig_vecs_logical, eig_vals_logical] = eigs(laplcn_logical_pix, num_eigenvecs, 1e-10, opts);

% =================================================
%% All_superpixels is set to 0 if using pixels
All_superpixels= 0;
parfor z = 1:length(images)
    
    for z_flip = 1:flip
        if z_flip == 1
            im1_whole = imread([image_dir_name '/' images(z).name]);
        elseif z_flip == 2
            im1_whole = flip_image(imread([image_dir_name '/' images(z).name]));
        end
        if strcmp(type, 'pixel')
            im1 = double(imresize(im1_whole, [imgsize imgsize]));
            % ===============================================
            %% sigmax given by a tenth of the image diagonal
            sigmax = sqrt(size(im1, 1)^2 + size(im1,2)^2)/10;
            % ===============================================
            %% sigmav given by the median of all pixel-intensity differences
            intnsty = sum(im1.^2,3).^(0.5);
            all_diffs = pdist2(intnsty(:), intnsty(:));
            sigmav = sqrt(median(all_diffs(:)));
            %==================================================
            %% calculate the laplacian of the image here
            [laplcn_img, D_half] = ICS_laplacian_nf(im1, radius, sigmax, sigmav);
            
            %==================================================
            %% compute the smallest eigenvectors of the laplcn
            %% This is the reduced functional space we will be optimizing in

            [eig_vecs_img, eig_vals_img] = eigs(laplcn_img, num_eigenvecs, 1e-10,opts);
            
            eig_vals = diag([diag(eig_vals_img); diag(eig_vals_logical)]);
            eig_vecs = [eig_vecs_img eig_vecs_logical];
            
            [vals,sorted_eig_val_indices] = sort(diag(eig_vals));
            
            
            eig_vals = diag(vals);
            eig_vecs = eig_vecs(:,sorted_eig_val_indices);
            

            
        elseif strcmp(type, 'superpixel')
            %% use superpixel basis instead
            [laplcn, superpixels, eig_vecs, eig_vals] = compute_superpixel_basis(im1_whole, numpix, num_eigenvecs);
            All_superpixels{z, z_flip} = superpixels;
        end
        
        %% save all basis vectors in a struct
        %====================================
        All_eig_vecs{z,z_flip} = eig_vecs;
        All_eig_vals{z,z_flip} = eig_vals;
        %====================================
    end
    fprintf('Image (%d / %d) computed \n', z, length(images));
end
end