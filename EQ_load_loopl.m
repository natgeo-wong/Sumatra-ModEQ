function loopl = EQ_load_loopl (xyz)

%                            EQ_load_loopl.m
%      EQ Function that defines the gridsize over which loops occur
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function takes as input the xyz (lon,lat,depth) positions of the
% event from the input file and creates two grids of the possible xy
% (lon,lat) positions that this event could take, a small grid over which
% the search area will be refined, and a large grid to cover the entire
% spatial area to be mapped.
%
% INPUT:
% -- xyz : vector containing coordinate points
%
% OUTPUT:
% -- loopl : structure containing xyz positions of the event over the
%            entire grid.
%
% FORMAT OF CALL: EQ_load_loopl (xyz)
%
% OVERVIEW:
% 1) Takes as input the xyz positions of the event.
%
% 2) Creates two different grids, one small (pos_1) and one large (pos_2)
%    that the parameters will be looped through.
%
% 3) Finds the size of each of these loops.
%
% 4) Saves into the variable loopl and exports it to the parent function.
%
% VERSIONS:
% 1) -- Final version validated on 20190419 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%% DETERMINING LOOP RANGE %%%%%%%%%%%%%%%%%%%%%%%%%%

  EQlon1 = xyz(1); EQlat1 = xyz(2);

[ pos_1,pos_2 ] = EQ_load_looplrange (EQlon1,EQlat1);
[ size1,pos_1 ] = EQ_load_loopgrid (pos_1,xyz);
[ size2,pos_2 ] = EQ_load_loopgrid (pos_2,xyz);

  loopl.pos1 = pos_1; loopl.pos2 = pos_2; loopl.size = [ size1 size2 ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end