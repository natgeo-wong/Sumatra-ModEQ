function [deltad,dist1,dist2,azim1,azim2] = azim(lon0,lat0,lon,lat)

%  This matlab program calculates
%  (1) the azimuth from lon0,lat0 to lon,lat [degree]
%  (2) the angular distance between them [degree]
%  (3) the absolute distance between them [m]
%  Input:
%  (1) lon,lat [degree] can be scalars, vectors or matrices,
%      but they must have the same size
%  (2) (lon0,lat0) [degree] is usually the source location
%  Output:
%  (1) delta [degree]: the angular distance
%  (2) dist1,dist2 [m] in cartesian coordiante
%      dist values are similar
%  (3) azim1,azim2 [degree]: azimuth clockwise from north
%      azim values may differ a little
%  They may be scalars, vectors or matrices
%  depending on the input lon,lat [degree]
%
%  Reference:
%  1) An introduction to seismology, earthquakes, and earth structure
%     Seth Stein and Michael Wysession P464
%  2) The solid earth
%     C.M.R. Fowler P20
%
%  first writen by Lujia Feng on Fri Mar  6 16:50:37 EST 2009
%  switch (lon0 lat0) with (lon lat) lfeng Fri Dec 10 17:21:39 EST 2010
%  last modified by lfeng Fri Dec 10 17:22:03 EST 2010

R = 6378137;                % R - Earth's radius at equator [m]
% assume a perfect spheric Earth
%r = R;
% assume an oblate ellipsoid Earth [WGS 84 (World Geodetic System)]
ff = 1/298.257;             % ff - flattening factor
r = R*(1-ff*sind(lat0)^2);  % r - radius at lat [m]

if size(lon)~=size(lat), error('lon and lat are not consistent!'); end

% convert lat to colat
colat = 90 - lat;
colat0 = 90 - lat0;
% calculate the angular distance
delta = acos(cosd(colat).*cosd(colat0)+sind(colat).*sind(colat0).*cosd(lon-lon0));
deltad = delta.*180/pi;
% two ways to calculate the absolute distance 
% the results are the same for a small region; (2) is more accurate for a big region
% (1) transform from lon,lat to xx,yy using (lon0,lat0) as origin
mpd = r*pi/180;             % mpd - meters per degree
yy = (lat-lat0)*mpd;
xx = (lon-lon0)*mpd.*cosd((lat+lat0)*0.5);
dist1 = sqrt(xx.^2+yy.^2);
if yy>=0
   azim1 = atand(xx./yy);
   if azim1<0, azim1 = 360+azim1; end
else
   azim1 = 180+atand(xx./yy);
end
% (2) use the angular distance
dist2 = delta*r;
% calculate the azimuth
cos_az = (cosd(colat).*sind(colat0)-sind(colat).*cosd(colat0).*cosd(lon-lon0))./sin(delta);
sin_az = sind(colat).*sind(lon-lon0)./sind(delta);
if sin_az>=0
   azim2 = acosd(cos_az);
else
   azim2 = 360 - acosd(cos_az);
end
