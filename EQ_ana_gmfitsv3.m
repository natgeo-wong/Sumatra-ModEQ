function [ jj,EQsmfit ] = EQ_ana_gmfitsv3 (Files,i,lon1,lat1,lon2,lat2,d)

%                              EQ_svanalysis

bfitEQFile = Files(i).name;
EQsmfit = textread(bfitEQFile,'%f','commentstyle','shell');
EQsmfit = reshape(EQsmfit,11,[])';

lon = EQsmfit(:,3); lat = EQsmfit(:,4);
a = lon<lon1+d & lon>lon1-d & lat<lat1+d & lat>lat1-d;
b = lon<lon2+d & lon>lon2-d & lat<lat2+d & lat>lat2-d;
EQsmfit (a|b,:) = [];
    
vare = EQsmfit(:,9); [ ~,i ] = max(vare); jj = EQsmfit(i,2);
EQsmfit = textread(bfitEQFile,'%f','commentstyle','shell');
EQsmfit = reshape(EQsmfit,11,[])';

end