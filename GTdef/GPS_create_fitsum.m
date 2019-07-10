function [] = GPS_create_fitsum(fsiteName,linearFlag,seasonFlag,fqNum,foutExt,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    GPS_create_fitsum.m                                        %
% create fitsum files for sites                                                                 %
%                                                                                               %
% INPUT:                                                                                        %
% fsiteName - *.sites file                                                                      %
% 1      2              3              4                                                        %
% Site   Lon            Lat            Height [m]                                               %
% ABGS   99.387520914   0.220824642    236.2533                                                 %
%                                                                                               %
% linearFlag - whether to output linear fit                                                     %
% seasonFlag - whether to output seasonal fit                                                   %
% fqNum      - number of frequencies to fit                                                     %
%                                                                                               %
% foutExt - file ext for fitsum                                                                 %
%             = if empty, then use default '.fitsum'                                            %
%                                                                                               %
% scaleOut - scale to meter in the output                                                       %
%                                                                                               %
% fsiteqsName - *.siteqs file                                                                   %
% 1   2   3   4                                                                                 %
% Sta Lon Lat Height(m)                                                                         %
%                                                                                               %
% 1    2   3   4    5   6    7    8    9          10    11  12     13   14                      %
% Year Mon Day Hour Min Sec  Lon  Lat  Depth(km)  Mag   ID  Decyr  Site Dist(km)                %
%                                                                                               %
% OUTPUT: *.fitsum file                                                                         %
%									                        %
% first created by Lujia Feng Mon Oct 26 01:44:56 SGT 2015                                      %
% last modified by Lujia Feng Mon Oct 26 02:41:15 SGT 2015                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ siteList,loc,period ] = GPS_readsites(fsiteName,6);

siteNum = length(siteList);
for ii=1:siteNum
   lon = loc(ii,1);
   lat = loc(ii,2);
   hgt = loc(ii,3);
   siteName = siteList{ii};
   % prepare a new rneu file
   if isempty(foutExt)
       foutName = [ siteName '.fitsum' ];
   else
       foutName = [ siteName foutExt ];
   end
   fout = fopen(foutName,'w');

   %----------------------- site info -----------------------
   fprintf(fout,'# Created from GPS_create_fitsum.m\n');
   fprintf(fout,'# 1    2   3        4        5\n');
   fprintf(fout,'# Site LOC Lon(deg) Lat(deg) Elev(m)\n');
   fprintf(fout,'%4s LOC %14.9f %14.9f %10.4f\n\n',siteName,lon,lat,hgt);

   %----------------------- unit info -----------------------
   if ~isempty(scaleOut)
       fprintf(fout,'# 1    2       3\n');
       fprintf(fout,'# Site SCALE2M ScaleToMeter Unit\n');
       fprintf(fout,'%4s SCALE2M %8.3e\n\n',siteName,scaleOut);
   end

   %----------------------- basic linear info -----------------------
   if linearFlag
       fprintf(fout,'# 1   2     3        4      5      6    7     8          9\n');
       fprintf(fout,'# Sta Comp  Fittype  Dstart Tstart Dend Tend  Intercept  Rate\n');
       fprintf(fout,'%4s N linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e FIT\n',siteName,20110101,2011,20150101,2015,1e-3,1e-3);
       fprintf(fout,'%4s E linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e FIT\n',siteName,20110101,2011,20150101,2015,1e-3,1e-3);
       fprintf(fout,'%4s U linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e FIT\n\n',siteName,20110101,2011,20150101,2015,1e-3,1e-3);
   end
   
   %----------------------- seasonal info -----------------------
   if seasonFlag
       fprintf(fout,'# 1    2     3        4     5      6      7     8     9\n');
       fprintf(fout,'# Site Comp  Fittype  fqSin fqCos  Tstart Tend  ASin  ACos\n');
       % seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
       for ii=1:fqNum
           fprintf(fout,'%4s N seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e FIT\n',siteName,ii,ii,0.0,0.0,1e-1,1e-1);
           fprintf(fout,'%4s E seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e FIT\n',siteName,ii,ii,0.0,0.0,1e-1,1e-1);
           fprintf(fout,'%4s U seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e FIT\n\n',siteName,ii,ii,0.0,0.0,1e-1,1e-1);
       end
   end

   %----------------------- each earthquake -----------------------
   fprintf(fout,'# 1    2     3        4    5    6      7     8  9   10  11  12  13  14\n');
   fprintf(fout,'# Site Comp  Fittype  Deq  Teq  Tstart Tend  b  v1  v2  dv  O   a   tau\n');
   fsiteqsName = [ siteName '.siteqs' ];
   [ ~,siteqs,~ ] = EQS_readsiteqs(fsiteqsName,14);
   eqNum   = size(siteqs,1);
   func = 'off_samerate';
   eqRow = [ 0.0 0.0 0.0 1e-3 1e-3 1e-3 1e-3 1e-3 1e-3 ];
   for jj=1:eqNum
      yearmmdd = siteqs(jj,1)*1e4 + siteqs(jj,2)*1e2 + siteqs(jj,3);
      fprintf(fout,'%4s N %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e FIT\n',siteName,func,yearmmdd,siteqs(jj,12),eqRow);
      fprintf(fout,'%4s E %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e FIT\n',siteName,func,yearmmdd,siteqs(jj,12),eqRow);
      fprintf(fout,'%4s U %s %8.0f %8.5f %8.5f %8.5f %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e %12.4e FIT\n',siteName,func,yearmmdd,siteqs(jj,12),eqRow);
   end
   fclose(fout);
end
