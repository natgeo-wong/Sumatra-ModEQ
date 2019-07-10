function [ lat,lon,hh ] = XYZ2LLd(XX,YY,ZZ)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  convert from Earth Center Earth Fixed (ECEF) XYZ cartesian coordinate 
%  to geodetic latitude, longitude, and height
%  The World Geodetic System 1984 (WGS84) ellipsoid (updated on GRS80) 
%  The Geodetic Reference System 1980 (GRS80)
%  Very small difference between WGS84 and GRS80
%
%  INPUT:
%  xx,yy,zz [m] in WGS84 ellipsoid system
%  xx,yy,zz can be scalar, vector or matrix
%
%  Parameters for WGS84 :
%  aa - semi-major axis = 6378137 [m]
%  bb - semi-minor axis = 6356752.314245 [m] ~ 6356752.3 [m] 
%  aa - bb = 21384 [m]
%  ff - flattening = (aa-bb)/aa = 1/298.257223563 ~ 1/298.257
%  e2 - 2*ff - ff^2 = (aa^2-bb^2)/aa^2
%  Rn - radius of curvature, need to know latitude
%
%  Parameters for GRS80:
%  aa - semi-major axis = 6378137 [m]
%  ff - flattening = (aa-bb)/aa = 1/298.257222101
%
%  OUTPUT:
%  lon - geodetic longitude is almost the same as the geocentric longitude
%  lat - geodetic latitude is different from the geocentric latitude
%        geodetic latitude is the angle between the normal to the ellipsoid and the equatorial plane 
%        geocentric latitude is the angle between the sphere and the equatorial plane
%        astronomical latitude is the angle between the direction of gravity and the equatorial plane
%  height - geodetic height is the height above the ellipsoid, rarely used in daily life
%   [m]     different from the orthometric height based on a potential surface e.g. mean sea level
%
% REFERENCE:
% GPS Theory and Practice, Hofmann-Wellenhof, Lichtenegger, and Collins P280
%
% first created by Lujia Feng Wed Mar 13 10:17:19 SGT 2013
% used GRS80 following JPL convention lfeng Fri Mar 22 11:36:35 SGT 2013
% modified isequal lfeng Wed Jul  9 10:42:02 SGT 2014
% last modified by Lujia Feng Wed Jul  9 10:42:23 SGT 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sizeX = size(XX); sizeY = size(YY); sizeZ = size(ZZ);
if ~isequal(sizeX,sizeY,sizeZ)
    error('XYZ2LLd ERROR: XX,YY, and ZZ are not consistent!'); 
end

aa  = 6378137;              
aa2 = aa^2;
ff  = 1/298.257222101;             
e2  = 2*ff - ff^2;
bb  = aa*(1-ff);
bb2 = bb^2;

%---------- longitude can be computed directly ----------
% tan(lon) = YY/XX
lon  = atan2(YY,XX);

%---------- latitude & height can be computed iteratively ----------
% calculate the radius of a parallel
pp   = sqrt(XX.^2+YY.^2);
% compute an initial value for latitude
lat0 = atan2(ZZ,pp./(1-e2));
% set the initial value of height to be zero
hh0  = 0;
% set tolarence
elat = 1e-12*zeros(size(XX));
ehh  = 1-5*zeros(size(XX));
dlat = elat+1;
dhh  = ehh+1;
ii = 0;

while any(any(dlat>elat)) || any(any(dhh>ehh))
    ii = ii + 1;
    % compute an approxiate value for N - the radius of curvature in prime vertical
    NN   = aa2./sqrt(aa2.*cos(lat0).^2+bb2.*sin(lat0).^2);
    % compute the ellipsoidal height
    hh   = pp./cos(lat0)-NN;
    % compute an improved value for latitude
    lat  = atan2(ZZ,pp.*(1-e2.*NN./(NN+hh)));
    % compute difference
    dlat = abs(lat-lat0);
    dhh  = abs(hh-hh0);
    hh0  = hh;
    lat0 = lat;
end

% convert from rad to deg
lon = lon*180/pi;
lat = lat*180/pi;
