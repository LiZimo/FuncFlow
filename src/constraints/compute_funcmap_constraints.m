function [All_constraints] = compute_funcmap_constraints(image_dir_name, imgsize,flip, All_eig_vecs, All_superpixels, type)
%% ======================================================
%% Compute all constraints, projected into reduced space of every image pair
% The correspondences used are both pixel-correspondences from optical flow
% fields, such as 'DSP' or 'SIFTflow', along with saliency correspondences
% derived from 'GBVS'.  For more info, please refer to:

% <http://people.csail.mit.edu/celiu/SIFTflow/>
% <http://vision.cs.utexas.edu/projects/dsp/>
% <http://www.vision.caltech.edu/~harel/share/gbvs.php>
% ======================================================
%% INPUTS
% image_dir_name - (str) name of image director
% imgsize - (int) reshaped image size to use
% flip - (int) 1 (no flipped copies) or 2 (flipped copies)
% All_eig_vecs - (N x F cell, N is #images, F is flip) each entry has all the eigenvectors for an image arranged in columns
% All_superpixels - (N x F cell, N is #images, F is flip) if type == superpixels, then this contains superpixel labels for each image
% type - either 'DSP' or 'SIFTflow' pixel correspondences
% =======================================================
%% OUTPUTS
% All_constraints - (N x F x N x F cell, N is #images, F is flip) contains the correspondences between each image-pair projected into reduced space
%% =======================================================

images = dir([image_dir_name '/*.JPEG']);
if isempty(images)
    images = dir([image_dir_name '/*.bmp']);
end
if isempty(images)
    images = dir([image_dir_name '/*.jpg']);
end

All_constraints = cell(length(images), flip, length(images), flip,2);
for z = 1:length(images)
    
    for z_flip = 1:flip
        if z_flip == 1
            im1_whole = imread([image_dir_name '/' images(z).name]);
        elseif z_flip == 2 
            im1_whole = flip_image(imread([image_dir_name '/' images(z).name])); % use flipped copy
        end
        
        % =============================
        %% resize image 1 and load basis
        im1 = double(imresize(im1_whole, [imgsize imgsize]));
        eig_vecs1 = All_eig_vecs{z,z_flip};
        % ==============================
        
        for y = 1:length(images)
            for y_flip = 1:flip
                if y_flip == 1
                    im2_whole = imread([image_dir_name '/' images(y).name]);
                elseif y_flip ==2
                    im2_whole = flip_image(imread([image_dir_name '/' images(y).name]));
                end
                
                % ===========================================
                %% resize image 2 and load basis
                im2 = double(imresize(im2_whole, [imgsize imgsize]));
                eig_vecs2 = All_eig_vecs{y,y_flip};
                %========================================================================================
                %% Calculate all correspondences between the two images
                if z == y && z_flip ~= y_flip
                    [C,D] = get_flip_correspondences(im1); % gt-correspondences between an image and its flipped version
                else                   
                   [C, D] = get_pixel_correspondences(im1, im2, type); % pixel correspondences using either 'SIFTflow' or 'DSP'
                end
                
                [im1_saliency, im2_saliency] = get_saliency_correspondences(im1, im2); %Saliency correspondences using 'GBVS'
                
                if iscell(All_superpixels) % move correspondences up to superpixel resolution if so desired
                    [C, D] = pixel_to_superpixel_correspondences(D, All_superpixels{z,z_flip}, All_superpixels{y,y_flip});
                    [im1_saliency]  = pixel_to_superpixel_saliency(im1_saliency, All_superpixels{z,z_flip});
                    [im2_saliency] =  pixel_to_superpixel_saliency(im2_saliency, All_superpixels{y,y_flip});
                end
                
                %============================================================================================
                %% gather all correspondences and save them
                img1_projected_indicators = [normalize_columns(eig_vecs1'*C) normalize_columns(eig_vecs1'*im1_saliency)]; % normalize so that correspondences have equal weight
                img2_projected_indicators = [normalize_columns(eig_vecs2'*D) normalize_columns(eig_vecs2'*im2_saliency)];
                
                indicators = {};
                indicators{1} = img1_projected_indicators;
                indicators{2} = img2_projected_indicators;
                for j = 1:2
                    All_constraints{z, z_flip, y, y_flip,j} = indicators{j};
                    
                end
                %==============================================================================================
            end
        end
        
    end
    fprintf('Finished computing constraints for image (%d / %d) \n', z, length(images));
end
end
