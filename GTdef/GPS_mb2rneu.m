function [ ] = GPS_mb2rneu(siteName,nName,eName,uName,scaleIn,scaleOut,errRatio,tlim)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GPS_mb2rneu.m                                   %
% combine GAMIT mb output files to one rneu format file	                        %
%										%
% INPUT: 									%
% siteName - site name                                                          %
% nName    - file name of north component                                       %
% eName    - file name of east  component                                       %
% uName    - file name of vertical component                                    %
% GAMIT nData = N, eData = E, uData = U                                         %
% Format:									%
% 1         2               3     						%
% YEAR.DCML NORTH/EAST/VERT N_err/E_err/V_err                          		%
%										%
% scaleIn  - scale to meter in input fileName                                   %
%    if scaleIn = [], an optimal unit will be determined                        %
% scaleOut - scale to meter in output rneu                                      %
%    if scaleOut = [], units won't be changed                                   %
%										%
% errRatio - threshold for points being identified as outliers 			%
%            used by GPS_cleanup.m						%
%          =  3 usually								%
%	   <= 0 do not call GPS_cleanup						%
% tlim - time range that is kept in rneu files					%
%          = [ tmin tmax ] in decimal years					%
%          = [] use all data available                                          %
%                                                                               %
% OUTPUT: 									%
% SITE.rneu (my reduced format inherited from usgs raw .rneu)			%
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
%										%
% functions used: GPS_readmb, GPS_DCMLYEARtoYEARMMDD				%
% first created by Luija Feng @ EOS Mon Jul  4 13:09:59 SGT 2011                %
% added remove mean lfeng Fri Jul  8 11:29:37 SGT 2011				%
% used '' for all sites lfeng Mon Jul 18 16:59:31 SGT 2011			%
% added GPS_cleanup & GPS_saverneu lfeng Mon Aug 29 13:52:30 SGT 2011		%
% modified to be able to read files while uData doesn't have the same time	%
% column as nData and eData lfeng Fri Sep  9 14:29:23 SGT 2011			%
% added tlim lfeng Sun Nov 27 21:45:05 SGT 2011					%
% added repeatability check lfeng (with Louisa) Thu Jun 28 17:46:11 SGT 2012    %
% modified to make file naming more flexible lfeng Wed Apr 29 15:23:56 SGT 2015 %
% move check unit before remove outliers lfeng Thu Apr 30 01:39:29 SGT 2015     %
% last modified by Lujia Feng Thu Apr 30 01:39:36 SGT 2015                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rneuName = strcat(siteName,'.rneu');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1,'\n%s',siteName);
[ nData ] = GPS_readmb(nName); % output are column vectors in [m]
[ eData ] = GPS_readmb(eName); % output are column vectors in [m]
[ uData ] = GPS_readmb(uName); % output are column vectors in [m]
nNum = size(nData,1); eNum = size(eData,1); uNum = size(uData,1);

%%%%%%%%%%%%%%%%%%%%%%%% check if data repeated %%%%%%%%%%%%%%%%%%%%%
nDatanew = unique(nData,'rows'); nNumnew = size(nDatanew,1);
eDatanew = unique(eData,'rows'); eNumnew = size(eDatanew,1);
uDatanew = unique(uData,'rows'); uNumnew = size(uDatanew,1);
if nNum~=nNumnew 
   fprintf(1,'\nGPS_mb2rneu WARNING: %d repeated data lines in %s have been removed!\n',nNum-nNumnew,nName);
   nData = nDatanew; nNum = nNumnew;
end
if eNum~=eNumnew 
   fprintf(1,'\nGPS_mb2rneu WARNING: %d repeated data lines in %s have been removed!\n',eNum-eNumnew,eName);
   eData = eDatanew; eNum = eNumnew;
end
if uNum~=uNumnew 
   fprintf(1,'\nGPS_mb3rneu WARNING: %d repeated data lines in %s have been removed!\n',uNum-uNumnew,uName);
   uData = uDatanew; uNum = uNumnew;
end

%%%%%%%%%%%%%%% check if data consistent between components %%%%%%%%%%%%
if nNum~=eNum || nNum~=uNum || eNum~=uNum
   error('\nGPS_mb2rneu ERROR: %s %s %s do not have the same length!\n',nName,eName,uName);
end
decyr1 = nData(:,1); decyr2 = eData(:,1); decyr3 = uData(:,1);
if ~isequal(decyr1,decyr2,decyr3)
   error('\nGPS_mb2rneu WARNING: %s %s %s do not match!\n',nName,eName,uName);
end

%%%%%%%%%%%%%%% convert decimal year to YEARMMDD %%%%%%%%%%%%
yearmmdd = [];
for jj=1:nNum
   [ ymd,~,~,~,~ ] = GPS_DCMLYEARtoYEARMMDD(decyr1(jj));
   yearmmdd = [ yearmmdd; ymd ];
end

%%%%%%%%%%%%%%% keep data only within tlim %%%%%%%%%%%%
if ~isempty(tlim)
   ind = decyr1>=tlim(1) & decyr1<=tlim(2);
else
   ind = true(size(decyr1));
end

%%%%%%%%%%%%%% remove mean %%%%%%%%%%%%
nDataMean = mean(nData(ind,2));  
eDataMean = mean(eData(ind,2)); 
uDataMean = mean(uData(ind,2));
nData(:,2) = nData(:,2) - nDataMean;
eData(:,2) = eData(:,2) - eDataMean;
uData(:,2) = uData(:,2) - uDataMean;

rneu = [ double(yearmmdd) decyr1 nData(:,2) eData(:,2) uData(:,2) nData(:,3) eData(:,3) uData(:,3) ];
rneu = rneu(ind,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% check unit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if scale in the input file is not specified
if ~isempty(scaleOut)
    if isempty(scaleIn)
        errAvg = mean([ rneu(:,6);rneu(:,7);rneu(:,8) ]);
        valMax = max([ rneu(:,3);rneu(:,4);rneu(:,5) ]); 
        if errAvg>1e-5 && errAvg<0.05  % indicate it's m && zero errors
            scaleIn = 1;
        else
            scaleIn = 1e-3;  % indicate it's mm
        end
    end
    scale = scaleIn/scaleOut;
    rneu(:,3:8) = rneu(:,3:8)*scale;
end

%%%%%%%%%%%%%%% do initial cleanup if errRatio > 0 %%%%%%%%%%%%
if errRatio>0
   [ rneuNew,~ ] = GPS_cleanup(rneu,errRatio);
   rneu = rneuNew;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save rneu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1,'\n.......... GPS_mb2rneu: saving %s ...........\n',rneuName);
fout = fopen(rneuName,'w');
fprintf(fout,'# rneu converted from GAMIT %s, %s, and %s\n',nName,eName,uName);
fprintf(fout,'# mean %12.5f %12.5f %12.5f removed from N, E, and U\n',nDataMean,eDataMean,uDataMean);
fprintf(fout,'% SCALE2M is %8.3e\n',scaleOut);
fclose(fout);
% append 
GPS_saverneu(rneuName,'a',rneu,1);
