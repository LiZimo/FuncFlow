function box = mask_to_box(mask)

xmin = min(find(logical(sum(mask))));
xmax = max(find(logical(sum(mask))));

ymin = min(find(logical(sum(mask'))));
ymax = max(find(logical(sum(mask'))));

box = [xmin ymin xmax ymax];

end
