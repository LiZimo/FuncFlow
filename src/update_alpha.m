function alphas = update_alpha(weights, lambda, X, img1_projected_indicators, img2_projected_indicators)
%% Given X, the weights, and the indicator-correspondences, will update the scaling factor "alphas"


img1_projected_indicators_weighted = img1_projected_indicators * weights;
img2_projected_indicators_weighted = img2_projected_indicators * weights;
num_correspondences = size(img1_projected_indicators,2);

alphas = zeros(1, num_correspondences);

for c=1:num_correspondences
    g = img2_projected_indicators_weighted(:,c);
    f = img1_projected_indicators_weighted(:,c);
    
    numerator =  g'*X*f + lambda;
    denominator = g'*g + lambda;
    
    alpha_c = numerator/denominator;
    alphas(c) = alpha_c;

end

alphas = diag(alphas);
end