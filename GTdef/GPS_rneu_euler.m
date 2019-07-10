function [ ] = GPS_rneu_euler(frneuName,foutExt,siteName,eulerName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                GPS_rneu_euler.m				        % 
% remove an Euler rotation vector + translation from rneu files	                        %
%											%	
% INPUT: 										%
% (1) frneuName - *.rneu                           					%
% NOTE: must have site name capitalized in the rneu file name                           %
%     1        2         3     4    5    6    7    8                              	%
%     YEARMODY YEAR.DCML NORTH EAST VERT Nerr Eerr Verr                          	%
%											%
% (2) foutExt - file ext for rneu files                                                 %
%             = if empty, then use default '_euler.rneu'                                %
%											%
% (3) siteName - *.sites                                                                %
%     1      2              3             4    			                        %
%     Site   Lon            Lat	          Height                                        %
%     ABGS   99.387520914   0.220824642   236.2533                                      %
%                                                                                       %
% (4) eulerName - *.euler                                                               %
%     euler rotation pole file	                                                        %
%     supports three formats,read in as euler structure                                 %
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
% OUTPUT: a new *.rneu file with euler rotation + translation removed                   %
%                                                                                       %
% first created by Lujia Feng Wed Jul 13 18:53:39 SGT 2011                              %
% separated from GPS_rneu.m lfeng Wed Jun 19 10:43:57 SGT 2013                          %
% added foutExt lfeng Fri Jun  5 15:27:56 SGT 2015                                      %
% added rneu empty check lfeng Thu Jul  2 19:13:08 SGT 2015                             %
% last modified by Lujia Feng Thu Jul  2 19:14:00 SGT 2015                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in *.rneu file
fprintf(1,'\n.......... reading %s  ...........\n',frneuName);
[ rneu ] = GPS_readrneu(frneuName,[],[]); % ScaleIn = ScaleOut = 1
if isempty(rneu)  
   fprintf(1,'GPS_rneu_euler WARNING: %s is empty',frneuName); 
   return;
end

% read in *.sites file
fprintf(1,'\n.......... reading %s  ...........\n',siteName);
[ siteList,loc ] = GPS_readsites(siteName);    % site names capitalized in *.sites

% read in *.euler file
fprintf(1,'\n.......... reading %s  ...........\n\n',eulerName);
[ euler ] = GPS_readeuler(eulerName);

% find location for site
[ ~,basename,~ ] = fileparts(frneuName);
siteNum = length(siteList);
ind = 0;
for ii=1:siteNum
   ss   = siteList{ii};
   if ~isempty(strfind(basename,ss))
      ind = ii;
   end;
end
if ind==0, error('GPS_rneu_euler ERROR: the location for %s was not found!',frneuName); end
lon0 = loc(ind,1); lat0 = loc(ind,2); hh0 = loc(ind,3);
fprintf(1,'%4s LOC %14.9f %14.9f %10.4f\n',frneuName,lon0,lat0,hh0);

% prepare a new rneu file
if isempty(foutExt)
    foutName = [ basename '_euler.rneu' ];
else
    foutName = [ basename foutExt ];
end
fout     = fopen(foutName,'w');
% write out the header
fprintf(fout,'# remove Euler rotation from %s\n',frneuName);
fprintf(fout,'# Euler pole: Lat %6.2f Lon %6.2f Omega %8.3f [deg/Myr]\n',euler.lat,euler.lon,euler.omega);
fprintf(fout,'# Covariance matrix: [rad^2/Myr^2]\n');
fprintf(fout,'# %10.2e %10.2e %10.2e \n# %10.2e %10.2e %10.2e \n# %10.2e %10.2e %10.2e \n',euler.cw);
fprintf(fout,'# Translation:  X  = %9.4f Y  = %9.4f Z  = %9.4f [mm/yr]\n',euler.Tx,euler.Ty,euler.Tz);
fprintf(fout,'# Trans errors: dX = %9.4f dY = %9.4f dZ = %9.4f [mm/yr]\n',euler.errTx,euler.errTy,euler.errTz);

% calculate plate motion from euler vector
[ Vns,Vew,Vud,Vhoriz,Vdir ] = GPS_wxyz2neu(lat0,lon0,hh0,euler.wx,euler.wy,euler.wz,euler.Tx,euler.Ty,euler.Tz);
fprintf(fout,'# Plate motion removed: Vns = %9.4f Vew = %9.4f Vud = %9.4f [mm/yr]\n\n',Vns,Vew,Vud);
fclose(fout);

% rate removed from the 1st point
tt  = rneu(:,2) - rneu(1,2);
ns0 = rneu(:,3);  ew0 = rneu(:,4); ud0 = rneu(:,5);
% remove plate motion
ns = ns0 - 1e-3*Vns*tt; ew = ew0 - 1e-3*Vew*tt; ud = ud0 - 1e-3*Vud*tt;
% remove mean
rneu(:,3:5)  = [ ns-mean(ns) ew-mean(ew) ud-mean(ud) ];
% error propagation is not conducted for rneu!

GPS_saverneu(foutName,'a',rneu,1);
