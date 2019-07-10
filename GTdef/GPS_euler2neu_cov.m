function [ Cneu ] = GPS_euler2neu_cov(lat,lon,height,Cw,errTx,errTy,errTz)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_euler2neu_cov.m					%
% propagate covariance matrix 								%
% from angular velocity in cartesian coordinate (w XYZ) 				%
% first to plate motion in cartesian coordinate (v XYZ)					%
% final to plate motion in local geodetic tangent plane (v NEU)				%
%											%
% INPUT:										% 
% (1) lat,lon,height - site location [m]						%
%     where you want to calculate the plate motion					%
%     scalar only									%
%											%
% (2) covariance matrix for euler rotation (3x3 matrix)					%
%           [   Cxx     Cxy     Cxz   ] 						%
%      Cw = [   Cyx     Cyy     Cyz   ]     [rad^2/Myr^2]                           	%
%           [   Czx     Czy     Czz   ]                                           	%
%   Cw is the covariance matrix for angular velocity in xyz cartesian coordinate  	%
%      x - direction of (0N,0E) Greenwich						%
%      y - direction of (0N,90E)							%
%      z - direction of 90N								%
%      Cxx, Cyy, Czz - varicance  [rad^2/Myr^2]                                         %
%      Cxy, Cxz, Cyz - covariance [rad^2/Myr^2]                                         %
%                                                                                       %
% (3) errors for translation rate                                                       %
%      errTx,errTy,errTz          [mm/a]                                                %
%                                                                                       %
% OUTPUT: 										%
% Cneu  - covariance matrix in local geodetic topocentric system (v NEU)		%
%         [ Cnn Cne Cnu ]              							%
%       = [ Cen Cee Ceu ]                                                      		%
%         [ Cun Cue Cuu ]                                                      		%
%											%
% related functions: GPS_euler2neu.m, GPS_wxyz2neu.m                                    %
% first created by Lujia Feng Tue Mar  1 14:39:17 EST 2011				%
% added translation rate lfeng Wed Jun 19 01:10:26 SGT 2013                             %
% last modified by Lujia Feng Wed Jun 19 01:27:20 SGT 2013                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%% (1) from geodetic (lon,lat,height) to geocentric ECEF cartesian (XYZ) %%%%%%%%
[XX,YY,ZZ] = LL2XYZd(lat,lon,height);

% convert from [m] to [km]
XX = XX*1e-3; YY = YY*1e-3; ZZ = ZZ*1e-3;

%%%%%%%% (2) from cartesian angular velocity covariance to geocentric velocity covariance %%%%%%%
% [vx]   [  0  Z -Y 1 0 0 ][wx]
% [vy] = [ -Z  0  X 0 1 0 ][wy]
% [vz]   [  Y -X  0 0 0 1 ][wz]
%                          [Tx]
%                          [Ty]
%                          [Tz]
T1 = [  0  ZZ -YY 1 0 0; 
      -ZZ   0  XX 0 1 0; 
       YY -XX   0 0 0 1 ];
Cov = blkdiag(Cw,errTx^2,errTy^2,errTz^2);
Cxyz = T1*Cov*T1';

%%%%%%%% (3) from geocentric velocity covariance to geodetic local velocity (NEU) covaricance %%%%%%%%
% [vn]   [ -sin(lat)cos(lon) -sin(lat)sin(lon) cos(lat) ][vx]
% [ve] = [     -sin(lon)          cos(lon)        0     ][vy]
% [vu]   [  cos(lat)cos(lon)  cos(lat)sin(lon) sin(lat) ][vz]

T2 = [ -sind(lat)*cosd(lon) -sind(lat)*sind(lon) cosd(lat);
           -sind(lon)          cosd(lon)        0      ;
        cosd(lat)*cosd(lon)  cosd(lat)*sind(lon) sind(lat) ];

Cneu = T2*Cxyz*T2';		% unit is mm/yr = km/Myr
