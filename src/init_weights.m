function weights = init_weights(image_dir_name, flip)
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
weights = zeros(length(images), flip, length(images),flip);
for x = 1:length(images)
    for x_flip = 1:flip
        for p = 1:length(images)
            for p_flip = 1:flip
                
                if x == p && x_flip ~= p_flip
                    weights(x,x_flip,p,p_flip) = 1;
                elseif x==p && x_flip == p_flip
                    weights(x,x_flip,p,p_flip) = 0;
                else
                    weights(x,x_flip,p,p_flip) = 0.2;
                    
                end
            end
        end
    end
end
end