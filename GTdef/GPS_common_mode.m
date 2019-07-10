function [ ] = GPS_common_mode(siteList,eqYMD,foffsetName,offsetScale)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            	GPS_common_mode.m				% 
% stack daily solution of sites to form a common mode time series		%
% in order to remove noise shared by the whole network				%
%										%	
% INPUT: 									%
% siteList - a list of GPS station names that are used to form common mode	%
% e.g. siteList = 'PSKI TRTK PPNJ PKRT LNNG MKMK LAIS MNNA MLKN' for Mentawai	%
% each site has data in *.rneu format						%
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
% 										%
% eqYMD - YEARMMDD for an earthquake e.g. 20101025				%
% foffsetName - *.vel format files that store offsets caused by earthquakes 	%
%               that need to be removed						%
% offsetScale - scale for offset e.g 1.0 or 0.7  				%
%										%
% OUTPUT: a new *.rneu file that contains common mode				%
%										%
% some work need to be done to make the script general				%
% first created by lfeng Mon Nov 28 17:38:10 SGT 2011				%
% last modified by lfeng Tue Nov 29 14:51:15 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(1,'\n.......... reading %s  ...........\n',foffsetName);
[ eqsiteList,vel ] = GPS_readvel(foffsetName);		% E N U

siteCell = regexp(siteList,'\s+','split');
siteStr  = char(siteCell);
siteNum  = size(siteStr,1);

for ii=1:siteNum
   rneu = [];
   site = siteStr(ii,:);
   frneuNameStruct = dir([ '*' site '*.rneu']);
   fnum = length(frneuNameStruct);
   if fnum==0
      error('GPS_common_mode ERROR: no %s rneu files exist in the current directory!',site);
   end
   if fnum>1
      error('GPS_common_mode ERROR: >1 %s rneu files exist in the current directory!',site);
   end
   frneuName = frneuNameStruct(1).name;
   % format check
   fprintf(1,'\n.......... reading %s  ...........\n',frneuName);
   [ rneu ] = GPS_readrneu(frneuName,[],[]);
   colNum = size(rneu,2);
   if colNum~=8, error('GPS_commod_mode ERROR: %s does not have the right format!',frneuName); end
   % remove offset for earthquakes
   siteInd = strcmpi(site,eqsiteList);
   if any(siteInd > 0.5)
      % cm to m, scale back to 70%
      offsetE = vel(siteInd,4)*1e-2/offsetScale; 
      offsetN = vel(siteInd,5)*1e-2/offsetScale; 
      offsetU = vel(siteInd,6)*1e-2/offsetScale; 
      rneuInd = rneu(:,1)>eqYMD;
      rneu(rneuInd,3) = rneu(rneuInd,3)-offsetN;
      rneu(rneuInd,4) = rneu(rneuInd,4)-offsetE;
      rneu(rneuInd,5) = rneu(rneuInd,5)-offsetU;
      %--------------------------- DEBUG ---------------------------
      % save file to test if offsets have been move correctly
      %foutName = [ site '.rneu' ];
      %GPS_saverneu(foutName,'w',rneu,1);
   end
   if ii==1  
      nnStack = rneu(:,3); eeStack = rneu(:,4); uuStack = rneu(:,5);
      dayStack = rneu(:,1); decyrStack = rneu(:,2);
      countStack = ones(size(dayStack));
   else
      % find exact dates matching two data sets
      [ ~,dayInd ] = ismember(rneu(:,1),dayStack);
      % get rid of data not in the 1st file
      keepInd = dayInd>0;
      rneu = rneu(keepInd,:);
      [ ~,dayInd ] = ismember(rneu(:,1),dayStack);
      % add up
      nnStack(dayInd) = bsxfun(@plus,nnStack(dayInd),rneu(:,3));
      eeStack(dayInd) = bsxfun(@plus,eeStack(dayInd),rneu(:,4));
      uuStack(dayInd) = bsxfun(@plus,uuStack(dayInd),rneu(:,5));
      countStack(dayInd) = countStack(dayInd)+1;
   end
end

% average noise
nnNoise = bsxfun(@rdivide,nnStack,countStack);
eeNoise = bsxfun(@rdivide,eeStack,countStack);
uuNoise = bsxfun(@rdivide,uuStack,countStack);

% save file to test if common mode noise has been extracted correctly
foutName = 'NOISE.rneu';
err  = zeros(size(nnNoise));
rneu = [ dayStack decyrStack nnNoise eeNoise uuNoise err err err ];
GPS_saverneu(foutName,'w',rneu,1);
