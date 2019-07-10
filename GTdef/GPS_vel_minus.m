function [ ] = GPS_vel_minus(vel1Name,vel2Name,scaleIn,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    GPS_vel_minus.m				        % 
%                                                                                       %
% calculate vel1 - vel2                                                                 %
% make sure two *.vel files have the same units						%
%											%
% INPUT: 										%
% (1) vel1Name.vel                                                                      %
% (2) vel2Name.vel           								%
% velocity file format:                                                                 %
% 1   2   3   4      5  6  7  8   9   10  11     12 13  14 15    16  17  18         	%
% Sta Lon Lat Height VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D   Cne Ceu Cnu      	%
% Note: Cne is correlation coefficient between North and East uncertainties!		%
%											%
% OUTPUT: a new *.vel file that contains the results					%
%										        %
% first created by Lujia Feng Wed Nov  3 13:42:31 EDT 2010				%
% added scaleIn & scaleOut lfeng Mon Oct 20 17:17:01 SGT 2014                           %
% last modified by Lujia Feng Mon Oct 20 17:18:39 SGT 2014                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin <= 2
   scaleIn = []; scaleOut = [];
end

% read in the first velocity file
fprintf(1,'\n.......... reading %s  ...........\n',vel1Name);
[ siteList1,vel1 ] = GPS_readvel(vel1Name,scaleIn,scaleOut);
% fnum = 17 (up to all 3 correlation coeffs)
% fnum = 15; fnum = 14 if Cne ignored; fnum = 10 if T0 T0D T1 T1D Cne ignored
fnum1 = size(vel1,2);
if fnum1~=10&&fnum1~=14&&fnum1~=15&&fnum1~=17, error('GPS_vel_minus ERROR: %s does not have the right format!',vel1Name); end

% read in the second velocity file
fprintf(1,'\n.......... reading %s  ...........\n\n',vel2Name);
[ siteList2,vel2 ] = GPS_readvel(vel2Name);
fnum2 = size(vel2,2);
if fnum2~=10&&fnum2~=14&&fnum2~=15&&fnum2~=17, error('GPS_vel_minus ERROR: %s does not have the right format!',vel2Name); end

fnum = min([fnum1 fnum2]);

% prepare a new velocity file
[~,basename1,~] = fileparts(vel1Name);
[~,basename2,~] = fileparts(vel2Name);
outName = [ basename1 '-' basename2 '.vel' ];
fout    = fopen(outName,'w');
% write out the header
fprintf(fout,'# %s - %s\n',vel1Name,vel2Name);
fprintf(fout,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
fprintf(fout,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
fprintf(fout,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');
fprintf(fout,'# Cne is correlation coefficient between north and east uncertainties [unitless]\n');

% loop through stations in the first file
siteNum1 = size(siteList1,1);
for ii=1:siteNum1
   site = siteList1{ii};
   ind  = strncmpi(site,siteList2,4);	% true-1; false-0
   % no match site found
   if ~any(ind), continue; end
   % more than one match found
   if sum(ind)>1, fprintf(1,'GPS_vel_minus WARNING: Found %d %4s in %s!\n',sum(ind),site,vel2Name); break; end
   % one match found
   loc = vel1(ii,1:3); enu = vel1(ii,4:6)-vel2(ind,4:6); 
   err = sqrt(vel1(ii,7:9).^2+vel2(ind,7:9).^2);
   wgt = vel1(ii,10);
   if fnum==10
      fprintf(fout,'%4s %14.9f %14.9f %12.4f %10.4f %10.4f %10.4f %9.4f %7.4f %7.4f %6.1f\n',...
      site,loc,enu,err,wgt);
   end
   if fnum>=14
      fprintf(fout,'%4s %14.9f %13.9f %10.4f %10.4f %10.4f %10.4f %9.4f %7.4f %7.4f %4.1f %9d %12.6f %9d %12.6f\n',...
              site,loc,enu,err,wgt,vel1(ii,11:14));
   end
end
fclose(fout);
