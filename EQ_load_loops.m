function [ size,pos ] = EQ_load_loops (lon,lat,xyz)

%                          EQ_loopsize_para2.m
%    EQ Function that defines Range for Loop Variables for Para 2 Loops
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the range for variables that are being looped in
% para 2 loops, or position loops, based upon the earthquake epicenter
% longitude and latitude (flttypes 1 & 3), or top-left fault-rupture
% longitude and latitude (flttypes 2 & 4).
%
% INPUT:
% -- EQlon    : Longitude of Epicenter (?) (flttypes 1 & 3)
%               Longitude of top-left Fault-Rupture (?) (flttypes 2 & 4)
% -- EQlat    : Latitude of Epicenter (?) (flttypes 1 & 3)
%               Latitude of top-left Fault-Rupture (?) (flttypes 2 & 4)
% -- rake     : Rake of the fault-displacement
% -- loopsize : range of values which the loop covers.
%
% OUTPUT:
% -- rakemin  : minimum rake analysed
% -- rakemax  : maximum rake analysed
% -- lonmin   : minimum longitude analysed (?)
% -- lonmax   : maximum longitude analysed (?)
% -- latmin   : minimum latitude analysed (?)
% -- latmax   : maximum latitude analysed (?)
% -- lonstep  : increments of increase in longitude (?)
% -- latstep  : increments of increase in latitude (?)
%
% FORMAT OF CALL: EQ_loopsize_para1 (longitude, latitude, rake, loopsize)
%
% OVERVIEW:
% 1) This function will first use the variable "loopsize" to determine the
%    size of the loop (ie. the range through which the variables to be
%    analysed by the loop is run through).
%
% 2) If the loop is large (ie. loopsize = 1), then the variables rakemin,
%    lonmin, lonmax, latmin and latmax can be calculated directly
%    from the input variables EQlon, EQlat and rake.
%
%    However, if the loop is small (ie. loopsize = 2), then the function
%    will call for an input of the variables cenlon, cenlat and cenrake,
%    which will define the mean value of the range.  The variables rakemin,
%    rakemax, lonmin, lonmax, latmin and latmax will be calculated from
%    cenrake, cenlon and cenlat.
%
% 3) The function will then calculate the step for each iteration of the
%    loop by taking the variables rakemax, rakemin, lonmax, lonmin, latmax
%    and latmin.
%
% 4) The variables will then all be exported to the parent function.
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
%
%    -- Modified on 20160624 by Nathanael Wong
%    -- Added option for tiny grids that will narrow down the lon/lat for
%       earthquakes where a tiny shift in position results in a large
%       change in misfit (like in strike-slip earthquakes with a very high
%       dip and thus location is highly limited)

%%%%%%%%%%%%%%%%%%%%%%%%% DETERMINING LOOP RANGE %%%%%%%%%%%%%%%%%%%%%%%%%%

lonmin  = lon - 0.5;  latmin  = lat - 0.5;
lonmax  = lon + 0.5;  latmax  = lat + 0.5;
lonstep = 0.01;       latstep = 0.01;

lon = lonmin : lonstep : lonmax;
lat = latmin : latstep : latmax;
pos = [ lon ; lat ];

[ size,pos ] = EQ_load_loopgrid (pos,xyz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end