function [ ] = GPS_vel_project(velName,str,scaleIn,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                GPS_vel_project.m                                        % 
% project velocities along a direction or perpendicular to a direction                    %
%                                                                                         %
% INPUT: 										  %
% (1) *.vel for models								          %
%   1   2   3   4      5  6  7  8   9   10  11     12 13  14 15  16  17  18               %
%   Sta Lon Lat Height VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D Cne Ceu Cnu              %
% Note: Cne is correlation coefficient between North and East uncertainties!		  %
%                                                                                         %
% (2) str - strike direction clockwise from N [deg]                                       %
%                                                                                         %
% OUTPUT: 4 new *.vel files                                                               %
% *.vel          - normal and parallel velocities replacing Vew & Vns + vertical velocity %
%   along-strike = new N +                                                                %
%   along-dip    = new E +                                                                %
% *_normal.vel   - direction-normal velocities for gmt                                    %
% *_parall.vel   - direction-parallel velocities for gmt                                  %
% *_vertical.vel - vertical velocities for gmt oblique projection                         %
%										          %
% first created by Lujia Feng Wed Nov  3 13:42:31 EDT 2010				  %
% separated from GPS_vel.m lfeng Wed Jun 19 18:01:06 SGT 2013                             %
% to be consistent with ENU, switch TP & TN lfeng Fri Mar 28 11:17:08 SGT 2014            %
% added scaleIn & scaleOut lfeng Mon Oct 20 17:17:01 SGT 2014                             %
% last modified by Lujia Feng Mon Oct 20 17:17:34 SGT 2014                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin <= 2
   scaleIn = []; scaleOut = [];
end

% read in the velocity file
fprintf(1,'\n.......... reading %s  ...........\n\n',velName);
[ siteList,vel ] = GPS_readvel(velName,scaleIn,scaleOut);
% fnum = 17 (up to all 3 correlation coeffs)
% fnum = 15; fnum = 14 if Cne ignored; fnum = 10 if T0 T0D T1 T1D Cne ignored
fnum = size(vel,2);
if fnum==0, return; end
if fnum~=10&&fnum~=14&&fnum~=15&&fnum~=17, error('GPS_vel_project ERROR: %s does not have the right format!',velName); end

% prepare 4 new velocity files
[ ~,basename,~ ] = fileparts(velName);
normalName = [ basename '_str' num2str(str,'%.0f') '_normal.vel' ];
parallName = [ basename '_str' num2str(str,'%.0f') '_parall.vel' ];
vertName   = [ basename '_str' num2str(str,'%.0f') '_vertical.vel' ];
pnName     = [ basename '_str' num2str(str,'%.0f') '.vel' ];
% both normal and parallel
fpn = fopen(pnName,'w'); 
fprintf(fpn,'# project %s velocities parallel and normal to strike %f \n',velName,str);
fprintf(fpn,'# 1   2   3   4    5  6  7  8   9   10  11     12 13  14 15    16\n');
fprintf(fpn,'# Sta Lon Lat Elev VP VN VU ErP ErN ErU Weight T0 T0D T1 T1D   Cpn\n');
fprintf(fpn,'# Elev in [m] Rate in [mm/yr] error in [mm/yr]   Cpn unitless\n');
% strike parallel
fp = fopen(parallName,'w');
fprintf(fp,'# project %s velocities parallel to strike %f \n',velName,str);
fprintf(fp,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
fprintf(fp,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
fprintf(fp,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');
fprintf(fp,'# Cne is correlation coefficient between north and east uncertainties [unitless]\n');
% strike normal
fn = fopen(normalName,'w'); 
fprintf(fn,'# project %s velocities normal to strike %f \n',velName,str);
fprintf(fn,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
fprintf(fn,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
fprintf(fn,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');
fprintf(fn,'# Cne is correlation coefficient between north and east uncertainties [unitless]\n');
% vertical
fv = fopen(vertName,'w'); 
fprintf(fv,'# project %s vertical velocities normal to strike %f \n',velName,str);
fprintf(fv,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16\n');
fprintf(fv,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne\n');
fprintf(fv,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');

siteNum = size(vel,1);
for ii = 1:siteNum
   site = siteList{ii}; 
   loc  = vel(ii,1:3);
   ew = vel(ii,4); errEW = vel(ii,7);
   ns = vel(ii,5); errNS = vel(ii,8);
   ud = vel(ii,6); errUD = vel(ii,9);
   % form the correlation coefficient between north and east 
   if fnum>=15 ccNE = vel(ii,15); else ccNE = 0; end
   [ parall,normal,errParall,errNormal,cc ] = GPS_vel2strike(ns,ew,errNS,errEW,ccNE,str);
   % both parallel and normal
   if fnum==10
      fprintf(fpn,'%4s %14.9f %14.9f %12.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %5f %5f %5f %5f %6.3f\n',...
                  site,loc,-normal,parall,ud,errNormal,errParall,errUD,vel(ii,10),[nan nan nan nan],cc);
   end
   if fnum>=14
      fprintf(fpn,'%4s %14.9f %14.9f %12.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %10d %12.6f %10d %12.6f %6.3f\n',...
                  site,loc,-normal,parall,ud,errNormal,errParall,errUD,vel(ii,10:14),cc);
   end
   % strike parallel 
   [ ns,ew,errNS,errEW,cc ] = GPS_vel2ne(parall,errParall,str);
   if fnum==10
      fprintf(fp,'%4s %14.9f %14.9f %12.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %5f %5f %5f %5f %6.3f\n',...
                  site,loc,ew,ns,ud,errEW,errNS,errUD,vel(ii,10),[nan nan nan nan],cc);
   end
   if fnum>=14
      fprintf(fp,'%4s %14.9f %14.9f %12.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %10d %12.6f %10d %12.6f %6.3f\n',...
                  site,loc,ew,ns,ud,errEW,errNS,errUD,vel(ii,10:14),cc);
   end
   % strike normal
   [ ns,ew,errNS,errEW,cc ] = GPS_vel2ne(normal,errNormal,str-90);
   if fnum==10
      fprintf(fn,'%4s %14.9f %14.9f %12.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %5f %5f %5f %5f %6.3f\n',...
                  site,loc,ew,ns,ud,errEW,errNS,errUD,vel(ii,10),[nan nan nan nan],cc);
   end
   if fnum>=14
      fprintf(fn,'%4s %14.9f %14.9f %12.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %10d %12.6f %10d %12.6f %6.3f\n',...
                  site,loc,ew,ns,ud,errEW,errNS,errUD,vel(ii,10:14),cc);
   end
   % vertical
   [ ns,ew,errNS,errEW,cc ] = GPS_vel2ne(ud,errUD,str-90);
   if fnum==10
      fprintf(fv,'%4s %14.9f %14.9f %12.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %5f %5f %5f %5f %6.3f\n',...
                  site,loc,ew,ns,ud,errEW,errNS,errUD,vel(ii,10),[nan nan nan nan],cc);
   end
   if fnum>=14
      fprintf(fv,'%4s %14.9f %14.9f %12.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %10d %12.6f %10d %12.6f %6.3f\n',...
                  site,loc,ew,ns,ud,errEW,errNS,errUD,vel(ii,10:14),cc);
   end
end
fclose(fn); fclose(fp); fclose(fpn); fclose(fv);
