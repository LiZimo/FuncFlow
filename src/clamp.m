function val = clamp(x, a, b)

assert(a <= b);
val = x;

if x < a
    val = a;
elseif x > b
    val = b;
end
        

end
