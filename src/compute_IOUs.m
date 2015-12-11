function [avg, IOUs] = compute_IOUs(image_dir_name, segments, All_eig_vecs, imgsize)

images = dir([image_dir_name '/*.JPEG']);
if isempty(images)
    images = dir([image_dir_name '/*.bmp']);
end
if isempty(images)
    images = dir([image_dir_name '/*.jpg']);
end
if isempty(images)
    images = dir([image_dir_name '/*.png']);
end


gtmasks = dir([image_dir_name '/GroundTruth/*.JPEG']);
if isempty(gtmasks)
    gtmasks = dir([image_dir_name '/GroundTruth/*.bmp']);
end
if isempty(gtmasks)
    gtmasks = dir([image_dir_name '/GroundTruth/*.jpg']);
end
if isempty(gtmasks)
    gtmasks = dir([image_dir_name '/GroundTruth/*.png']);
end


IOUs = zeros(1, length(gtmasks));
 for i = 1:length(gtmasks)
    
    j = i;
    imag = imread([image_dir_name '/' images(j).name]);
    segment = squeeze(segments(j,1,:));
    seg = All_eig_vecs{j,1,:,:} * segment;
    
    gt_seg = imread([image_dir_name '/GroundTruth/', gtmasks(j).name]);
    gt_seg = squeeze(gt_seg(:,:,1));

   

    I = seg_kmeans(seg);
    final_seg = reshape(I, [imgsize imgsize]);
    final_seg = double(imresize(final_seg, [size(gt_seg,1) size(gt_seg,2)], 'bilinear'));
    final_seg_sup = refine_consistentfunc_with_gop(final_seg, imag);
    

    
    union = logical(final_seg_sup + double(gt_seg));
    intersection = logical(final_seg_sup .* double(gt_seg));
    
    IOUs(j) = sum(intersection(:))/sum(union(:));
end
avg = mean(IOUs);

end