function [ size,pos ] = EQ_load_loopgrid (pos,xyz)

%                          EQ_load_loopgrid.m
%      EQ Function that defines the gridsize over which loops occur
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function takes as input the grid positions (pos) and lon,lat,depth
% coordinates (xyz) of the event), and returns the grid positions and size
% of the grid.  This helps to project the position of the lon/lat of the
% second point of the event (for flt2 and flt4 options) based on the
% available grid.
%
% INPUT:
% -- xyz : vector containing coordinate points of event
% -- pos : array containing grid information
%
% OUTPUT:
% -- size : variable containing size of vector
% -- pos  : array containing modified grid information based on xyz
%
% FORMAT OF CALL: EQ_load_loopgrid (grid_positions,event_coordinates)
%
%
% OVERVIEW:
% 1) Takes as input the xyz coordinates of the event and the pos variable
%    containing information on the grids
%
% 2) Extrapolates the positions of the event (assuming flt2/4 options) to
%    the relevant grid sizes (note: flt1/3 options default to NaN).
%
% 3) Obtain size of the grid.
%
% VERSIONS:
% 1) -- Final version validated on 20190419 by Nathanael Wong

EQlon1 = xyz(1); EQlat1 = xyz(2); EQlon2 = xyz(3); EQlat2 = xyz(4);

  lon = pos(1,:); lat = pos(2,:);
[ lon1,lat1 ] = meshgrid(lon,lat);

lon1 = reshape(lon1,1,[])    ; lat1 = reshape(lat1,1,[]);
lon2 = lon1 + EQlon2 - EQlon1; lat2 = lat1 + EQlat2 - EQlat1;
count = 1 : length(lon1); size = length(count);

pos = [ lon1 ; lat1 ; lon2 ; lat2 ]';

end