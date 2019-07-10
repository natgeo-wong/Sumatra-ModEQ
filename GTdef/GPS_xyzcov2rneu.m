function [ ] = GPS_xyzcov2rneu(finName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_xyzcov2rneu.m                                  %
% convert geocentric XYZ coordinate in *.xyzcov                                 %
% to local NEU coordinate and store them in rneu files                          %
%                                                                               %
% INPUT:                                                                        %
% finName - SITE.xyzcov                                                         %
% if site = '' meaning running for all *.xyzcov files in the current dir  	%
%                                                                               %
% *.xyzcov FORMAT                                                               %
% 1         2   3   4   5      6      7      8      9      10                   %
% YEARMMDD  XX  YY  ZZ  XXErr  YYErr  ZZErr  corXY  corXZ  corYZ [m]            %
% XXErr,YYErr,ZZErr - standard deviation                                        %
% corXY,corXZ,corYZ - correlation                                               %
%              covXY                                                            %
% corXY = ----------------                                                      %
%            XXErr*YYErr                                                        %
%                                                                               %
% OUTPUT:                                                                       %
% SITE.rneu (my reduced format inherited from usgs raw .rneu)                   %
% 1        2         3     4    5    6     7     8                              %
% YEARMMDD YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
% all in [m]                                                                    %
% Note: output errors probably underestimated!                                  %
%                                                                               %
% first created by Lujia Feng Wed Mar 13 05:38:38 SGT 2013                      %
% changed stacov to xyzcov to avoid conflict with GIPSY stacov format           %
% last modified by Lujia Feng Fri Mar 22 10:23:46 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%% check if for all *.rneu files %%%%%%%%%%%%%%%%%%%%%%%
if isempty(finName)
   allNamesStruct = dir('*.xyzcov');	% not regexp \. here
else
   allNamesStruct = dir(finName);	% * like linux system can be used in finName
end

fnum = length(allNamesStruct);
if fnum==0, error('GPS_xyzcov2rneu ERROR: no xyzcov files exist in the current directory satisfying input!'); end

for ii=1:fnum
   xyzcovName = allNamesStruct(ii).name;
   [ ~,basename,~ ] = fileparts(xyzcovName);
   rneuName = [ basename '.rneu' ];
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n.......... reading %s ...........\n',xyzcovName);
   [ yearmmdd,XX,YY,ZZ,XXErr,YYErr,ZZErr,corXY,corXZ,corYZ ] = GPS_readxyzcov(xyzcovName);
   for ii=1:length(yearmmdd)
       [ year,doy,decyr(ii,1) ] = GPS_YEARMMDDtoDCMLYEAR(yearmmdd(ii,1));
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%% find the changes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   [ lat0,lon0,hh0 ] = XYZ2LLd(XX(1),YY(1),ZZ(1));
   XX = XX - XX(1); YY = YY - YY(1); ZZ = ZZ - ZZ(1); 

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%% from changes in XYZ to NEU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   [ NN,EE,UU,NNErr,EEErr,UUErr ] = XYZ2NEUd(lat0,lon0,XX,YY,ZZ,XXErr,YYErr,ZZErr,corXY,corXZ,corYZ);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%% save rneu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n.......... saving %s ...........\n',rneuName);
   fout = fopen(rneuName,'w');
   fprintf(fout,'# rneu converted from %s\n',xyzcovName);
   fprintf(fout,'# origin is lon=%.9f lat=%.9f height=%.4f\n',lon0,lat0,hh0);
   fprintf(fout,'# 1        2         3     4    5    6     7     8\n');
   fprintf(fout,'# YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err  [m]\n');
   for ii=1:length(yearmmdd)
      fprintf(fout,'%8d %14.6f %12.5f %12.5f %12.5f %12.5f %8.5f %8.5f\n',...
              yearmmdd(ii),decyr(ii),NN(ii),EE(ii),UU(ii),NNErr(ii),EEErr(ii),UUErr(ii)); 
   end
   fclose(fout);
end
