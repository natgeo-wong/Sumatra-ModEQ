function [ ] = GPS_vel_baseline(velName,siteRef,scaleIn,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  GPS_vel_baseline.m				        % 
%                                                                                       %
% form baselines for sites in velName with respect to a reference site                  %       
%                                                                                       %
% INPUT: 										%
% (1) velName.vel                                                                       %
% velocity file format:                                                                 %
% 1   2   3   4      5  6  7  8   9   10  11     12 13  14 15    16  17  18         	%
% Sta Lon Lat Height VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D   Cne Ceu Cnu      	%
% Note: Cne is correlation coefficient between North and East uncertainties!		%
%                                                                                       %
% (2) siteRef - name of the reference site                                              %
% if siteRef = '', all sites are used as reference sites                                %
%											%
% OUTPUT: a *.bsline file that contains the baselines                                   %
% baseline file format:                                                                 %
% 1         2    3    4    5    6    7    8  9  10 11  12  13  14     15 16  17 18      %
% Sta1-Sta2 Lon1 Lat1 Hgt1 Lon2 Lat2 Hgt2 VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D     %
%										        %
% first created by Lujia Feng Wed Jun 26 17:11:56 SGT 2013                              %
% added scaleIn & scaleOut lfeng Mon Oct 20 17:17:01 SGT 2014                           %
% last modified by Lujia Feng Mon Oct 20 17:17:09 SGT 2014                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin <= 2
   scaleIn = []; scaleOut = [];
end

% read in the velocity file
fprintf(1,'\n.......... reading %s  ...........\n',velName);
[ siteList,vel ] = GPS_readvel(velName,scaleIn,scaleOut);
siteNum = size(siteList,1);
% fnum = 17 (up to all 3 correlation coeffs)
% fnum = 15; fnum = 14 if Cne ignored; fnum = 10 if T0 T0D T1 T1D Cne ignored
fnum = size(vel,2);
if fnum~=10&&fnum~=14&&fnum~=15&&fnum~=17, error('GPS_vel_baseline ERROR: %s does not have the right format!',velName); end

% find the reference site
if ~isempty(siteRef)
   indRef = strcmpi(siteRef,siteList);
   if ~any(indRef),  error('GPS_vel_baseline ERROR: %s does not exist in %s!',siteRef,velName); end
   if sum(indRef)>1, error('GPS_vel_baseline ERROR: %s appear more than once in %s!',siteRef,velName); end
end

% prepare a new velocity file
[ ~,basename,~ ] = fileparts(velName);
if ~isempty(siteRef)
   outName = [ basename '-' siteRef '.bsline' ];
else
   outName = [ basename '.bsline' ];
end

fout = fopen(outName,'w');
% write out the header
fprintf(fout,'# 1         2    3    4    5    6    7    8  9  10 11  12  13  14     15 16  17 18\n');
fprintf(fout,'# Sta1-Sta2 Lon1 Lat1 Hgt1 Lon2 Lat2 Hgt2 VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D\n');
fprintf(fout,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');

if ~isempty(siteRef)
   locRef = vel(indRef,1:3);
   enuRef = vel(indRef,4:6); 
   errRef = vel(indRef,7:9);
   fprintf(1,'\n.......... calculating baselines with respect to %s  ...........\n',siteRef);
   for ii=1:siteNum
      site = siteList{ii};
      if strcmpi(site,siteRef), continue; end
      sitepair = [ site '-' siteRef ];
      loc = vel(ii,1:3); 
      enu = vel(ii,4:6)-enuRef;
      err = sqrt(vel(ii,7:9).^2+errRef.^2);
      wgt = vel(ii,10);
      if fnum==10
         fprintf(fout,'%4s %14.9f %14.9f %12.4f %14.9f %14.9f %12.4f %10.4f %10.4f %10.4f %9.4f %7.4f %7.4f %6.1f\n',...
                 sitepair,loc,locRef,enu,err,wgt);
      end
      if fnum>=14
         T0  = [ num2str(vel(ii,11))        '-' num2str(vel(indRef,11)) ];
         T0D = [ num2str(vel(ii,12),'%.4f') '-' num2str(vel(indRef,12),'%.4f') ];
         T1  = [ num2str(vel(ii,13))        '-' num2str(vel(indRef,13)) ];
         T1D = [ num2str(vel(ii,14),'%.4f') '-' num2str(vel(indRef,14),'%.4f') ];
         fprintf(fout,'%4s %14.9f %13.9f %10.4f %14.9f %13.9f %10.4f %10.4f %10.4f %10.4f %9.4f %7.4f %7.4f %4.1f %17s %19s %17s %19s\n',...
                 sitepair,loc,locRef,enu,err,wgt,T0,T0D,T1,T1D);
      end
   end
else
   for jj=1:siteNum  % reference site
      siteRef = siteList{jj};
      locRef  = vel(jj,1:3);
      enuRef  = vel(jj,4:6); 
      errRef  = vel(jj,7:9);
      fprintf(1,'\n.......... calculating baselines with respect to %s  ...........\n',siteRef);
      for ii=1:siteNum
         site = siteList{ii};
         if strcmpi(site,siteRef), continue; end
         sitepair = [ site '-' siteRef ];
         loc = vel(ii,1:3); 
         enu = vel(ii,4:6)-enuRef;
         err = sqrt(vel(ii,7:9).^2+errRef.^2);
         wgt = vel(ii,10);
         if fnum==10
            fprintf(fout,'%4s %14.9f %14.9f %12.4f %14.9f %14.9f %12.4f %10.4f %10.4f %10.4f %9.4f %7.4f %7.4f %6.1f\n',...
                    sitepair,loc,locRef,enu,err,wgt);
         end
         if fnum>=14
            T0  = [ num2str(vel(ii,11))        '-' num2str(vel(jj,11)) ];
            T0D = [ num2str(vel(ii,12),'%.4f') '-' num2str(vel(jj,12),'%.4f') ];
            T1  = [ num2str(vel(ii,13))        '-' num2str(vel(jj,13)) ];
            T1D = [ num2str(vel(ii,14),'%.4f') '-' num2str(vel(jj,14),'%.4f') ];
            fprintf(fout,'%4s %14.9f %13.9f %10.4f %14.9f %13.9f %10.4f %10.4f %10.4f %10.4f %9.4f %7.4f %7.4f %4.1f %17s %19s %17s %19s\n',...
                    sitepair,loc,locRef,enu,err,wgt,T0,T0D,T1,T1D);
         end
      end
   end
end
fclose(fout);
