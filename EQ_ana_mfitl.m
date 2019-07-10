function [ EQlmfit ] = EQ_ana_mfitl (EQmfitFiles,i)



bfitEQFile = EQmfitFiles(i).name;
EQlmfit = textread(bfitEQFile,'%f','commentstyle','shell');
EQlmfit = reshape(EQlmfit,11,[])';

end