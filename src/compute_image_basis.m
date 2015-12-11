function [All_eig_vecs, All_eig_vals, All_superpixels] = compute_image_basis(image_dir_name, num_eigenvecs,imgsize,flip, radius, numpix, type)

%% ===== Set up Parameters: section 1 =====%

images = dir([image_dir_name '/*.JPEG']);
if isempty(images)
    images = dir([image_dir_name '/*.bmp']);
end
if isempty(images)
    images = dir([image_dir_name '/*.jpg']);
end

All_eig_vecs = cell(length(images),flip);
All_eig_vals = cell(length(images),flip);
All_superpixels = cell(length(images), flip);
% All_laplacians = cell(length(images),flip);
% All_lplc_diags = cell(length(images),flip);
for z = 1:length(images)
    
    for z_flip = 1:flip
        if z_flip == 1
            %im1_whole = imread_ncut([image_dir_name '/' images(z).name], imgsize, imgsize);
            im1_whole = imread([image_dir_name '/' images(z).name]);
        end
        if z_flip == 2
            %im1_whole = flip_image(imread_ncut([image_dir_name '/' images(z).name]), imgsize, imgsize);
            im1_whole = flip_image(imread([image_dir_name '/' images(z).name]));
        end
        
        if strcmp(type, 'pixel')
        im1 = double(imresize(im1_whole, [imgsize imgsize]));
        sigmax = sqrt(size(im1, 1)^2 + size(im1,2)^2)/10;
        intnsty = sum(im1.^2,3).^(0.5);
        all_diffs = pdist2(intnsty(:), intnsty(:));
        sigmav = sqrt(median(all_diffs(:)));
        [laplcn, D_half] = ICS_laplacian_nf(im1, radius, sigmax, sigmav);
        
        opts.issym = 1;
        opts.isreal = 1;
        [eig_vecs, eig_vals] = eigs(laplcn, num_eigenvecs, 1e-10,opts);
        All_superpixels= 0;
%         All_lplc_diags{z, z_flip} = sparse(D_half);
%         All_laplacians{z, z_flip} = sparse(laplcn);
        
 
        
        
        elseif strcmp(type, 'superpixel')
            [laplcn, superpixels, eig_vecs, eig_vals] = compute_superpixel_basis(im1_whole, numpix, num_eigenvecs);
            All_superpixels{z, z_flip} = superpixels;
        end
            All_eig_vecs{z,z_flip} = eig_vecs;
            All_eig_vals{z,z_flip} = eig_vals;
        fprintf('Image (%d / %d) computed \n', z, length(images));
    end
end
end