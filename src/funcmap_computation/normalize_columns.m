function normalized = normalize_columns(matrix)
%% normalizes columns of a matrix.  Straightforward.


[mr,mc] = size(matrix);
if (mr == 1)
  normalized = ones(1,mc);
else
  normalized =ones(mr,1)*sqrt(ones./sum(matrix.*matrix)).*matrix;
end

normalized(isnan(normalized)) = 0;

end
