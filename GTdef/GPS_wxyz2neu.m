function [ Vns,Vew,Vud,Vhoriz,Vdir ] = GPS_wxyz2neu(lat,lon,height,wx,wy,wz,Tx,Ty,Tz)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_wxyz2neu                               %
% computer plate motion from a rotation vector                          %
% all calculation uses scalars						%
% 									%
% INPUT:								%
% lat,lon,height  - site position [deg,deg,m]                           %
% wx,wy,wz        - rotation vector in XYZ cartesian system [rad/Myr]   %
% Tx,Ty,Tz        - translation vector of origin [mm/yr]                %
% if Tx = Ty = Tz = 0, no translation considered                        %
%                                                                       %
% OUTPUT:                                                               %
% Vns    - velocity in north-south direction     [mm/yr]                %
% Vew    - velocity in east-west direction       [mm/yr]                %
% Vud    - vertical velocity                     [mm/yr]                %
% Vhoriz - rate of plate motion	                 [mm/yr]                %
% Vdir   - azimuth of plate motion                                      %
% 									%
% Math description in XYZ coordinate system:				%
% V = w x r + T                                                         %
% V - velocity                                                          %
% w - the Euler vector             	                                %
% r - site position vector                                              %
% T - translation vector with respect to ITRF                           %
% x - cross product                                                     %
% 	  | i  j  k  |							%
% w x r = | wx wy wz | = (wy*ZZ-wz*YY)i-(wx*ZZ-wz*XX)j+(wx*YY-wx*XX)k   %
%         | XX YY ZZ |							%
%                                                                       %
% modified based on GPS_euler2xyz.m                                     %
% first created by Lujia Feng Tue Jun 18 17:22:21 SGT 2013              %
% added translation lfeng Tue Jun 18 20:05:00 SGT 2013                  %
% last modified by Lujia Feng Tue Jun 18 20:05:35 SGT 2013              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%% (1) convert angular velocity from Euler parameters to XYZ cartesian system %%%%%%%%
% note unit converted from [deg/Myr] to [rad/Myr]
%[ wx,wy,wz ] = Euler2wxyzd(pole_lat,pole_lon,omega);

%%%%%%%% (2) convert the given point from geodetic (lon,lat,height) to XYZ %%%%%%%%
[ XX,YY,ZZ ] = LL2XYZd(lat,lon,height);

% convert from [m] to [km]
XX = XX*1e-3; YY = YY*1e-3; ZZ = ZZ*1e-3;

%%%%%%%% (3) from angular velocity in XYZ to plate motion in XYZ %%%%%%%%
% [wx wy wz] [rad/Myr]
% [vx]   [  0  Z -Y ][wx]
% [vy] = [ -Z  0  X ][wy] is the same as using matlab function cross(w,r)
% [vz]   [  Y -X  0 ][wz]
T1 = [  0  ZZ -YY; 
      -ZZ   0  XX; 
       YY -XX   0 ];
Wxyz = [ wx;wy;wz ];
Vxyz = T1*Wxyz;        % unit of Vxyz is mm/yr = km/Myr

%%%%%%%% (4) add origin translation component %%%%%%%%
Vxyz = Vxyz + [ Tx;Ty;Tz ];

%%%%%%%% (5) from plate motion in XYZ to plate motion in local tangent plane %%%%%%%%
% [vn]   [ -sin(lat)cos(lon) -sin(lat)sin(lon) cos(lat) ][vx]
% [ve] = [     -sin(lon)          cos(lon)        0     ][vy]
% [vu]   [  cos(lat)cos(lon)  cos(lat)sin(lon) sin(lat) ][vz]

T2 = [ -sind(lat)*cosd(lon) -sind(lat)*sind(lon) cosd(lat);
           -sind(lon)          cosd(lon)        0      ;
        cosd(lat)*cosd(lon)  cosd(lat)*sind(lon) sind(lat) ];

Vneu = T2*Vxyz;        % unit is mm/yr = km/Myr
Vns  = Vneu(1); 
Vew  = Vneu(2);	
Vud  = Vneu(3);        % Vud should be very small if no translation

% calculate the rate of motion [mm/yr]
Vhoriz = sqrt(Vns^2+Vew^2);

% calculate the azimuth of motion
if Vew>=0
    Vdir = 90 - atan(Vns/Vew)*180/pi;
else
    Vdir = 270 - atan(Vns/Vew)*180/pi;
end
