function spos = EQ_pos_surf (pos,zsd,data)

%                              EQ_pos_surf.m
%       EQ Function that calculates the projected surface fault
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the coordinates when we project the fault
% rupture corners to the surface, for GTdef input.
%
% INPUT:
% -- pos  : coordinates of the fault rupture edges in the gridsearch area
% -- zsd  : fault geometry projection details (depth,strike,dip)
% -- data : earthquake initial input data
%
% OUTPUT:
% -- spos : surface coordinates
%
% FORMAT OF CALL: EQ_pos_surf (gridsearch positions,geometry,event data)
%
% OVERVIEW:
% 1) This function take in as gridsearch coordinates, the fault geometry at
%    those coordinates, and the earthquake initial input data.
%
% 2) The function then proceeds to calculate the projection of the fault
%    geometry to the surface.
%    - Also calculates the second edge in case the GTdef model is type 2 or
%      4
%
% 3) The function then exports the surface coordinates to the parent
%    function for GTdef modelling
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%

xyz = data.xyz; lon = pos(:,1); lat = pos(:,2);
z1  = zsd(:,1); str = zsd(:,3); dip = zsd(:,4);

R_E = 6371e3;
hor = z1 ./ tand (dip);
ang = 180 - str;

%%%%%%%%%%%%%%%%%%% CALCULATING X- AND Y- DISPLACEMENTS %%%%%%%%%%%%%%%%%%%

ydisp = hor .* sind (ang); xdisp = hor .* cosd (ang);

%%%%%%%%%%%%% CALCULATING LONGITUDE / LATITUDE OF PROJECTION %%%%%%%%%%%%%%

latsurf1 = lat + ydisp ./ (2*pi*R_E) * 360;
lonsurf1 = lon + xdisp ./ (2*pi*R_E * cosd (lat)) * 360;

EQlon1 = xyz(1); EQlat1 = xyz(2); EQlon2 = xyz(3); EQlat2 = xyz(4);
latsurf2 = latsurf1 + (EQlat2 - EQlat1);
lonsurf2 = lonsurf1 + (EQlon2 - EQlon1);

spos = [ lonsurf1 latsurf1 lonsurf2 latsurf2 ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end