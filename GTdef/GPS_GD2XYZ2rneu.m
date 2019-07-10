function [ ] = GPS_GD2XYZ2rneu(finName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_GD2XYZ2rneu.m				        %
% convert geodetic (lon,lat,height) in U of Miami GD files 			%
% first to geocentric XYZ coordinate 						%
% then to local NEU coordinate and store them in rneu files			%
%										%
% INPUT: 									%
% finName - SITE.GD (miami GIPSY GD format)					%
% if site = '' meaning running for all *.gd files in the current dir  		%
%										%
% GD FORMAT									%
% 1     2    3          4           5          6        7           8           %
% DATE  GD   Lat(deg)+/-Sigma(m)    Lon(deg)+/-Sigma(m) Height(m)+/-Sigma(m)    %
%                                                                               %
% OUTPUT: 									%
% SITE.rneu (my reduced format inherited from usgs raw .rneu)			%
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
% all in [m]                                                                    %
%										%
% first created by lfeng Thu Mar  3 01:37:07 EST 2011				%
% used "dir" instead of "ls" lfeng Sat Mar  5 22:01:47 EST 2011			%
% corrected the wrong alphabetic order lfeng Sat Mar  5 22:46:46 EST 2011	%
% use 5 digits instead 4 digits lfeng Mon Jul  4 15:34:00 SGT 2011		%
% used '' to imply all files instead of 'all.GD' Fri Jul 15 18:01:20 SGT 2011	%
% last modified by lfeng Fri Jul 15 18:03:41 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%% check if for all *.rneu files %%%%%%%%%%%%%%%%%%%%%%%
if isempty(finName)
   allNamesStruct = dir('*.GD');	% not regexp \. here
else
   allNamesStruct = dir(finName);	% * like linux system can be used in finName
end

fnum = length(allNamesStruct);
if fnum==0, error('GPS_GD2XYZ2rneu ERROR: no GD files exist in the current directory satisfying input!'); end

for ii=1:fnum
   GD_name = allNamesStruct(ii).name;
   site = strtok(GD_name,'.');	% noly works for names without "."
   rneu_name = strcat(site,'.rneu');
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n%s',site);
   fprintf(1,'\n.......... reading %s ...........\n',GD_name);
   [ day,time,lat,lon,height,ns_err,ew_err,ud_err ] = GPS_readGD(GD_name);	% output are column vectors in [m]

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%% convert from geodetic to XYZ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   [XX,YY,ZZ] = LL2XYZd(lat,lon,height);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%% find the changes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   lat0 = lat(1); lon0 = lon(1); hh0 = height(1);
   XX = XX - XX(1); YY = YY - YY(1); ZZ = ZZ - ZZ(1); 

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%% from changes in XYZ to NEU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   [ NN,EE,UU ] = XYZ2NEUd(lat0,lon0,XX,YY,ZZ);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%% save rneu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n.......... saving %s ...........\n',rneu_name);
   fout = fopen(rneu_name,'w');
   fprintf(fout,'# rneu converted from %s\n# origin is lon=%.9f lat=%.9f height=%.4f\n',GD_name,lon0,lat0,hh0);
   fprintf(fout,'# 1        2         3     4    5    6     7     8\n# YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err  [m]\n');
   for ii=1:length(day)
      fprintf(fout,'%8d %14.6f %12.5f %12.5f %12.5f %12.5f %8.5f %8.5f\n',day(ii),time(ii),NN(ii),EE(ii),UU(ii),ns_err(ii),ew_err(ii),ud_err(ii)); 
   end
   fclose(fout);
end
