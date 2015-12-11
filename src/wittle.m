function current = wittle(seg, iters)

current = seg;

for i=1:iters
nonzero = current(current~=0);

%disp(min(nonzero));
nonzero = 0.5*nonzero + 0.5;
nonzero = (nonzero - min(nonzero))/(max(nonzero) - min(nonzero));


current(current~=0) = nonzero;

end



end