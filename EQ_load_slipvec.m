function [ slipvec ] = EQ_load_slipvec (rakeii,data,size)



rs = data.slip(3);

rakeii = mod(rakeii,360);
ss = rs * cosd(rakeii);

if rakeii >= 0 && rakeii <= 180
    ds = rs * sind(rakeii); ts = 0;
else
    ts = rs * sind(rakeii); ds = 0;
end

slip = [ rs ss ds ts ]; slipvec = repmat (slip,size,1);

end