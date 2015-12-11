function final_weights = init_graph_gist_nn(image_dir_name, imgsize, num_nn, flip)

%load images
images = dir([image_dir_name '/*.JPEG']);
if isempty(images)
    images = dir([image_dir_name '/*.bmp']);
end
if isempty(images)
    images = dir([image_dir_name '/*.jpg']);
end

%set gist params
param.imageSize = imgsize; % it works also with non-square images
param.orientationsPerScale = [8 8 8 8];
param.numberBlocks = 4;
param.fc_prefilt = 4;

all_gists = cell(length(images),flip);

for k = 1:flip

for i = 1:length(images)
    img = imread([image_dir_name '/' images(i).name]);
    if k == 2
        img = flip_image(img);
    end
    
    [gist, param] = LMgist(img, '', param);
    all_gists{i,k} = gist;

end
end

mat_all_gists_original = cell2mat(all_gists(:,1));
mat_all_gists_flip = cell2mat(all_gists(:,flip));


[IDX_orig, Distances_orig] = knnsearch(mat_all_gists_original,mat_all_gists_original, 'K', num_nn + 1);
[IDX_flip, Distances_flip] = knnsearch(mat_all_gists_flip, mat_all_gists_original, 'K', num_nn + 1);

All_dists = [Distances_orig(:); Distances_flip(:)];
All_dists(All_dists == 0) = [];
sigma = median(All_dists);

weights_orig = zeros(length(images));
for n = 1:length(images)
    for m = 1:num_nn - 1
        neighbor = IDX_orig(n, m + 1);
        weights_orig(n,neighbor) = exp( -norm(all_gists{n,1} - all_gists{neighbor,1})/(sqrt(2)*sigma));
    end
end

weights_flip = zeros(length(images));
for n = 1:length(images)
    for m = 1:num_nn
        neighbor = IDX_flip(n, m + 1);
        weights_flip(n,neighbor) = exp( -norm(all_gists{n,flip} - all_gists{neighbor,flip})/(sqrt(2)*sigma));
    end
end

final_weights = zeros(length(images), flip, length(images), flip);
final_weights(:,1,:,1) = weights_orig;
final_weights(:,flip,:,flip) = weights_orig;
final_weights(:,flip,:,1) = weights_flip;
final_weights(:,1,:,flip) = weights_flip;

end 
