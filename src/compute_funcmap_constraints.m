function [All_constraints] = compute_funcmap_constraints(image_dir_name, imgsize,flip, All_eig_vecs, All_superpixels, type)

images = dir([image_dir_name '/*.JPEG']);
if isempty(images)
    images = dir([image_dir_name '/*.bmp']);
end
if isempty(images)
    images = dir([image_dir_name '/*.jpg']);
end

num_eigenvecs = size(All_eig_vecs{1,1},2);
All_constraints = cell(length(images), flip, length(images), flip,2);
for z = 1:length(images)
    
    for z_flip = 1:flip
        if z_flip == 1
            im1_whole = imread([image_dir_name '/' images(z).name]);
        end
        if z_flip == 2

            im1_whole = flip_image(imread([image_dir_name '/' images(z).name]));
        end
        im1 = double(imresize(im1_whole, [imgsize imgsize]));
        eig_vecs1 = All_eig_vecs{z,z_flip};
        
        for y = 1:length(images)
            for y_flip = 1:flip
                if y_flip == 1

                    im2_whole = imread([image_dir_name '/' images(y).name]);
                end
                if y_flip ==2
     
                    im2_whole = flip_image(imread([image_dir_name '/' images(y).name]));
                end
                
                im2 = double(imresize(im2_whole, [imgsize imgsize]));
                eig_vecs2 = All_eig_vecs{y,y_flip};
                
                if z == y && z_flip ~= y_flip
                    [C,D] = get_flip_correspondences(im1);
                else
  
                    [C, D] = get_pixel_correspondences(im1, im2, type);
                end
                

                
                [im1_saliency, im2_saliency] = get_saliency_correspondences(im1, im2);

                
                %% Section 3: solve for the change of basis matrix row by row
                
                
                if iscell(All_superpixels)
                    [C, D] = pixel_to_superpixel_correspondences(D, All_superpixels{z,z_flip}, All_superpixels{y,y_flip});
                    [im1_saliency]  = pixel_to_superpixel_saliency(im1_saliency, All_superpixels{z,z_flip});
                    [im2_saliency] =  pixel_to_superpixel_saliency(im2_saliency, All_superpixels{y,y_flip});
                end
                
                img1_projected_indicators = [normalize_columns(eig_vecs1'*C) normalize_columns(eig_vecs1'*im1_saliency)];  
                img2_projected_indicators = [normalize_columns(eig_vecs2'*D) normalize_columns(eig_vecs2'*im2_saliency)]; 
                
                indicators = {};
                indicators{1} = img1_projected_indicators;
                indicators{2} = img2_projected_indicators;
                for j = 1:2
                    All_constraints{z, z_flip, y, y_flip,j} = indicators{j};
                    
                end
                
            end
        end

    end
    fprintf('Finished computing constraints for image (%d / %d) \n', z, length(images));
end
end
