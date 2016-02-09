function features = compute_caffenet_features(im, layer, caffe_dir)
%% ======================================================
%% computes caffenet features for rgb image "im" at layer "layer"
% ======================================================
%% INPUTS: 
% im - an rgb image
% layer (str) - a string detailing which layer to extract features from
% ======================================================
%% OUTPUTS:
% features - features array, the same height and width as input image
%% =========================================================

warning('off', 'all');
addpath(genpath(caffe_dir));
% Set caffe mode
if exist('use_gpu', 'var') && use_gpu
  caffe.set_mode_gpu();
  gpu_id = 0;  % we will use the first gpu in this demo
  caffe.set_device(gpu_id);
else
  caffe.set_mode_cpu();
end

% Initialize the network using BVLC CaffeNet for image classification
% Weights (parameter) file needs to be downloaded from Model Zoo.
model_dir = [caffe_dir '/models/bvlc_reference_caffenet/'];
net_model = [model_dir 'deploy.prototxt'];
net_weights = [model_dir 'bvlc_reference_caffenet.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)
if ~exist(net_weights, 'file')
  error('Please download CaffeNet from Model Zoo before you run this demo');
end

% Initialize a network
net = caffe.Net(net_model, net_weights, phase);

% reshape so the network takes in 1 image at a time
net.blobs('data').reshape([227 227 3 1]); % reshape blob 'data'
net.reshape();


% run the forward pass with the pretrainedm odel
data_dimensions = net.blobs('data').shape;
x_size = data_dimensions(1);
y_size = data_dimensions(2);

padded_im = prepare_image_for_caffenet(im, x_size, y_size);
scores = net.forward({padded_im});

% get the conv4 features
features = net.blobs(layer).get_data();

% call caffe.reset_all() to reset caffe
caffe.reset_all();

end
