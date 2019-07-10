function [ i,jj,EQsmfit ] = EQ_ana_bmfitsw2 (Files,lon1,lat1,d)

%                              EQ_svanalysis

mat_vare = zeros(length(Files),11);
parfor ii = 1 : length(Files)
    
    iiEQFile = Files(ii).name;
    EQsmfit = textread(['./GTdef_SW_Misfit/' iiEQFile],'%f','commentstyle','shell');
    EQsmfit = reshape(EQsmfit,11,[])';
    
    lon = EQsmfit(:,3); lat = EQsmfit(:,4);
    a = lon<lon1+d & lon>lon1-d & lat<lat1+d & lat>lat1-d;
    EQsmfit (a,:) = [];
    
    wvare = EQsmfit(:,11); [ ~,i ] = max(wvare);
    mat_vare(ii,:) = EQsmfit(i,:);
    
end
wvare = mat_vare(:,11); [ ~,i ] = max(wvare); jj = mat_vare(i,2);
bfitEQFile = Files(i).name;
EQsmfit = textread(['./GTdef_SW_Misfit/' bfitEQFile],'%f','commentstyle','shell');
EQsmfit = reshape(EQsmfit,11,[])';

end