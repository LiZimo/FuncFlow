function IOU = seg_box_IOU(mask)

xmin = min(find(logical(sum(mask))));
xmax = max(find(logical(sum(mask))));

ymin = min(find(logical(sum(mask'))));
ymax = max(find(logical(sum(mask'))));


box_mask = zeros(size(mask));
box_mask(ymin:ymax, xmin:xmax) = 1;

intersection = sum(logical(box_mask .* mask));
union = sum(logical(box_mask + mask));
IOU = intersection/union;
end