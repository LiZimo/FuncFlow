function im1_feats = get_pix_features(im1, feat_type, caffe_dir)
cellsize=3;
gridspacing=1;
SIFTflowpara.alpha=2*255;
SIFTflowpara.d=40*255;
SIFTflowpara.gamma=0.005*255;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=2;
SIFTflowpara.topwsize=10;
SIFTflowpara.nTopIterations = 60;
SIFTflowpara.nIterations= 30;

imgsize = size(im1,1);

sift1 = mexDenseSIFT(im1,cellsize,gridspacing);

if strcmp(feat_type, 'conv4') || isnumeric(feat_type)
    
if exist(caffe_dir, 'dir')
    addpath(caffe_dir);

    conv4_feats_1 = compute_caffenet_features(im1, 'conv4', caffe_dir);   
    conv4_feats_1 = imresize(conv4_feats_1, [imgsize imgsize], 'bilinear');  
else 
    error('caffe_dir not valid \n');
end
    im1_feats = conv4_feats_1;

elseif strcmp(feat_type, 'sift')
    im1_feats = sift1;
elseif isreal(feat_type)
    im1_feats = cat(3, sift1, feat_type*conv4_feats_1);   
else 
    im1_feats = sift1;
end


end
