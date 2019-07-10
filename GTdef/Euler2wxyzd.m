function [ wx,wy,wz ] = Euler2wxyzd(poleLat,poleLon,omega)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Euler2wxyzd                                %
% convert from Euler parameters                                         %
% (1) lat & lon of rotation pole                                        %
% (2) angular velocity                                                  %
% to rotation vector in cartesian XYZ coordinate                        %
% rotation vector [wx wy wz]                                            %
%                                                                       %
% INPUT:                                                                %
% poleLat, poleLon - euler pole location [deg]                          %
% omega - angular velocity [deg/Myr]                                    %
%                                                                       %
% OUTPUT:                                                               %
% wx,wy,wz - rotation vector in XYZ cartesian system [rad/Myr]          %
%                                                                       %
% Reference:                                                            %
% The solid earth C.M.R. Fowler P22                                     %
%                                                                       %
% Sister function: wxyz2Eulerd.m                                        %
% first created by lfeng Fri Mar  4 11:49:36 EST 2011                   %
% last modified by lfeng Fri Mar  4 11:53:22 EST 2011                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wx = omega*cosd(poleLat)*cosd(poleLon);
wy = omega*cosd(poleLat)*sind(poleLon);
wz = omega*sind(poleLat);

% convert from deg/Myr to rad/Myr
wx = wx*pi/180;
wy = wy*pi/180;
wz = wz*pi/180;
