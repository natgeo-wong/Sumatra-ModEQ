function [ XX,YY,ZZ ] = LL2XYZd(lat,lon,height)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert from geodetic latitude, longitude, and height 
% to Earth Center Earth Fixed (ECEF) XYZ cartesian coordinate
% The World Geodetic System 1984 (WGS84) ellipsoid (updated on GRS80) 
% The Geodetic Reference System 1980 (GRS80)
% Very small difference between WGS84 and GRS80
%
% INPUT:
% lon - geodetic longitude is almost the same as the geocentric longitude
% lat - geodetic latitude is different from the geocentric latitude
%       geodetic latitude is the angle between the normal to the ellipsoid and the equatorial plane 
%       geocentric latitude is the angle between the sphere and the equatorial plane
%       astronomical latitude is the angle between the direction of gravity and the equatorial plane
% height - geodetic height is the height above the ellipsoid, rarely used in daily life
%          different from the orthometric height based on a potential surface e.g. mean sea level
% lon,lat,height [m] can be scalar, vector or matrix
%
% Parameters for WGS84 :
% aa - semi-major axis = 6378137 [m]
% bb - semi-minor axis = 6356752.314245 [m] ~ 6356752.3 [m] 
% aa - bb = 21384 [m]
% ff - flattening = (aa-bb)/aa = 1/298.257223563 ~ 1/298.257
% e2 - 2*ff - ff^2 = (aa^2-bb^2)/aa^2
% Rn - radius of curvature, need to know latitude
%
% Parameters for GRS80:
% aa - semi-major axis = 6378137 [m]
% ff - flattening = (aa-bb)/aa = 1/298.257222101
%
% OUTPUT:
% xx,yy,zz [m] in WGS84 ellipsoid system
%
% first created by Lujia Feng Thu Mar  3 00:31:15 EST 2011
% used GRS80 following JPL convention lfeng Fri Mar 22 11:36:35 SGT 2013
% modified isequal lfeng Wed Jul  9 10:38:11 SGT 2014
% last modified by Lujia Feng Wed Jul  9 10:38:17 SGT 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sizelon = size(lon); sizelat = size(lat); sizehh = size(height);
if ~isequal(sizelon,sizelat,sizehh)
    error('lon,lat, and height are not consistent!'); 
end

aa = 6378137;              
ff = 1/298.257222101;             
e2 = 2*ff - ff^2;
% notes: if size(Rn) differnt from size(lat), something is wrong
Rn = aa./sqrt(1-e2.*sind(lat).*sind(lat));	% needs to be ./ instead of /

XX = (Rn+height).*cosd(lat).*cosd(lon);
YY = (Rn+height).*cosd(lat).*sind(lon);
ZZ = (Rn*(1-e2)+height).*sind(lat);
