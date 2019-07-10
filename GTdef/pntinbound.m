function B = pntinbound (data,s)



B = bwboundaries(data,'noholes'); l = length(B); num = zeros(l,1);

for ii = 1:l
    Bii = B{k}; xii = Bii(:,2); yii = Bii(:,1);
    num(ii) = numel(inpolygon(xii,yii,data(:,1),data(:,2)));
end

B = B{num>s};

end