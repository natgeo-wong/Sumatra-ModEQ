function [ ] = GPS_vel_euler(velName,eulerName,foutExt,scaleIn,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  GPS_vel_euler.m                                      % 
%                                                                                       %	
% remove an Euler rotation vector + translation from velocity files	                %
%                                                                                       %	
% INPUT: 							                        %
% (1) *.vel - velocity file                                                             %
% velocity file format:                                                                 %
% 1   2   3   4      5  6  7  8   9   10  11     12 13  14 15    16  17  18         	%
% Sta Lon Lat Height VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D   Cne Ceu Cnu      	%
% Note: Cne is correlation coefficient between North and East uncertainties!		%
%                                                                                       %	
% (3) foutExt - file ext for rneu files                                                 %
%             = if empty, then use default '_euler.vel'                                 %
%											%
% (4) *.euler - euler rotation pole file					        %
% supports three formats,read in as euler structure                                     %
%     euler.lat     scale        [deg]                                                  %
%     euler.lon     scale        [deg]                                                  %
%     euler.omega   scale        [deg/Myr]                                              %
%     euler.wx  \                                                                       %
%     euler.wy      vector       [rad/Myr]                                              %
%     euler.wz  /                                                                       %
%     euler.cw      3x3 matrix   [rad^2/Myr^2]                                          %
%     euler.Tx  \                                                                       %
%     euler.Ty      vector       [mm/yr]                                                %
%     euler.Tz  /                                                                       %
%     euler.errTx \                                                                     %
%     euler.errTy   vector       [mm/yr]                                                %
%     euler.errTz /                                                                     %
%                                                                                       %	
% OUTPUT: a new *.vel file with euler rotation + translation removed                    %
%                                                                                       %	
% first created by Lujia Feng Wed Nov  3 13:42:31 EDT 2010				%
% separated from GPS_vel.m lfeng Wed Jun 18 10:46:51 SGT 2013                           %
% added foutExt lfeng Wed Feb  3 17:15:11 SGT 2016                                      %
% last modified by Lujia Feng Wed Feb  3 17:24:05 SGT 2016                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin <= 2
   foutExt = []; scaleIn = []; scaleOut = [];
elseif nargin <= 3
   scaleIn = []; scaleOut = [];
end

% read in the velocity file
fprintf(1,'\n.......... reading %s  ...........\n',velName);
[ siteList,vel ] = GPS_readvel(velName,scaleIn,scaleOut);
% fnum = 17 (up to all 3 correlation coeffs)
% fnum = 15; fnum = 14 if Cne ignored; fnum = 10 if T0 T0D T1 T1D Cne ignored
fnum = size(vel,2);
if fnum~=10&&fnum~=14&&fnum~=15&&fnum~=17, error('GPS_vel_euler ERROR: %s does not have the right format!',velName); end

% read in the euler file
fprintf(1,'\n.......... reading %s  ...........\n\n',eulerName);
[ euler ] = GPS_readeuler(eulerName);

% prepare a new velocity file
[ ~,basename,~ ] = fileparts(velName);
if isempty(foutExt)
    foutName = [ basename '_euler.vel' ];
else
    foutName = [ basename foutExt ];
end
fout    = fopen(foutName,'w');
% write out the header
fprintf(fout,'# remove Euler rotation from %s\n',velName);
fprintf(fout,'# Euler pole: Lat %6.2f Lon %6.2f Omega %8.3f [deg/Myr]\n',euler.lat,euler.lon,euler.omega);
fprintf(fout,'# Covariance matrix: [rad^2/Myr^2]\n');
fprintf(fout,'# %10.2e %10.2e %10.2e \n# %10.2e %10.2e %10.2e \n# %10.2e %10.2e %10.2e \n',euler.cw);
fprintf(fout,'# Translation:  X  = %9.4f Y  = %9.4f Z  = %9.4f [mm/yr]\n',euler.Tx,euler.Ty,euler.Tz);
fprintf(fout,'# Trans errors: dX = %9.4f dY = %9.4f dZ = %9.4f [mm/yr]\n',euler.errTx,euler.errTy,euler.errTz);
fprintf(fout,'# 1   2   3   4      5  6  7  8   9   10  11      12 13  14 15    16  17  18\n');
fprintf(fout,'# Sta Lon Lat Height VE VN VU ErE ErN ErU Weight  T0 T0D T1 T1D   Cne Ceu Cnu\n');
fprintf(fout,'# Height in [m] Rate in [mm/yr] error in [mm/yr]\n');
fprintf(fout,'# Cne is correlation coefficient between north and east uncertainties [unitless]\n');

siteNum = size(vel,1);
for ii=1:siteNum
   site  = siteList{ii};
   % Sta Lon Lat Height VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D Cne
   lat0  = vel(ii,2); lon0  = vel(ii,1); hh0   = vel(ii,3);
   Vns0  = vel(ii,5); Vew0  = vel(ii,4); Vud0  = vel(ii,6);
   errNS = vel(ii,8); errEW = vel(ii,7); errUD = vel(ii,9);
   errneu = [ errNS errEW errUD ]; 
   ccNE  = 0.0;

%   % simple euler pole
%   % calculate plate motion from simple euler pole
%   [ Vns,Vew,Vhoriz,Vdir ] = Euler1(lat0,lon0,euler.lat,euler.lon,euler.omega);
%   % remove plate motion
%   ns = Vns0 - Vns; ew = Vew0 - Vew; ud = Vud0;

   % calculate plate motion from euler vector
   [ Vns,Vew,Vud,Vhoriz,Vdir ] = GPS_wxyz2neu(lat0,lon0,hh0,euler.wx,euler.wy,euler.wz,euler.Tx,euler.Ty,euler.Tz);
   % remove plate motion
   ns = Vns0 - Vns; ew = Vew0 - Vew; ud = Vud0 - Vud;
   % if covariance matrix is non-zero
   if sum(sum(euler.cw))~=0
      % form the correlation coefficient between north and east uncertainties
      if fnum>=15 ccNE = vel(ii,15); else ccNE = 0; end
      if fnum>=16 ccEU = vel(ii,16); else ccEU = 0; end
      if fnum>=17 ccNU = vel(ii,17); else ccNU = 0; end
      % velocity data covariance matrix
      % note: the order is north, east, and vertical
      datCov = [ errNS^2 errNS*errEW*ccNE  errNS*errUD*ccNU ;
                 errNS*errEW*ccNE  errEW^2 errEW*errUD*ccEU ;
        	 errNS*errUD*ccNU  errEW*errUD*ccEU  errUD^2 ];
      % plate motion covariance matrix
      [ eulerCov ] = GPS_euler2neu_cov(lat0,lon0,hh0,euler.cw,euler.errTx,euler.errTy,euler.errTz);
      %[ v_err,dir_err ] = GPS_ne2mov_cov(v_ns,v_ew,eulerCovmat);
      [ errneu,covmat,cc ] = GPS_neuneu_cov(datCov,eulerCov);	% data - euler
      ccNE = cc(1,2);
   end
   % write out one site
   if fnum==10
      fprintf(fout,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f\n',...
              site,lon0,lat0,hh0,ew,ns,ud,errneu([2 1 3]),vel(ii,10));
   end
   if fnum==14
      fprintf(fout,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f\n',...
              site,lon0,lat0,hh0,ew,ns,ud,errneu([2 1 3]),vel(ii,10:14));
   end
   if fnum>14
      fprintf(fout,'%4s %14.9f %14.9f %10.4f %7.1f %7.1f %7.1f %6.1f %4.1f %4.1f %6.1f %9d %12.6f %9d %12.6f %6.3f\n',...
              site,lon0,lat0,hh0,ew,ns,ud,errneu([2 1 3]),vel(ii,10:14),ccNE);
   end
end
fclose(fout);
