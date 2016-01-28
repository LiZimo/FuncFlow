function refined_heatmap = remove_bg (heatmap)
%% ==========================================================
%% Use kmeans to segment into foreground and background
% ===========================================================
%% INPUT:
% heatmap - (H x W double) heatmap representing confidence of image object
% ===========================================================
%% OUTPUT:
% refined_heatmap - (H x W double) heatmap after background is set to 0 via kmeans,
% the map is sent through convolution and the values are normalized
%% ============================================================

% =================================
%% scale heatmap to [0 ,1 ]
scaled_heatmap = (heatmap - min(heatmap(:)))/(max(heatmap(:)) - min(heatmap(:)));
% ===============================================================
%% Run kmeans and eliminate cluster with lower variance.  The eliminated cluster is the background
[id, c] = kmeans(scaled_heatmap(:), 2);
var1 = var(scaled_heatmap(id == 1));
var2 = var(scaled_heatmap(id == 2));
[~, minvar_id] = min([var1 var2]);
if c(minvar_id) > mean(c)
    refined_heatmap = 1-scaled_heatmap;
else
    refined_heatmap = scaled_heatmap;
end
refined_heatmap(id == minvar_id) = 0;
%===============================================================
%% Convolve to smooth it out a little
filter = [1/sqrt(2) 1 1/sqrt(2); 1 2 1; 1/sqrt(2) 1 1/sqrt(2)];
% for c = 1:1
%     refined_heatmap = conv2(refined_heatmap, filter, 'same');
% end
refined_heatmap(id == minvar_id) = 0;
% ===============================================================
foreground = refined_heatmap(refined_heatmap~=0);
foreground_size = sum(logical(foreground(:)));
[id2, c2] = kmeans(foreground(:),2);
[~, maxval_id] = max(c2);
refined_heatmap(refined_heatmap~=0) = foreground;
refined_heatmap = wittle(refined_heatmap, 1);
end