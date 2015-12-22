function current = wittle(heatmap, iters)
%% ==========================================
%% scales heatmap to range [0,1] and then removes the smallest element.
%% does this iters number of times
%% ==========================================
current = heatmap;
for i=1:iters
    nonzero = current(current~=0);
    nonzero = 0.5*nonzero + 0.5;
    nonzero = (nonzero - min(nonzero))/(max(nonzero) - min(nonzero));
    current(current~=0) = nonzero;    
end
end