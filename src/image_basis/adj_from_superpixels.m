function adj_matrix = adj_from_superpixels(labeled_img, type, orig_img)
%% ===================================================================
%% changes a superpixeled image into an adjacency matrix of the superpixels
%% Adjacency is defined as sharing a border
% Uses convolution filter to discover neighboring superpixels
% pretty uninteresting to explain, hopefully you can figure it out by
% reading.
% ====================================================================
%% Inputs:
% labeled_img - (H x W double) array with the same dimensions as your image.  The
% value at (i,j) represents what superpixel to which the (i,j)th pixel
% belongs

% type - a string of different types of adjacency to calculate.
%     'logical' - puts a 1 in (l,m) if region l is adjacent to region m
%     'boundary' - puts the boundary length between (l,m)
%     'intensity' - puts the difference in average intensity between the two regions
%========================================================================
%% Outputs: 
% adj_matrix - (N x N double, N is number of superpixels) the desired adjacency matrix
%% ======================================================================

if nargin < 2
    type = 'logical';
end

if ~strcmp(type, 'intensity')
    orig_img = 0;
end

adj_conv_filter = [1 1 1; 1 0 1; 1 1 1];
regions = unique(labeled_img);

adj_matrix = zeros(max(regions));

for i = 1:length(regions)
    row = zeros(1,max(regions));
    mask_i = conv2(double(labeled_img == i),adj_conv_filter, 'same') > 0;
    highlighted_region = labeled_img(mask_i);
    adjacent_regions = unique(highlighted_region);
    
    if strcmp(type, 'logical')
        row(adjacent_regions) = 1;
    end
    
    if strcmp(type, 'boundary')
        for r = 1:length(adjacent_regions)
            count = sum(sum(logical(labeled_img(mask_i) == adjacent_regions(r))));
            row(adjacent_regions(r)) = count;
        end
    end
    
    if strcmp(type, 'intensity')
        red = orig_img(:,:,1);
        green = orig_img(:,:,2);
        blue = orig_img(:,:,3);
        colors = {red, green, blue};
        for c = 1:length(colors)
            color = colors{c};
            for r=1:length(adjacent_regions)
                intensity_i = sum(sum(color(labeled_img == i)))/sum(sum(logical(color(labeled_img == i))));
                intensity_r = sum(sum(color(labeled_img == adjacent_regions(r))))/sum(sum(logical(color(labeled_img == adjacent_regions(r)))));
                row(adjacent_regions(r)) = row(adjacent_regions(r)) + (intensity_i - intensity_r)^2;
            end
        end
    end
    
    adj_matrix(i,:) = row;
end

adj_matrix = (adj_matrix + adj_matrix')/2;
adj_matrix(1:max(regions)+1:max(regions)^2) = 0;

end