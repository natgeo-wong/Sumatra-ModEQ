function [ ] = GPS_vel2relax(fvelName,lon0,lat0,zone)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_vel2relax.m                              % 
% Convert vel/disp format to RELAX displacement format                     %
% need to switch between N & E and turn upside down                        %
%--------------------------------------------------------------------------%
% The format of *.vel                                                      %
% 1   2   3   4    5  6  7  8   9   10  11     12 13  14 15    16          %
% Sta Lon Lat Elev VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D   Cne         %
%--------------------------------------------------------------------------%
% The format of RELAX coseismic.dat or postseismic.dat in [m]              %
% 1    2     3    4    5          6         7         8     9     10       %
% NAME north east down disp_north disp_east disp_down err_n err_e err_d    %
%      (km)  (km) (km) (m)        (m)       (m)       (m)   (m)   (m)      %
%--------------------------------------------------------------------------%
%                                                                          %
% INPUT:                                                                   %
% fvelName  - *.vel                                                        %
% lon0,lat0 - origin reference point    [degree]                           %
% zone      - if not specified, zone of lon0 lat0 is used                  %
%                                                                          %
% OUTPUT:                                                                  %
% coseismic.dat & postseismic.dat                                          %
%                                                                          %
% first created by lfeng Wed Nov  7 17:57:36 SGT 2012                      %
% last modified by lfeng Wed Nov  7 19:16:12 SGT 2012                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'\n.......... reading %s ...........\n',fvelName);
[ site,vel ] = GPS_readvel(fvelName);

% convert from lon & lat to UTM
lon = vel(:,1);
lat = vel(:,2);
ee    = vel(:,4); nn    = vel(:,5); uu    = -vel(:,6);
eeErr = vel(:,7); nnErr = vel(:,8); uuErr = vel(:,9);
[ xx,yy ] = LL2UTMd(lon,lat,lon0,lat0,zone);
xx = xx*1e-3;
yy = yy*1e-3;
zz = zeros(size(xx));

[ ~,basename,~ ] = fileparts(fvelName);
foutName = [ basename '.dat' ];
fout = fopen(foutName,'w');
fprintf(fout,'# converted from %s using GPS_vel2relax.m by Lujia FENG\n',fvelName);
fprintf(fout,'# Lon Lat converted to %s UTM zone centered at %f %f\n',zone,lon0,lat0);
fprintf(fout,'# NAME north(km) east(km) down(km) disp_north(m) disp_east(m) disp_down(m) err_n(m) err_e(m) err_d(m)\n');
siteNum = size(site,1);
for ii=1:siteNum
    fprintf(fout,'%4s %14.9f %14.9f %12.4f %15.5e %12.5e %12.5e %12.5e %12.5e %12.5e\n',...
            site{ii},yy(ii),xx(ii),zz(ii),nn(ii),ee(ii),uu(ii),nnErr(ii),eeErr(ii),uuErr(ii));
end
fclose(fout);
