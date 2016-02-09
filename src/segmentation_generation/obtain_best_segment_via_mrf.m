function [final_props] = obtain_best_segment_via_mrf(all_proposals, all_features, saliency_IOUs, pairwise_coeff, proportion_cutoff)





numNodes = length(all_proposals);
numLabels = length(all_proposals{1});


trunc_length = floor(numLabels * proportion_cutoff);

labels = zeros(1, numNodes*trunc_length);
nodes = zeros(1, numNodes*trunc_length);


sorted_IOUS = cell(1, length(saliency_IOUs));
for g =1:length(saliency_IOUs)
   image_g_IOUS = saliency_IOUs{g};
   [~, sorted_ids] = sort(image_g_IOUS, 'descend');
   sorted_ids_truncated = sorted_ids(1:trunc_length);
   sorted_IOUS{g} = sorted_ids_truncated;
end

el = 0;
for node =  1:numNodes
    for label = 1:trunc_length
       el = el + 1;      
       nodes(el)  = node;
       labels(el) = label;  
    end
end


D = zeros(numNodes * trunc_length, 1);
for i = 1:numNodes
    image_i_IOUs = saliency_IOUs{i};
    truncated_ids = sorted_IOUS{i};
    truncated_list = image_i_IOUs(truncated_ids);
    D((i-1)*trunc_length + 1:i*trunc_length) = truncated_list;
end



% M = zeros(numNodes * numLabels);
% for i = 1:numNodes*numLabels
%     for j = 1:numNodes*numLabels
%       %   M(i,j) =  A(nodes(i), nodes(j))*B(labels(i), labels(j));
%         M(i,j) = norm(all_features{nodes(i)}{labels(i)} - all_features{nodes(j)}{labels(j)});
%       
%     end
% end

M = zeros(numNodes * trunc_length);
for i = 1:numNodes
    truncated_ids_i = sorted_IOUS{i};
    for j = 1:numNodes
        truncated_ids_j = sorted_IOUS{j};

        image_i_features = cell2mat(all_features{i}(truncated_ids_i))';
        image_j_features = cell2mat(all_features{j}(truncated_ids_j))';
        
        block_ij = pdist2(image_i_features, image_j_features);
        
        M((i-1)*trunc_length + 1:i*trunc_length, (j-1)*trunc_length +1:j*trunc_length) = block_ij;
      
    end
end


M = pairwise_coeff * exp(-M/std(M(:)));
M(isnan(M)) = 0;
M(isinf(M)) = 0;
[sol, score1, V] = L2QP_MAP_inference( M, D, labels, nodes, 100, 400);

final_prop_indicators = reshape(sol, [trunc_length numNodes]);
[~, final_prop_indices] = sort(final_prop_indicators, 'descend');
final_props = cell(1, numNodes);

for z = 1:numNodes
   image_z_sorted_ids = sorted_IOUS{z};
   final_props{z} = all_proposals{z}{image_z_sorted_ids(final_prop_indices(1,z))}; 
end

end