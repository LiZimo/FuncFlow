function outim = get_projected_image(basis, image)
%% ===============================================
% Given a function over an image ('image') and a basis ('basis'), 
% show the projected function in that basis.  Assumes square image;
% ================================================
%% INPUTS: 
% basis - (imgsize x numvecs double), the basis vectors as columns
% image - (imgsize x imgsize double), the image we are projecting
% ================================================
%% OUTPUTS:
% outim - (imgsize x imgsize double), projected image
%% ===============================================

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
end