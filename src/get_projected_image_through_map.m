
function outim = get_projected_image_through_map(basis1, basis2, fmap, image)
imgsize = floor(sqrt(size(basis2,1)));         
if size(image,1)*size(image,2) == size(basis1,1)
    img_vector = double(reshape(image, 1, []));
    img_projected_onto_basis1 = img_vector * basis1;
else
    img_projected_onto_basis1 = squeeze(image)';
end



img_across_fmap = fmap * img_projected_onto_basis1';
img_proj_on_new_basis = basis2*img_across_fmap;

outim = reshape(img_proj_on_new_basis, imgsize, imgsize);
outim = (outim - min(outim(:)))/ (max(outim(:) - min(outim(:))));
outim = outim/norm(outim);


end
