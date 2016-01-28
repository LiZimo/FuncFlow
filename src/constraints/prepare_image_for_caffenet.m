function padded_im_data = prepare_image_for_caffenet(im, xsize, ysize)
% ===========================================
% pad the image and switch the channels to be caffe compatible
% ============================================
%% INPUTS: rgb image
%% OUTPUTS: rgb image, padded and reformatted for caffe
% ============================================


% caffe/matlab/+caffe/imagenet/ilsvrc_2012_mean.mat contains mean_data that
% is already in W x H x C with BGR channels
padded_size = 20;

width = size(im,2);
height = size(im,1);

padded = zeros(height + 2*padded_size, width + 2*padded_size, 3);
padded(padded_size + 1:end - padded_size, padded_size + 1:end - padded_size, :) = im;

% Convert an image returned by Matlab's imread to im_data in caffe's data
% format: W x H x C with BGR channels
padded_im_data = padded(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
padded_im_data = permute(padded_im_data, [2, 1, 3]);  % flip width and height
padded_im_data = single(padded_im_data);  % convert from uint8 to single
padded_im_data = imresize(padded_im_data, [ysize xsize], 'bilinear');  % resize im_date


end