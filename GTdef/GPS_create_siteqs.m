function [] = GPS_create_siteqs(fsiteName,feqsName,distCutoff)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    GPS_create_siteqs.m                                        %
% create siteqs files for sites                                                                 %
% check the distance and magnitude for site-earthquake pairs                                    %
%                                                                                               %
% INPUT:                                                                                        %
% (1) fsiteName - *.sites file                                                                  %
% 1      2              3              4                                                        %
% Site   Lon            Lat            Height [m]                                               %
% ABGS   99.387520914   0.220824642    236.2533                                                 %
%                                                                                               %
% (2) feqsName - *.eqs file                                                                     %
% 1    2  3  4  5  6       7          8          9       10         11          12              %
% YEAR MO DY HR MI SS.SSSS LONGITUDE  LATITUDE   DEPTH   MAGNITUDE  EVENT ID    DECYR           %
% 2008 07 04 19 46 30.3100 -118.81384 37.57717   6.3500  0.86                                   %
% 2011 07 10 05 09 06.2600 95.09900    4.61800  35.3000  4.70    201107101008  2011.521918      %
%                                                                                               %
% (3) distCutoff - cut-off distance for site-earthquake pairs [km]                              %
%                                                                                               %
% OUTPUT:            							                        %
% *.siteqs                                                                                      %
% 1   2   3   4                                                                                 %
% Sta Lon Lat Height(m)                                                                         %
%                                                                                               %
% 1    2   3   4    5   6    7    8    9          10    11  12     13   14                      %
% Year Mon Day Hour Min Sec  Lon  Lat  Depth(km)  Mag   ID  Decyr  Site Dist(km)                %
%									                        %
% first created by Lujia Feng Mon May 25 17:18:04 SGT 2015                                      %
% distCutoff can be a vector lfeng Sat May 28 17:54:58 SGT 2016                                 %
% last modified by Lujia Feng Sat May 28 17:57:07 SGT 2016                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ siteList,loc,period ] = GPS_readsites(fsiteName,6);
[ eqs ] = EQS_readeqs(feqsName);

siteNum = length(siteList);
eqNum   = size(eqs,1);
for ii=1:siteNum
   lon = loc(ii,1);
   lat = loc(ii,2);
   hgt = loc(ii,3);
   siteName = siteList{ii};
   foutName = [ siteName '.siteqs' ];
   fout = fopen(foutName,'w');
   fprintf(fout,'# 1   2   3   4\n');
   fprintf(fout,'# Sta Lon Lat Height(m)\n');
   fprintf(fout,'%4s %14.9f %14.9f %10.4f\n\n',siteName,lon,lat,hgt);
   fprintf(fout,'# 1    2   3   4    5   6    7    8    9          10    11  12     13   14\n');
   fprintf(fout,'# Year Mon Day Hour Min Sec  Lon  Lat  Depth(km)  Mag   ID  Decyr  Site Dist(km)\n');
   for jj=1:eqNum
      eqlon = eqs(jj,7);
      eqlat = eqs(jj,8);
      [ ~,dist,~,~,~] = azim(eqlon,eqlat,lon,lat);
      dist = dist*1e-3;
      if isscalar(distCutoff)
         cutoff = distCutoff;
      else
         cutoff = distCutoff(jj);
      end
      if dist<=cutoff
         fprintf(fout,'%4d %02d %02d %02d %02d %07.4f %11.5f %10.5f %8.4f %5.2f %15.0f %15.6f %6s %8.2f\n',eqs(jj,:),siteName,dist);
         fprintf(1,'%4d %02d %02d %02d %02d %07.4f %11.5f %10.5f %8.4f %5.2f %15.0f %15.6f %6s %8.2f\n',eqs(jj,:),siteName,dist);
      end
   end
   fclose(fout);
end
