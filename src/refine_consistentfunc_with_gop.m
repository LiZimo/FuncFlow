function refined_mask = refine_consistentfunc_with_gop(input_mask, img)
init_gop;
gop_mex( 'setDetector', 'MultiScaleStructuredForest("/home/zimo/Documents/dense_functional_map_matching/external/gop_1.3/data/sf.dat")' );

 p = Proposal('max_iou', 1.0,...
             'unary', 5, 8, 'seedUnary()', 'backgroundUnary({0,15})',...
             'unary', 0, 10, 'zeroUnary()', 'backgroundUnary({0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15})' ...
             );

 os = OverSegmentation( img );
 props = p.propose( os );
 IOUs_box = zeros(1, size(props,1));
 IOUs_seg = zeros(1, size(props,1));
 gop_IOUs = zeros(1, size(props,1));
 boxes = os.maskToBox( props );
 
 %figure; imagesc(input_mask); input(' ');
 
 mean_input = mean(input_mask(input_mask~=0));
     for i=1:size(props,1)

               
        mask = props(i,:);
        
        m = double(uint8(mask( os.s()+1 )));
        
        m1= zeros(size(input_mask));
        xmin = boxes(i,1) +1;
        ymin = boxes(i,2) +1;
        xmax = boxes(i,3)+ 1;
        ymax = boxes(i,4)+ 1;
        m1(ymin:ymax, xmin:xmax) = 1;
        
        gop_IOUs(i) = seg_box_IOU(m);
        
        intersection_seg = sum(sum(m .* input_mask))^2 / sum(sum(logical(m .* input_mask))*mean_input);
        %union_seg =  sum(sum(abs(m - input_mask)));
        union_seg = sum(sum(logical(m + input_mask)));
        IOUs_seg(i) = intersection_seg/union_seg;
        
%         if isnan(intersection_seg/union_seg)
%             disp('hi');
%             
%         end
        
        intersection_box = sum(sum(m1 .* input_mask))^2/ sum(sum(logical(m1 .* input_mask))*mean_input);
        %intersection_box = sum(sum(m1 .* input_mask));
        %union_box =  sum(sum(abs(m-input_mask)));
        union_box = sum(sum(logical(m1 + input_mask)));
        IOUs_box(i) = intersection_box/union_box;
        
       % figure; imagesc(m); input(' ');
     end
input_mask_IOU = seg_box_IOU(input_mask);
avg_gop_IOU = mean(gop_IOUs);
std_gop_IOU = std(gop_IOUs);

box_weight = exp(-(avg_gop_IOU - input_mask_IOU)^2/ 2*std_gop_IOU^2);
%box_weight = 0.5;   
%IOUs = box_weight*IOUs_box + IOUs_seg;    
IOUs = IOUs_seg;
IOUs(isnan(IOUs)) = 0;

k = 3;
[~, ids] = sort(IOUs);
top_k = ids(end-k + 1:end);
top_props = cell(k,1);
for z = 1:k
   new_prop = props(top_k(z),:);
   new_mask = double(uint8(new_prop(os.s() + 1)));
   top_props{z} = reshape(new_mask, 1, []);
end

top_props = cell2mat(top_props);

total_intersection = prod(top_props,1);
intersect_mask = reshape(total_intersection, size(img,1), size(img,2));

top_IOUs = zeros(1,k);
for r = 1:k
   intersection = sum(top_props(r,:).*total_intersection);
   union = sum(logical(top_props(r,:) + total_intersection));
   top_IOUs(r) = intersection/union;
end

[~, bestid] = max(top_IOUs);
refined_mask = reshape(top_props(bestid,:), size(img,1), size(img,2)); % .* logical(input_mask);
%refined_mask = intersect_mask;

% [~, maxid] = max(IOUs);
% final_mask = props(maxid,:);
% refined_mask = double(uint8(final_mask(os.s()+1)));
%figure; imagesc(refined_mask); input(' ');



% figure;
% subplot(1,11,1); imshow(img);
% for t=1:10
%     next = props(ids(end - t + 1),:);
%     examp = double(uint8(next(os.s()+1)));
%     subplot(1,11,t+1); imshow(examp);
% end
% input(' ' );
end