function [ i,jj,EQsmfit ] = EQ_ana_bmfitsw1 (Files)

%                              EQ_svanalysis

mat_vare = zeros(length(Files),11);
parfor ii = 1 : length(Files)
    
    iiEQFile = Files(ii).name;
    EQsmfit = textread(['./GTdef_SW_Misfit/' iiEQFile],'%f','commentstyle','shell');
    EQsmfit = reshape(EQsmfit,11,[])';
    
    wvare = EQsmfit(:,11); [ ~,i ] = max(wvare);
    mat_vare(ii,:) = EQsmfit(i,:);
    
end
wvare = mat_vare(:,11); [ ~,i ] = max(wvare); jj = mat_vare(i,2);
bfitEQFile = Files(i).name;
EQsmfit = textread(['./GTdef_SW_Misfit/' bfitEQFile],'%f','commentstyle','shell');
EQsmfit = reshape(EQsmfit,11,[])';

end