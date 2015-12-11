function [all_img1_indicators,all_img2_indicators] = get_flip_correspondences(im1)
    
imgsize = size(im1,1);
all_img1_indicators = zeros(imgsize^2, imgsize^2);
all_img2_indicators = zeros(imgsize^2, imgsize^2);
entry = 1;
for i=1:imgsize
    for j=1:imgsize
      img1_indicator = zeros(imgsize);
      img1_indicator(i,j) = 1;
      img1_indicator = reshape(img1_indicator, [], 1);
      
      img2_indicator = zeros(imgsize);
      img2_indicator(i, end - j + 1) = 1;

      img2_indicator = reshape(img2_indicator, [], 1);
      
      all_img1_indicators(:,entry) = img1_indicator;
      all_img2_indicators(:,entry) = img2_indicator;
      entry = entry+1;
    end
end

end