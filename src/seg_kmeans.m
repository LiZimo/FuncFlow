function mask = seg_kmeans (seg)

% use kmeans to segment into foreground and background
scaled_seg = (seg - min(seg(:)))/(max(seg(:)) - min(seg(:)));

[id, c] = kmeans(scaled_seg(:), 2);
var1 = var(scaled_seg(id == 1));
var2 = var(scaled_seg(id == 2));
[~, minvar_id] = min([var1 var2]);

if c(minvar_id) > mean(c)
    mask = 1-scaled_seg;
else
    mask = scaled_seg;
end

mask(id == minvar_id) = 0;

% filter = [1/sqrt(2) 1 1/sqrt(2); 1 0 1; 1/sqrt(2) 1 1/sqrt(2)];
% for c = 1:4
%     mask = conv2(mask, filter, 'same');
%     %mask = wittle(mask, 200);
% end

mask(id == minvar_id) = 0;

% within foreground, use kmeans again to make the bright region more bright


foreground = mask(mask~=0);
foreground_size = sum(logical(foreground(:)));


[id2, c2] = kmeans(foreground(:),2);
[~, maxval_id] = max(c2);
% foreground(id2 == maxval_id) = 1;
% foreground(id2 ~= maxval_id) = 0.5;
mask(mask~=0) = foreground;
mask = wittle(mask, 1);

% filter = [1/sqrt(2) 1 1/sqrt(2); 1 0 1; 1/sqrt(2) 1 1/sqrt(2)];
% for c = 1:2
%     mask = conv2(mask, filter, 'same');
% end
% 
% mask = wittle(mask, 1);
%






% mask(mask~=0) = (mask(mask~=0) - mean(mask(mask~=0)))/std(mask(mask~=0));
%mask(mask~=0) = (mask(mask~=0) - min(mask(:)))/(max(mask(:)) - min(mask(:)));
%mask(mask~=0) = 0.9*mask(mask~=0) + 0.1;

% all_mask_vals = mask(mask~=0);
% mask_mad = median(abs(all_mask_vals - median(all_mask_vals)));
% mask_mad = mask_mad/mean(all_mask_vals);

%mask(mask~=0) = (1-exp(-mask_mad))*mask(mask~=0) + exp(-mask_mad);

end