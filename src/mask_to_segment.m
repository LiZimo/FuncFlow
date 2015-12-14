function segmented_image = mask_to_segment(mask, image)

    [gx,gy] = gradient(double(logical(mask)));
    non_zero_gradient = (gx.^2 + gy.^2) ~= 0;
    contour = non_zero_gradient;
    for u = 0:2
        for v = 0:2
            contour(1+u:end, 1+v:end) = contour(1+u:end, 1+v:end) + non_zero_gradient(1:end-u, 1:end-v);
            contour(1:end-u, 1:end-v) = contour(1:end-u, 1:end-v) + non_zero_gradient(1+u:end, 1+v:end);
        end
    end
    
    contour = double(logical(contour))*255;
    segmented_image = double(image);
    
    segmented_image(:,:,1) = segmented_image(:,:,1) .* (logical(~contour) + contour);
    segmented_image(:,:,2) = segmented_image(:,:,2) .* logical(~contour);
    segmented_image(:,:,3) = segmented_image(:,:,3) .* logical(~contour);
   
    segmented_image = segmented_image/255;
end