function [output_masks_final, output_masks_rough, output_consistentfunc] = visualize_output_masks(image_dir_name, consistent_funcs, All_eig_vecs, imgsize, which)
%% ===============================================================
%% Computes final mask and creates figures


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

output_consistentfunc = cell(1, length(images));
output_masks_final = cell(1, length(images));
output_masks_rough = cell(1, length(images));
for i = 1:length(images)

    image = imread([image_dir_name '/' images(i).name]);
    consistent_func = squeeze(consistent_funcs(i,1,:));
    try 
        consistent_func_im = All_eig_vecs{i,1} * consistent_func;
    catch
        consistent_func_im = squeeze(All_eig_vecs(i,1,:,:)) * consistent_func;
    end
    
    I = seg_kmeans(consistent_func_im);
    
    final_seg = reshape(I, [imgsize imgsize]);
    final_seg = double(imresize(final_seg, [size(image,1) size(image,2)], 'bilinear'));
    output_consistentfunc{i} = final_seg;
    final_seg_sup = refine_consistentfunc_with_gop(final_seg, image);
    output_masks_final{i} = final_seg_sup;
    output_masks_rough{i} = logical(final_seg);
      
end

if ~isempty(which)
    figure;
end

    for j = 1:length(which)
        image = imread([image_dir_name '/' images(j).name]);
        segmented_image_final = mask_to_segment(output_masks_final{which(j)}, image);
        segmented_image_rough = mask_to_segment(output_masks_rough{which(j)}, image); 
        subplot(3, length(which), 0*length(which) + j); imshow(output_consistentfunc{j}); colormap('hot'); title('Generated Function', 'FontSize', 7);
        subplot(3, length(which), 1*length(which) + j) ; imshow(segmented_image_rough); title('Rough Thresholding', 'FontSize', 7);
        subplot(3, length(which), 2*length(which) + j); imshow(segmented_image_final); title('Final Output', 'FontSize', 7); 
    end
end