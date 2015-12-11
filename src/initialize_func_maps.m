function [All_func_maps, Residuals] = initialize_func_maps( All_eig_vals, All_constraints,...
flip, saliency_weight, graph_weights)


%% ===== Set up Parameters: section 1 =====%
%fprintf('Section 1: Setting up Parameters ... \n');
num_eigenvecs = size(All_eig_vals{1,1}, 2);

%fprintf('Finished Section 1 \n');

num_images = size(All_eig_vals, 1);
All_func_maps = zeros(size(All_eig_vals,1),flip, size(All_eig_vals,1),flip, num_eigenvecs, num_eigenvecs);
Residuals = zeros(size(All_eig_vals,1),flip, size(All_eig_vals,1),flip);
for z = 1:num_images
    for z_flip = 1:flip

        eig_vals1 = All_eig_vals{z, z_flip};
        for y = 1:num_images

            for y_flip = 1:flip
                
                if graph_weights(z, z_flip, y,y_flip) < 0.01
                    continue;
                end

                eig_vals2 = All_eig_vals{y,y_flip};
                
                indicator_constraints_1 = All_constraints{z, z_flip, y, y_flip,1};
                indicator_constraints_2 = All_constraints{z, z_flip, y, y_flip,2};
                
                if size(indicator_constraints_1,2) == 0;
                  disp('trouble');
                end
                
                indicator_constraints_1(:, end) = indicator_constraints_1(:, end)*saliency_weight;
                indicator_constraints_2(:, end) = indicator_constraints_2(:,end)*saliency_weight;
                
                
                img1_projected_indicators = [indicator_constraints_1 ];
                img2_projected_indicators = [indicator_constraints_2 ];
                
                
                % set some parameters.  "Mu" is coefficient in front of ||X*eigs1 -eigs2*X||
                % sig is the "sigma squared" inside "zimo.pdf" to update the weights
                % lambda correspond to the term "lambda*(alpha_c - 1)^2", also in zimo.pdf%
                % these defaults work decently well
                
                num_iters = 10;
                mu = 1000;
                lambda = 10;
                sig = 1;
                
                % next initialize weights and alphas
                
                num_constraints = size(img1_projected_indicators,2);
                weights = eye(num_constraints);
                alphas = eye(num_constraints);
                
                % here is where the optimization is happening
                
                %fprintf('calculating a map \n');
%                tic;
%                 for r=1
 
                
                [X, residual] = update_X(weights, mu, alphas, img1_projected_indicators, img2_projected_indicators, eig_vals1, eig_vals2);

                %disp(y);
%              weights = update_weights(X, sig, img1_projected_indicators, img2_projected_indicators, alphas);
%                 alphas = update_alpha(weights, lambda, X, img1_projected_indicators, img2_projected_indicators);
%                 end
                
                All_func_maps(z,z_flip,y,y_flip,:,:) = X;
                Residuals(z,z_flip,y,y_flip) = residual;
                %toc;
            end
        end
    end
    %fprintf('Finished updating all functional maps for image (%d / %d) \n', z, length(images));
end
end