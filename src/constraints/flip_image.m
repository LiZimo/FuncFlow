function flipped = flip_image(image)
%% given 'image', flips it around the y-axis
%=======================================
    flipped = zeros(size(image));
    flipped(:,:,:)  = image(:,end:-1:1,:);
end