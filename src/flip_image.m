

function flipped = flip_image(image)
    flipped = zeros(size(image));
    flipped(:,:,:)  = image(:,end:-1:1,:);
end