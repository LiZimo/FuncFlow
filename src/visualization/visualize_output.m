function [] = visualize_output(image_dir_name, output_masks_mrf, output_masks_unary, output_masks_rough, output_consistentfunc, which)

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

for j = 1:length(which)
    image = imread([image_dir_name '/' images(which(j)).name]);
    segmented_image_mrf = mask_to_segment(output_masks_mrf{which(j)}, image);
    segmented_image_unary = mask_to_segment(output_masks_unary{which(j)}, image);
    segmented_image_rough = mask_to_segment(output_masks_rough{which(j)}, image);
    subplot(4, length(which), 0*length(which) + j); imshow(output_consistentfunc{which(j)}); colormap('hot'); title('Generated Function', 'FontSize', 4);
    subplot(4, length(which), 1*length(which) + j) ; imshow(segmented_image_rough); title('Rough Thresholding', 'FontSize', 4);
    subplot(4, length(which), 2*length(which) + j); imshow(segmented_image_unary); title('Unary Mask Output', 'FontSize', 4);
    subplot(4, length(which), 3*length(which) + j); imshow(segmented_image_mrf); title('MRF Mask Output', 'FontSize', 4);
end

end