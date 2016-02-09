function out_struct = flow_from_functional_map(All_func_maps, All_eig_vecs, xsize, ysize)
% =========================================================
%% produces all pairwise optical flow maps from functional maps
% =========================================================
%% INPUTS:
% All_func_maps - (N x F x N x F cell, N is number of images, F is flip) Cell array containing all functional maps
% All_eig_vecs - (N x F cell) Cell array containing all basis vectors
% xsize - (double) image's xsize
% ysize - (double) image's ysize
% =========================================================
%% OUTPUTS
% pairvx - (N x N cell) contains all pairwise flow fields for x direction
% pairvy - same as above
% validpoints - (N x N cell), contains logical arrays expressing valid pixels in the flow field.
% avg_deviations - (N x N double) mean absolute deviation of each flow field
%% =========================================================
num_images = size(All_func_maps,1);
pairvx = cell(num_images, num_images);
pairvy = cell(num_images, num_images);
validpoints = cell(num_images, num_images);
avg_deviations = zeros(num_images);

parfor i = 1:num_images
    for j = 1:num_images
        funcmap = All_func_maps{i,1,j,1};
        basis1 = All_eig_vecs{i,1};
        basis2 = All_eig_vecs{j,1};
        
        [vx, vy, valid_points] = pairwise_flow_mean(funcmap, basis1, basis2, xsize, ysize);
        pairvx{i,j} = vx;
        pairvy{i,j} = vy;
        validpoints{i,j} = valid_points;
        avg_deviations(i,j) = mean(abs(vx(:))) + mean(abs(vy(:)));
    end
    fprintf('Finished all flowfields for image %d \n', i);
end

out_struct = struct;
out_struct.pairvx = pairvx;
out_struct.pairvy = pairvy;
out_struct.validpoints = validpoints;
out_struct.avg_deviations = avg_deviations;
end

function [vx, vy, valid_points] = pairwise_flow_max(funcmap, basis1, basis2, xsize, ysize)


start_indicators = eye(xsize*ysize); % represents all the pixel indicators from the first image
projected_start_indicators = start_indicators*basis1; % project each pixel in the first basis
sent_through_map = funcmap * projected_start_indicators'; % transfer the correspondences through the functional map
end_indicators = basis2 * sent_through_map; 
[~, lin_index_corresponding_points] = max(end_indicators, [], 1); % corresponding point is the max valued pixel on the other side

[corresponding_y, corresponding_x] = ind2sub([ysize,xsize], lin_index_corresponding_points); % linear indices to subscript indices
valid_points = (corresponding_x >= 0) & (corresponding_x <= xsize) & (corresponding_y >= 0) & (corresponding_y <= ysize);
valid_points = reshape(valid_points, [ysize, xsize]);

x_starts = repmat(linspace(1,xsize,xsize), ysize, 1);
y_starts = repmat(linspace(1,ysize,ysize)', 1, xsize);
x_ends = reshape(corresponding_x, [ysize,xsize]);
y_ends = reshape(corresponding_y, [ysize,xsize]);

vx = x_ends - x_starts; % subtract final - original to find the flow field
vy = y_ends - y_starts;


end

function [vx, vy, valid_points] = pairwise_flow_mean(funcmap, basis1, basis2, xsize, ysize)


start_indicators = eye(xsize*ysize); % represents all the pixel indicators from the first image
projected_start_indicators = start_indicators*basis1; % project each pixel in the first basis
sent_through_map = funcmap * projected_start_indicators'; % transfer the correspondences through the functional map
end_indicators = basis2 * sent_through_map; 
[~,sorted_end_indicators] = sort(end_indicators,1, 'descend');
top_k = sorted_end_indicators(1:40, :);

[corresponding_y, corresponding_x] = ind2sub([ysize,xsize], top_k); % linear indices to subscript indices
corresponding_x = round(mean(corresponding_x,1));
corresponding_y = round(mean(corresponding_y,1));


valid_points = (corresponding_x >= 0) & (corresponding_x <= xsize) & (corresponding_y >= 0) & (corresponding_y <= ysize);
valid_points = reshape(valid_points, [ysize, xsize]);

x_starts = repmat(linspace(1,xsize,xsize), ysize, 1);
y_starts = repmat(linspace(1,ysize,ysize)', 1, xsize);
x_ends = reshape(corresponding_x, [ysize,xsize]);
y_ends = reshape(corresponding_y, [ysize,xsize]);

vx = x_ends - x_starts; % subtract final - original to find the flow field
vy = y_ends - y_starts;


end









