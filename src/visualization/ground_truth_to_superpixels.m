function superpix_indicators = ground_truth_to_superpixels(labels, ground_truth)
%% =======================================
%% Takes a ground truth mask and rounds it to superpixel boundaries
% ========================================
%% INPUTS:
% labels - superpixel labels for each pixel in the original image
% ground_truth - binary mask of pixel-level ground truth
% =======================================
%% OUTPUTS:
% superpix_indicators - marks which superpixels indicate the ground truth
%% =======================================

num_pix = length(unique(labels));
superpix_indicators = zeros(1, num_pix);

% ========================================
%% At each iteration, we mask out one superpixel and 
%% see if the ground truth intersects it.  If so, we add the superpixel
for e = 1:num_pix
   superpix_mask = labels;
   superpix_mask(labels ~= e) = 0;
   superpix_mask(labels == e) = 1;
   if norm(double(superpix_mask) .* double(ground_truth)) > 0
       superpix_indicators(e) = 1;
   end
    
end


end