function outim = get_projected_image(basis, image)

imgsize = floor(sqrt(size(basis,1)));
if size(image,1)*size(image,2) == size(basis,1)
    seg_vecj = double(reshape(image, 1, []));
    seg_proj_coeffj = seg_vecj * basis;
else
    seg_proj_coeffj = squeeze(image)';
end

seg_proj_j = basis * seg_proj_coeffj';

outim = reshape(seg_proj_j,imgsize, imgsize);
outim = (outim - min(outim(:))) / (max(outim(:)) - min(outim(:)));
%outim = outim/norm(outim);
end