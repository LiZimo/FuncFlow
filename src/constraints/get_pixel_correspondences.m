function [all_img1_indicators, all_img2_indicators, im1_feats, im2_feats] = get_pixel_correspondences(im1, im2, opt_flow_alg, caffe_dir, feat_type, im1_feats, im2_feats)

%% ====================================================
%% Builds pixelwise correspondences between two images.  
%For details,refer to the pdf, section 3 and 
%<http://people.csail.mit.edu/celiu/SIFTflow/>
%<http://vision.cs.utexas.edu/projects/dsp/>
%% INPUT: 
%% im1 and im2 are two rgb images
%% opt_flow_alg: (str), either "SIFTflow" or "DSP" to designate which flow-field computation to employ
%% feat_type: (str, double), either "conv4" for conv4 features, "sift" for sift features, or a float to represent a weighted concatenation of the two types
%% (weight is multiplied to conv4 feats)
% ===============================================
%% OUTPUT:
%% "all_img1_indicators" is an N x M matrix where N = size(im1,1)*size(im1,2), and M is the number
%% of correspondences calculated by the sift flow algorithm between the two images.
%% Each column of "all img1_indicators" represents a linearized version of the 2D image, with
%% a 1 representing a specific pixel
% ==================================================
%% "all_img2_indicators" is a K x M matrix where K = size(im2,1)*size(im2,2), and M is the
%% same as above.  Each column in "all_img2_indicators" is also an indicator, in correspondence with
%% the indicator in "all_img1_indicators" of the same row.  
cellsize=3;
gridspacing=1;
SIFTflowpara.alpha=2*255;
SIFTflowpara.d=40*255;
SIFTflowpara.gamma=0.005*255;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=2;
SIFTflowpara.topwsize=10;
SIFTflowpara.nTopIterations = 60;
SIFTflowpara.nIterations= 30;
imgsize = size(im1,1);

if isempty(im1_feats)
    im1_feats = get_pix_features(im1, feat_type, caffe_dir);
end
if isempty(im2_feats)
    im2_feats = get_pix_features(im2, feat_type, caffe_dir);
end
%% calculate the flow_field using SIFTflow
if strcmp(opt_flow_alg, 'SIFTflow')
[vx,vy,energylist]=SIFTflowc2f(im1_feats,im2_feats,SIFTflowpara);
%% calculate the flow field using DSP
elseif strcmp(opt_flow_alg, 'DSP')
[vx,vy] = DSPMatch(im1_feats, im2_feats); 
end

%% using the flow field, mark indicator matrices; no for loop
x_starts = repmat(linspace(1, imgsize, imgsize), [imgsize, 1]);
y_starts = x_starts';
x_ends = vx + x_starts;
y_ends = vy + y_starts;

y_starts = reshape(y_starts, 1, []);
x_starts = reshape(x_starts, 1, []);
x_ends = reshape(x_ends, 1, []);
y_ends = reshape(y_ends, 1, []);

invalid_x = find(x_ends >= imgsize | x_ends <= 0);
invalid_y = find(y_ends >= imgsize | y_ends <= 0);
invalids = union(invalid_x, invalid_y);

x_ends(invalids) = [];
y_ends(invalids) = [];
x_starts(invalids) = [];
y_starts(invalids) = [];

linear_inds_starts = sub2ind([imgsize, imgsize], y_starts, x_starts);
linear_inds_ends = sub2ind([imgsize, imgsize], y_ends, x_ends);


all_img2_indicators = zeros(imgsize^2, length(linear_inds_starts));
all_img1_indicators = zeros(imgsize^2, length(linear_inds_starts));
all_img1_indicators(sub2ind(size(all_img1_indicators),linear_inds_starts, linspace(1, length(linear_inds_starts), length(linear_inds_starts)))) = 1;
all_img2_indicators(sub2ind(size(all_img2_indicators),linear_inds_ends, linspace(1, length(linear_inds_starts), length(linear_inds_starts)))) = 1;



%% using the flow field, mark indicator matrices using for loop

%%
% all_img1_indicators = zeros(imgsize^2, imgsize^2);
% all_img2_indicators = zeros(imgsize^2, imgsize^2);
% entry = 1;


% for i=1:imgsize
%     for j=1:imgsize
%       img1_indicator = zeros(imgsize);
%       img1_indicator(i,j) = 1;
%       img1_indicator = reshape(img1_indicator, [], 1);
%       
%       img2_indicator = zeros(imgsize);
%       corres_y = i +vy(i,j);
%       corres_x = j+vx(i,j);
%       
%        if corres_y <= 0 || corres_y >= imgsize || corres_x <= 0 || corres_x >= imgsize
%           all_img1_indicators(:, entry) = zeros(imgsize^2,1);
%           all_img2_indicators(:, entry) = zeros(imgsize^2,1);
%           entry = entry + 1;
%            continue;
%        end
%       
%        img2_indicator(corres_y,corres_x) = 1;
%        
%       img2_indicator = reshape(img2_indicator, [], 1);
%       if length(img2_indicator) ~= imgsize^2
%           input('bad size');
%       end
%       
%       all_img1_indicators(:,entry) = img1_indicator;
%       all_img2_indicators(:,entry) = img2_indicator;
%       entry = entry+1;
%     end
% end

end

