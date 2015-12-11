function [corlocs, avg] = evaluate_segmentations_superpixels(image_dir_name, segments, All_eig_vecs, All_superpixels)

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

figure;
corlocs = zeros(1, length(images));
length1 = 10;
 for i = 1:length1
    
    %j = randi([1 length(images)]);
    j = i ;
    imag = imread([image_dir_name '/' images(j).name]);
    segment = squeeze(segments(j,1,:));
    superpixel_seg = All_eig_vecs{j,1} * segment;
    seg = zeros( size(imag,1),size(imag,2));
    
    labels = All_superpixels{j,1};
    regions = length(unique(labels));
    
    for e = 1:regions
        seg(labels == e) = superpixel_seg(e);
    end
    
    
    seg_name = images(j).name;  
   
    try gt_seg = imread([image_dir_name '/GroundTruth/', images(j).name]);
    catch
        gt_seg = imread([image_dir_name '/GroundTruth/', seg_name(1:end-3) 'png']);
    end
    gt_seg = squeeze(gt_seg(:,:,1));

    
    I = seg_kmeans(seg);
    %I = (seg - min(seg(:)))/(max(seg(:))- min(seg(:)));
    
    filter = [1/sqrt(2) 1 1/sqrt(2); 1 0 1; 1/sqrt(2) 1 1/sqrt(2)];
    for c = 1:10
        I = conv2(I, filter, 'same');
    %mask = wittle(mask, 200);
    end
    I = wittle(I, 10);
    final_seg = reshape(I, size(imag,1), size(imag,2));
    final_seg = double(imresize(final_seg, [size(gt_seg,1) size(gt_seg,2)], 'bilinear'));
    final_seg_sup = refine_consistentfunc_with_gop(final_seg, imag);
    %final_seg_sup = refine_mask_with_superpixels(final_seg, imag);
    %final_seg_sup = ~final_seg_sup;
    %final_seg_sup = refine_mask_with_gop(final_seg_sup, imag);
%     final_seg_sup = double(repmat(final_seg_sup, 1, 1, 3));
%     final_seg = double(repmat(final_seg, 1,1,3));
%     
    gray = rgb2gray(imag);
    mask_orig = gray;
    level_orig = graythresh(gray);
    mask_orig(gray < level_orig*255) = 0;
    mask_orig(gray >= level_orig*255) = 1;
    
    BW = im2bw(imag,level_orig);

%     level2 = graythresh(I);
%     I(I<level2) = 0;
%     I = seg;
%     I(I < mean(seg)) = 0;
%     I(I > mean(seg)) = 1;
    
    [gx_fseg,gy_fseg] = gradient(double(logical(final_seg)));
    non_zero_gradient = (gx_fseg.^2 + gy_fseg.^2) ~= 0;
    contour_fseg = non_zero_gradient;
    for u = 0:2
        for v = 0:2
            contour_fseg(1+u:end, 1+v:end) = contour_fseg(1+u:end, 1+v:end) + non_zero_gradient(1:end-u, 1:end-v);
            contour_fseg(1:end-u, 1:end-v) = contour_fseg(1:end-u, 1:end-v) + non_zero_gradient(1+u:end, 1+v:end);
        end
    end
    
    contour_fseg = double(logical(contour_fseg))*255;
    mask = double(imag);

    mask(:,:,1) = mask(:,:,1) .* (logical(~contour_fseg) + contour_fseg);
    mask(:,:,2) = mask(:,:,2) .* logical(~contour_fseg);
    mask(:,:,3) = mask(:,:,3) .* logical(~contour_fseg);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    [gx_fseg_sup,gy_fseg_sup] = gradient(double(logical(final_seg_sup)));
    non_zero_gradient_sup = (gx_fseg_sup.^2 + gy_fseg_sup.^2) ~= 0;
    contour_fseg_sup = non_zero_gradient_sup;
    for u = 0:2
        for v = 0:2
            contour_fseg_sup(1+u:end, 1+v:end) = contour_fseg_sup(1+u:end, 1+v:end) + non_zero_gradient_sup(1:end-u, 1:end-v);
            contour_fseg_sup(1:end-u, 1:end-v) = contour_fseg_sup(1:end-u, 1:end-v) + non_zero_gradient_sup(1+u:end, 1+v:end);
        end
    end
    
    contour_fseg_sup = double(logical(contour_fseg_sup))*255;
    mask_sup = double(imag);
    
    mask_sup(:,:,1) = mask_sup(:,:,1) .* (logical(~contour_fseg_sup) + contour_fseg_sup);
    mask_sup(:,:,2) = mask_sup(:,:,2) .* logical(~contour_fseg_sup);
    mask_sup(:,:,3) = mask_sup(:,:,3) .* logical(~contour_fseg_sup);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     mask = double(imag) .* logical(final_seg);
%     mask_sup = double(imag) .* final_seg_sup;
    %subplot(2, length1, i); imshow(imag);
    %subplot(5, length1, length1 + i); imshow(BW);
    subplot(3, length1, 2*length1 + i) ; imshow(mask/255); %input('next');
    subplot(3, length1, 0*length1 + i); imshow(final_seg); colormap('hot');
    subplot(3, length1, 1*length1 + i); imshow(mask_sup/255);
    
    union = logical(double(squeeze(final_seg(:,:,1))) + double(gt_seg));
    intersection = logical(double(squeeze(final_seg(:,:,1))) .* double(gt_seg));
    
    corlocs(j) = sum(intersection(:))/sum(union(:));
end
avg = mean(corlocs);

end