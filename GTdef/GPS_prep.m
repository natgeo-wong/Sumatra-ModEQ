function [ ] = GPS_prep(frneuName,foutExt,errRatio,tlim,ymdlim,figFlag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                GPS_prep.m                                     %
% do initial operation on *.rneu files including                                %
% (1) trim time series                                                          %
% (2) remove mean                                                               %
% (3) remove outliers                                                           %
%                                                                               %
% INPUT:                                                                        %
% frneuName - *.rneu files                                                      %
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
%                                                                               %
% foutExt  - file ext for rneu files                                            %
%          = if empty, then use default '_clean.rneu'                           %
% errRatio - threshold for points being identified as outliers                  %
%            used by GPS_cleanup.m                                              %
%          =  3 usually                                                         %
%          <= 0 do not call GPS_cleanup                                         %
% tlim     - time ranges specified that should be removed in rneu files         %
%          = [ tmin tmax ] matrix in decimal years                              %
%          do not trim if tlim is empty                                         %
% ymdlim   - yearmmdd ranges specified that should be removed in rneu files     %
%          = [ yearmmdd_min yearmmdd_tmax ] matrix                              %
%          do not trim if ymdlim is empty                                       %
% figFlag  - show figure or not                                                 %
%                                                                               %
% OUTPUT:                                                                       %
% *_clean.rneu file                                                             %
%                                                                               %
% first created by Lujia Feng Thu Mar 14 05:25:44 SGT 2013                      %
% added plot check lfeng Wed Nov 27 13:26:05 SGT 2013                           %
% changed tlim lfeng Thu Nov 28 13:37:26 SGT 2013                               %
% added figFlag lfeng Mon Feb 10 01:19:26 SGT 2014                              %
% added foutExt lfeng Tue May 19 00:02:50 SGT 2015                              %
% added ymdlim lfeng Tue Jul  7 12:46:42 SGT 2015                               %
% last modified by Lujia Feng Tue Jul  7 12:52:22 SGT 2015                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ ~,basename,~ ] = fileparts(frneuName);
if isempty(foutExt)
    foutName = [ basename '_clean.rneu' ];
else
    foutName = [ basename foutExt ];
end

%%%%%%%%%%%%%%% read in rneu %%%%%%%%%%%%
scaleIn  = 1; 
scaleOut = 1;
[ rneu ] = GPS_readrneu(frneuName,scaleIn,scaleOut);
rneuRaw  = rneu;

%%%%%%%%%%%%%%% do initial cleanup if errRatio > 0 %%%%%%%%%%%%
[ rneuKeep,rneuRemCell ] = GPS_cleanup(rneu,errRatio);
rneu = rneuKeep;

%%%%%%%%%%%%%%% remove data within tlim %%%%%%%%%%%%
if ~isempty(tlim)
    limNum  = size(tlim,1);
    for ii=1:limNum
        decyr   = rneu(:,2);
        indRem  = decyr>=tlim(ii,1) & decyr<=tlim(ii,2);
        indKeep = ~indRem;
        rneu    = rneu(indKeep,:);
    end
end

%%%%%%%%%%%%%%% remove data within ymdlim %%%%%%%%%%%%
if ~isempty(ymdlim)
    limNum  = size(ymdlim,1);
    for ii=1:limNum
        ymd     = rneu(:,1);
        indRem  = ymd>=ymdlim(ii,1) & ymd<=ymdlim(ii,2);
        indKeep = ~indRem;
        rneu    = rneu(indKeep,:);
    end
end

%%%%%%%%%%%%%%% plot to check %%%%%%%%%%%%
% plot 1 - data kept
rneuCell  = { rneuKeep; rneu };
lineCell  = {};
markCell  = { 'errorbar'; 'errorbar' };
sizeCell  = { 3; 3 };
colorCell = { 'r';[0.5 0.5 0.5; 0 1 0]  };
GPS_plotNrneu([basename '_clean.ps'],figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,{},{},scaleOut);
% plot 2 - data removed in steps
rneuCell  = [ rneuRaw; rneuRemCell([1 3 2]) ];
lineCell  = {};
markCell  = { 'errorbar'; 'errorbar'; 'errorbar'; 'errorbar' };
sizeCell  = { 3; 3; 3; 3 };
colorCell = { [0.5 0.5 0.5; 0 1 0]; 'k'; 'r'; 'b' };
GPS_plotNrneu([basename '.ps'],figFlag,rneuCell,lineCell,markCell,sizeCell,colorCell,{},{},scaleOut);

%%%%%%%%%%%%%%% remove mean %%%%%%%%%%%%
NNmean = mean(rneu(:,3));
EEmean = mean(rneu(:,4));
UUmean = mean(rneu(:,5));
rneu(:,3) = rneu(:,3) - NNmean;
rneu(:,4) = rneu(:,4) - EEmean;
rneu(:,5) = rneu(:,5) - UUmean;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save rneu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fout = fopen(foutName,'w');
fprintf(fout,'# mean %12.5f %12.5f %12.5f removed from N, E, and U\n',NNmean,EEmean,UUmean);
fclose(fout);
% append 
GPS_saverneu(foutName,'a',rneu,1);
