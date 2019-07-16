function [ size,pos ] = EQ_load_loops (lon,lat,xyz)

%                             EQ_load_loops.m
%      EQ Function that creates the positions of the fine-grid loop
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function creates the high-resolution (lon,lat) grid about which the
% event is looped through based on the initial best-fit model given by the
% initial coarse-resolution loop.
%
% INPUT:
% -- lon : longitude of best-fit start-point (from coarse grid)
% -- lat : latitude of best-fit start-point (from coarse grid)
% -- xyz : earthquake initial input coordinates
%
% OUTPUT:
% -- size : number of points in grid (i.e. nlon*nlat)
% -- pos  : array containing 
%
% FORMAT OF CALL: EQ_load_loops (longitude,latitude,event coordinates)
%
% OVERVIEW:
% 1) This function creates vectors for the possible longitudes and
%    latitudes from the input (lon,lat) coordinates
%
% 2) The function then calls the subfunction to create the gridded
%    coordinate positions and the grid size
%
% 3) The variables will then all be exported to the parent function.
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
%
%    -- Modified on 20160624 by Nathanael Wong
%    -- Added option for tiny grids that will narrow down the lon/lat for
%       earthquakes where a tiny shift in position results in a large
%       change in misfit (like in strike-slip earthquakes with a very high
%       dip and thus location is highly limited)
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%% DETERMINING LOOP RANGE %%%%%%%%%%%%%%%%%%%%%%%%%%

lonmin = lon - 0.5; lonmax = lon + 0.5; lonstep = 0.01;
latmin = lat - 0.5; latmax = lat + 0.5; latstep = 0.01;

lon = lonmin : lonstep : lonmax; lat = latmin : latstep : latmax;
pos = [ lon ; lat ];

[ size,pos ] = EQ_load_loopgrid (pos,xyz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end