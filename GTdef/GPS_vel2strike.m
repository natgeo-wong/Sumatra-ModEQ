function [ parall,normal,errParall,errNormal,cc ] = GPS_vel2strike(ns,ew,errNS,errEW,ccNE,dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              GPS_vel2strike.m                                 %
% Transform the coordinate x = ew & y = ns to a new coordinate system           %
% The same as projecting velocities to normal and parallel directoins           %
% only works for scalars                                                        %
%                                                                               %
% INPUT:                                                                        % 
% ns,ew,errNS,errEW - initial components                                        %
% ccNE - correlation coefficient between north and east	                        %
% dir  - strike direction clockwise from N [deg]                          	%
%                                                                               %
% OUTPUT:                                                                       %
% parall,errParall - velocity parallel to dir                                   %
%      +: along the given direction - new x direction                           %
% normal,errNormal - velocity normal to dir (right-hand rule)                   %
%      +: along new y direction                                                 %
% cc - correlaton coefficient between parall and normal component               %
%                                                                               %
% related to GPS_vel2ne.m                                                       %
% first created by Lujia Feng Fri Mar  4 17:26:43 EST 2011                      %
% last modified by Lujia Feng Thu Jun 20 01:12:01 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           y /\
%	      |
%	      |
%	   \  |    
%	    \ |   
%            \ ----------------> x
%	      \  a
%	       \
%		\ xT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a is the angle between x and xT 
% x -> xT clockwise rotation
%
% the rotation matrix is
% R = [ cos(a) -sin(a) ]
%     [ sin(a)  cos(a) ]
% [ xT yT ]' = R*[ xx yy ]'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% determine rotation angle and matrix
aa = dir - 90;
R  = [ cosd(aa) -sind(aa);
       sind(aa)  cosd(aa) ];

% rename use x = ew & y = ns
xx  = ew;  
yy  = ns;
Cxy = [ errEW^2         ccNE*errEW*errNS;
        ccNE*errNS*errEW         errNS^2 ];

% calculate new values
new    = R*[ xx;yy ];
parall = new(1);  
normal = new(2);

% calculate new covariance
Cpn       = R*Cxy*R';
errParall = sqrt(Cpn(1,1));
errNormal = sqrt(Cpn(2,2));
cc        = Cpn(1,2)/errParall/errNormal;
