function [ i,jj,EQsmfit ] = EQ_ana_bmfitsv1 (Files)

%                              EQ_svanalysis

mat_vare = zeros(length(Files),11);
parfor ii = 1 : length(Files)
    
    iiEQFile = Files(ii).name;
    EQsmfit = textread(['./GTdef_SV_Misfit/' iiEQFile],'%f','commentstyle','shell');
    EQsmfit = reshape(EQsmfit,11,[])';
    
    vare = EQsmfit(:,9); [ ~,i ] = max(vare);
    mat_vare(ii,:) = EQsmfit(i,:);
    
end
vare = mat_vare(:,9); [ ~,i ] = max(vare); jj = mat_vare(i,2);
bfitEQFile = Files(i).name;
EQsmfit = textread(['./GTdef_SV_Misfit/' bfitEQFile],'%f','commentstyle','shell');
EQsmfit = reshape(EQsmfit,11,[])';

end