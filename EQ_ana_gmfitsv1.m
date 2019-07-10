function [ jj,EQsmfit ] = EQ_ana_gmfitsv1 (Files,i)

%                              EQ_svanalysis

bfitEQFile = Files(i).name;
EQsmfit = textread(bfitEQFile,'%f','commentstyle','shell');
EQsmfit = reshape(EQsmfit,11,[])';
vare = EQsmfit(:,9); [ ~,i ] = max(vare); jj = EQsmfit(i,2);

end