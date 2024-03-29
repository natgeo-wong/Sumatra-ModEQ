function z1 = EQ_pos_z1b (str,dip,EQlon,EQlat,EQz1,pos)

%                               EQ_pos_z1b.m
%         EQ Function that calculates Burial Depth z1 on Backthrust
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the vertical burial depth of the fault from the
% given values of EQlon, EQlat and EQdepth for every value of lon and lat
% that is run through the parent function.  We are assuming that the fault
% here is uniform and can be assumed to be a rectangular plane which allows
% for such estimates and projections to be made.
%
% We use this function for backthrusts as we are unable to use the data
% from Slab 1.0 provided by USGS because these backthrusts are not recorded
% in the data.  z1 will have to be calculated manually using equations from
% the GCMT data that provides longitude, latitude and depth of the
% earthquake hypocenter.
%
% We then need to find the component of the distance between the 
% fault-rupture and the epicenter location given by GCMT that is 
% perpendicular to the fault strike.  This is dependent not only on the 
% xdisp and ydisp but also on the parameter str (ie. the strike of the
% fault).
%
% We are assuming in this function that the surface of the Earth for such a
% small displacement can be assumed to be a flat plane.
%
% INPUT:
% -- str   : strike of fault
% -- dip   : dip of fault
% -- EQlon : initial earthquake longitude
% -- EQlat : initial earthquake latitude
% -- EQz1  : initial burial depth
% -- pos   : depth of earthquake epicenter
%
% OUTPUT:
% -- z1    : burial depth matrix
%
% FORMAT OF CALL: EQ_pos_z1b (strike,dip,EQlon,EQlat,EQz1,gridsearch coord)
%
% OVERVIEW:
% 1) The following parameters have to be defined first:
%    a) radius of the Earth (m) stored in the variable "R_E"
%
% 2) The function will then use an equation to calculate the longitude/x
%    and latitude/y displacement in metric units as a function of the
%    variables "R_E" and the coordinates "EQlon", "EQlat", "lon" and "lat",
%    and save it as "xdisp" and "ydisp" resp.
%
% 3) The function will then calculate the angle of the line that joins the
%    earthquake epicenter and the endpoint and save it as variable "theta".
%
% 4) The function will then find the component of the distance between the 
%    fault-rupture and the epicenter location given by GCMT that is 
%    perpendicular to the fault strike "per_disp".  It can be negative, 
%    meaning the fault endpoint is closer to the fault than the epicenter.
%
% 5) The vertical burial depth z1 (m) will then be calculated using the
%    initial burial depth  and the variable "per_disp" and the
%    fault dip "dip".
%
% VERSIONS:
% 1) -- Created on 20160615 by Nathanael Wong
% 
% 2) -- Modified sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%

R_E = 6371e3; lon = pos(:,1); lat = pos(:,2);

%%%%%%%%%%%%%%% CALCULATING X-, Y- DISPLACEMENTS AND ANGLE %%%%%%%%%%%%%%%%

ydisp = 2*pi*R_E*(lat - EQlat)/360;
xdisp = 2*pi*R_E*cosd(lat).*(lon - EQlon)/360;
theta = atan2d (xdisp, -ydisp);

%%%%%%%% CALCULATING PERPENDICULAR DISPLACEMENTS AND BURIAL DEPTH %%%%%%%%%

per_disp = sqrt (xdisp.^2 + ydisp.^2) .* sind (180 - str - theta);
z1 = EQz1 + per_disp * tand(dip);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end