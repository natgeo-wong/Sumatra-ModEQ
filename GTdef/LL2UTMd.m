function [ xx,yy ] = LL2UTMd(lon,lat,lon0,lat0,zone)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            LL2UTMd.m                                 %
% Transforms lon,lat to UTM coordinate                                 %
% using lon0 lat0 as origin & zone e.g. '47N'                          %
%                                                                      %
% INPUT:                                                               %
% lon,lat   - scalars or column vectors [degree]                       %
%             lon & lat must have the same size                        %
% lon0,lat0 - origin reference point    [degree]                       %
% zone      - if not specified, zone of lon0 lat0 is used              %
%                                                                      %
% OUTPUT:                                                              %
% xx,yy     - scalars or column vectors depending on lon,lat [m]       %
%                                                                      %
% first created by lfeng Thu Oct 18 00:29:29 SGT 2012                  %
% last modified by lfeng Thu Oct 18 03:33:11 SGT 2012                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% choose the UTM zone if not specified
if isempty(zone)
    zone = utmzone(lat0,lon0);
end

% obtain the suggested ellipsoid vectors and names for this zone
% Note: ellipsoid & estr are lists!!!!!
[ ellipsoid,estr ] = utmgeoid(zone);

% set up the UTM coordinate system
% origin is the property of zones, so it cannot be changed
% utmstruct.falsenorthing = 0;
% utmstruct.falseeasting  = 5e5
utmstruct        = defaultm('utm'); 
utmstruct.zone   = zone;
utmstruct.geoid  = ellipsoid(1,:);          % nnx2 row vectors; nn is the number of suggestions
utmstruct        = defaultm(utmstruct);     % set empty latitude limits

% calculate the grid coordinates
[ x0,y0 ] = mfwdtran(utmstruct,lat0,lon0);
[ xx,yy ] = mfwdtran(utmstruct,lat,lon);
xx = xx - x0;
yy = yy - y0;
