function [ pos_1,pos_2 ] = EQ_load_looplrange (lon,lat)

%                         EQ_load_looplrange.m
%        EQ Function that creates gridsize over which loops occur
%                   Nathanael Zhixin Wong, Feng Lujia
%
% This function takes as input the lon and lat positions of the event and
% creates two different grids that the model will loop through
%
% INPUT:
% -- lon : Initial longitude
% -- lat : Initial latitude
%
% OUTPUT:
% -- pos_1 : position information (lon,lat) for the small loop
% -- pos_2 : position information (lon,lat) for the large loop
%
% FORMAT OF CALL: EQ_load_loopl (xyz)
%
% OVERVIEW:
% 1) Takes as input the initial measured longitude and latitude (lon,lat).
%
% 2) Rounds initial position to the nearest 0.5º position.
%
% 3) Creates a small and large square grid and saves the information into
%    pos_1 and pos_2 respectively.
%
% 4) Exports pos_1 and pos_2 to the parent function.
%
% VERSIONS:
% 1) -- Final version validated on 20190419 by Nathanael Wong

lonr = round(lon / 0.5)*0.5; latr = round(lat / 0.5)*0.5;

    lonmin(1)  = lonr - 0.5; latmin(1)  = latr - 0.5;
    lonmax(1)  = lonr + 0.5; latmax(1)  = latr + 0.5;
    lonstep(1) = 0.05;       latstep(1) = 0.05;

    lonmin(2)  = lonr - 1.2; latmin(2)  = latr - 1.2;
    lonmax(2)  = lonr + 1.2; latmax(2)  = latr + 1.2;
    lonstep(2) = 0.05;       latstep(2) = 0.05;

lon_1 = lonmin(1) : lonstep(1) : lonmax(1);
lat_1 = latmin(1) : latstep(1) : latmax(1);
lon_2 = lonmin(2) : lonstep(2) : lonmax(2);
lat_2 = latmin(2) : latstep(2) : latmax(2);

pos_1 = [ lon_1 ; lat_1 ]; pos_2 = [ lon_2 ; lat_2 ];

end