function [ pole_lat,pole_lon,omega ] = wxyz2Eulerd(wx,wy,wz)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert from rotation vector in cartesian XYZ coordinate
% rotation vector [wx wy wz] 
% convert from Euler parameters 
% (1) lat & lon of rotation pole  
% (2) angular velocity
%
% INPUT:
% wx,wy,wz - rotation vector in XYZ cartesian system [mas/yr or mas/a]
% mas (milliarcsecond) = 1/3600/1000 deg
%
% OUTPUT:
% pole_lat, pole_lon - euler pole location [deg]
% omega - angular velocity [deg/Myr]
%
% Reference:
% The solid earth C.M.R. Fowler P22
%
% Sister function: Euler2wxyzd.m
% first created by Lujia Feng Mon Jun 17 14:19:59 SGT 2013
% last modified by Lujia Feng Mon Jun 17 15:11:28 SGT 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate angular velocity omega
% omega has the same unit as input wx,wy,xz
omega = sqrt(wx^2+wy^2+wz^2);

%wx = omega*cosd(pole_lat)*cosd(pole_lon);
%wy = omega*cosd(pole_lat)*sind(pole_lon);
%wz = omega*sind(pole_lat);

% calculate pole latitude
pole_lat = asind(wz/omega);

% calculate pole longitude
coslon = wx/omega/cosd(pole_lat);
sinlon = wy/omega/cosd(pole_lat);

% [0 180]
if sinlon>=0
   pole_lon = acosd(coslon);
% [-180 0]
else
   pole_lon = -acosd(coslon);
end

% convert omega from mas/a to deg/Myr
omega = omega*1e6/3600/1000;
