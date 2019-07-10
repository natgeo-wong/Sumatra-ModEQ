function [ ns,ew,ns_err,ew_err,cc ] = GPS_vel2ne(vv,v_err,dir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% give a velocity and its direction and project it back 			%
% to north-south and east-west directions					%
%										%
% INPUT:									% 
% v,v_err,dir - velocity and its direction					%
% dir is azimuth clockwise from north						%
%										%
% OUTPUT:                                                                       %
% ns,ew,ns_err,ew_err - convert to north-south and east-west directions		%
% cc - correlation coefficient between north and east				%
%                                                                               %
% old version is GPS_prjvel.m							%
% related to GPS_vel2strike.m							%
% first created by lfeng Fri Mar  4 17:26:43 EST 2011				%
% last modified by lfeng Sat Mar  5 00:29:54 EST 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      yT /\   x
%         |   /  
%         |  /
%         | /    
%         |/ a 
%          ----------------> xT
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
aa = 90 - dir;
R = [ cosd(aa) -sind(aa);
      sind(aa)  cosd(aa) ];

% rename use x = v & y = 0
xx = vv;  yy = 0;
%----------- only consider error associated with v_dir -----------
Cxy = [ v_err^2    0;
           0	   0  ];
%----------- consider error associated with normal to v_dir too -----------
%Cxy = [ v_err^2            cc*v_err*v_normal_err;
%        cc*v_err*v_normal_err     v_normal_err^2  ];

% calculate new values
new = R*[ xx;yy ];
ew = new(1);  ns = new(2);

% calculate new covariance
Cen = R*Cxy*R';
ew_err = sqrt(Cen(1,1));
ns_err = sqrt(Cen(2,2));
cc = Cen(1,2)/ns_err/ew_err;
