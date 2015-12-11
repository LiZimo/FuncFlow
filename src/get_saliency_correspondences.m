function [saliency1, saliency2] = get_saliency_correspondences(im1, im2)
    
    image1 = imresize(im1, [128 128]);
    image2 = imresize(im2, [128 128]);
    
    im1_saliency = reshape(gbvs( image1 ), [], 1);
    im2_saliency = gbvs( image2, [], 1);
    
    saliency1 = imresize(im1_saliency.master_map, [size(im1,1), size(im1,2)]);
    saliency2 = imresize(im2_saliency.master_map, [size(im2,1), size(im2,2)]);
    
    saliency1 = reshape(saliency1, [], 1);
    saliency2 = reshape(saliency2, [], 1);
end