function [] = visualize_output_masks(image_dir_name, segments, All_eig_vecs, imgsize)

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
length1 = 10;
 for i = 1:length1
    
    %j = randi([1 length(images)]);
    j = i ;
    imag = imread([image_dir_name '/' images(j).name]);
    segment = squeeze(segments(j,1,:));
    try 
        seg = All_eig_vecs{j,1} * segment;
    catch
        seg = squeeze(All_eig_vecs(j,1,:,:)) * segment;
    end
    seg_name = images(j).name;  
   
    try gt_seg = imread([image_dir_name '/GroundTruth/', images(j).name]);
    catch
        gt_seg = imread([image_dir_name '/GroundTruth/', seg_name(1:end-3) 'png']);
    end
    gt_seg = squeeze(gt_seg(:,:,1));


    I = seg_kmeans(seg);
    final_seg = reshape(I, [imgsize imgsize]);
    final_seg = double(imresize(final_seg, [size(gt_seg,1) size(gt_seg,2)], 'bilinear'));
    final_seg_sup = refine_consistentfunc_with_gop(final_seg, imag);


    
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
   

    
    subplot(3, length1, 1*length1 + i) ; imshow(mask/255); title('Rough Thresholding', 'FontSize', 7);
    subplot(3, length1, 0*length1 + i); imshow(final_seg); colormap('hot'); title('Generated Function', 'FontSize', 7);
    subplot(3, length1, 2*length1 + i); imshow(mask_sup/255); title('Final Output', 'FontSize', 7);
    

end

end