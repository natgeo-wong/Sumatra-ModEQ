function GPS_xyzcov2rbsl(fileName1,fileName2,foutName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 GPS_xyzcov2rbsl.m                                       %
% read two xyzcov files to form baseline rbsl file                                        %
%										          %
% INPUT:                                                                                  %
% fileName1 & fileName2 - xyzcov files                                                    %
% 1         2   3   4   5      6      7      8      9      10                             %
% YEARMMDD  XX  YY  ZZ  XXErr  YYErr  ZZErr  corXY  corXZ  corYZ [m]                      %
% XXErr,YYErr,ZZErr - standard deviation                                                  %
% corXY,corXZ,corYZ - correlation                                                         % 
%              covXY                                                                      %
% corXY = ----------------                                                                %
%            XXErr*YYErr                                                                  %
%                                                                                         %
% OUTPUT: 									          %
% foutName - rbsl file                                                                    %
% rbsl format    							                  %
% 1        2         3        4                                                           %
% YEARMODY YEAR.DCML Baseline Baseline_err                                                %
%										          %
% first created by Lujia Feng Sat Jan  9 00:49:07 SGT 2016                                %
% last modified by Lujia Feng Sat Jan  9 01:46:14 SGT 2016                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin <= 2
   foutName = [];
end

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName1,'file'), error('GPS_xyzcov2rbsl ERROR: %s does not exist!',fileName1); end
if ~exist(fileName2,'file'), error('GPS_xyzcov2rbsl ERROR: %s does not exist!',fileName2); end

%%%%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%
fprintf(1,'\n.......... reading %s ...........\n',fileName1);
[ yearmmdd1,XX1,YY1,ZZ1,XXErr1,YYErr1,ZZErr1,corXY1,corXZ1,corYZ1 ] = GPS_readxyzcov(fileName1);

fprintf(1,'\n.......... reading %s ...........\n',fileName2);
[ yearmmdd2,XX2,YY2,ZZ2,XXErr2,YYErr2,ZZErr2,corXY2,corXZ2,corYZ2 ] = GPS_readxyzcov(fileName2);

%%%%%%%%%%%%%%%%%%% match dates %%%%%%%%%%%%%%%%
% find dates of the 2nd file in the 1st one
[ keepInd,~ ] = ismember(yearmmdd2,yearmmdd1);
yearmmdd2 = yearmmdd2(keepInd);
XX2     = XX2(keepInd);
YY2     = YY2(keepInd);
ZZ2     = ZZ2(keepInd);
XXErr2  = XXErr2(keepInd);
YYErr2  = YYErr2(keepInd);
ZZErr2  = ZZErr2(keepInd);
[ ~,locInd ] = ismember(yearmmdd2,yearmmdd1);

bb    = sqrt((XX1(locInd)-XX2).^2 + (YY1(locInd)-YY2).^2 + (ZZ1(locInd)-ZZ2).^2);
bbErr = sqrt(sqrt(XXErr1(locInd).^2 + XXErr2.^2).^2  ...
      + sqrt(YYErr1(locInd).^2 + YYErr2.^2).^2  ...
      + sqrt(ZZErr1(locInd).^2 + ZZErr2.^2).^2);

for ii=1:length(yearmmdd2)
   [ ~,~,decyr2(ii,1) ] = GPS_YEARMMDDtoDCMLYEAR(yearmmdd2(ii,1));
end

%%%%%%%%%% save rbsl files %%%%%%%%%%
scaleOut  = 1;
rbsl = [ yearmmdd2 decyr2 bb bbErr ];
if isempty(foutName)
   [ ~,bname1,~ ] = fileparts(fileName1);
   [ ~,bname2,~ ] = fileparts(fileName2);
   foutName = [ bname1 '-' bname2 '.rbsl' ];
end
fout = fopen(foutName,'w');
if ~isempty(scaleOut)
    fprintf(fout,'# SCALE2M %8.3e\n',scaleOut);
end
fprintf(fout,'# 1        2         3        4\n');
fprintf(fout,'# YEARMODY YEAR.DCML Baseline Baseline_err\n');
fprintf(fout,'%8.0f %14.6f %14.6f %14.6f\n',rbsl'); 
fclose(fout);
