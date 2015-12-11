
% example of how to call gbvs with default params

imdir = dir('/home/zimo/Documents/dense_functional_map_matching/data/face/*.bmp');

for i = 1:7
figure;
img = imread(['/home/zimo/Documents/dense_functional_map_matching/data/face/' imdir(i).name]);
out_gbvs = gbvs(img);
out_itti = ittikochmap(img);


subplot(1,2,1);
imshow(img);
title('Original Image');

subplot(1,2,2);
show_imgnmap(img,out_gbvs);
title('GBVS map overlayed');

% subplot(1,3,3);
% show_imgnmap(img,out_itti);
% title('Itti/Koch map overlayed');

% 
% subplot(2,3,5);
% imshow( out_gbvs.master_map_resized );
% title('GBVS map');
% 
% subplot(2,3,6);
% imshow(out_itti.master_map_resized);
% title('Itti/Koch map');
% input('next \n');

end

