function [ lon,lat,EQin ] = EQ_ana_ins (EQinFiles,i,jj)



EQinFile = EQinFiles(i).name;
EQinmat = textread(EQinFile,'%f','commentstyle','shell');
EQinmat = reshape(EQinmat,19,[])'; EQin = EQinmat(jj,2:end);
lon = EQin(2); lat = EQin(3);

end