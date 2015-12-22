function [laplcn, D_half] = ICS_laplacian_nf(rgbimage, radius, sigmax, sigmav)
%% =====================================
%% Computes laplacian for an image.  
% For more information, refer to section 2 of attached pdf
% and see <http://www.cs.berkeley.edu/~malik/papers/SM-ncut.pdf>
% ======================================
%% INPUTS:
% rgbimage - (H x W x 3 double), an rgb image
% radius - (int) pixel radius to use when computing the edge weights
% sigmax - value of sigma to use in distance term for edge weight
% sigmav - value of sigma to use in intensity term for edge weight
% ======================================
%% OUTPUTS:
% laplcn - ((H * W) x (H * W) double) the normalized laplacian for the image
% D_half - ((H * W) x (H * W) double) the diagonal of un-normalized the laplacian
%% ======================================

if nargin < 2
    radius = 1;
end

image = double(rgbimage);
all_starts = {};
all_ends = {};
all_vals = {};

%% =======================================
% the strategy here is to shift the image a certain number of spaces, then
% subtract it from itself before putting it through the gaussian.  This
% way, we can avoid too many nested forloops and it is parallelizable

% too annoying to explain in detail.  Look through it if you want.
for i1=1:2*radius + 1
    i = i1 - radius - 1;
    width = ceil(sqrt(radius^2 - i^2+1));
    starts = [];
    ends = [];
    vals = [];
    for j = -width:width
        if i == 0 && j == 0
            continue;
        end
        
        section = image(1+max(i,0):end+min(i,0), 1+max(j,0):end + min(j,0),:);
        shift = zeros(size(image,1),size(image,2),size(image,3),2);
        shift(1 - min(i,0):end-max(i,0),1-min(j,0):end-max(j,0),:,1) = section;
        shift(1 - min(i,0):end-max(i,0),1-min(j,0):end-max(j,0),:,2) = 1;
        
        weights = - gaussian_vect(image,shift(:,:,:,1), sigmav);
        
        dist=sqrt(i^2 + j^2);
        
  
        weights = weights*exp(-dist^2/(  (sigmax)^2 ) );

            
        weights(sum(shift(:,:,:,2),3)==0) = 0;
        start_indices = find(weights)';
        end_indices = start_indices + j*size(image,1) + i;
        val = weights(weights~=0);
    
        starts(end+1:end+length(start_indices)) = start_indices;
        ends(end+1:end+length(end_indices)) = end_indices;
    
        vals(end+1:end+length(val)) = val';
    end
    
    all_starts{i1} = starts;
    all_ends{i1} = ends;
    all_vals{i1} = vals;
end
% =============================================


all_starts = cell2mat(all_starts);
all_ends = cell2mat(all_ends);
all_vals = cell2mat(all_vals);


laplcn = sparse([all_starts all_ends], [all_ends all_starts], [all_vals all_vals]);
laplcn = (laplcn + laplcn')/2;
assert(issymmetric(laplcn));

% down the diagonal
for i=1:size(laplcn)
    laplcn(i,i) = -sum(laplcn(i,:));
end

% now we normalize it
d = diag(laplcn);
D_half = diag(1./sqrt(d));
assert(issymmetric(laplcn));
laplcn = sparse(D_half*laplcn*D_half);
laplcn = (laplcn + laplcn')/2;
assert(issymmetric(laplcn));
end

function val = gaussian_vect(a,b,sigma)
sq_diff = (a-b).^2;
val = exp(-sum(sq_diff,3)/(sigma^2));

end


