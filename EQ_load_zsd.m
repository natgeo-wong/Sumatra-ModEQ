function [ z,s,d ] = EQ_load_zsd (slab)

%                              EQ_load_zsd.m
%         EQ Function that loads the slab, strike and dip data
%                   Nathanael Zhixin Wong, Feng Lujia
%
% This function loads the relevant slab data based on the earthquake type
% indicated in the root data and creates a scatteredInterpolant grid based
% on the loaded data for future use.
%
% INPUT:
% -- slab : Slab choice for model
%
% OUTPUT:
% -- z : ScatteredInterpolant grid for Slab Depth
% -- s : ScatteredInterpolant grid for Slab Strike
% -- d : ScatteredInterpolant grid for Slab Dip
%
% FORMAT OF CALL: EQ_load_zsd (slab)
%
% OVERVIEW:
% 1) Function calls in the input variable slab to determine the type of
%    slab model that wll be used.
%
% 2) Function loads in the required data and creates a scatteredInterpolant
%    grid for the data loaded that will be exported out of the function.
%
% 3) For variables without scatteredInterpolant data, set to zero.
%
% VERSIONS:
% 1) -- Final version validated on 20190419 by Nathanael Wong

%#ok<*LOAD>

if slab == 1
    disp ('Loading Slab1.0 Data ...')
    load slabcoord.dat; load slabdepth.dat;
    load slabstrxy.dat; load slabstrike.dat;
    load slabdipxy.dat; load slabdip.dat;
    disp ('Calculating scatteredInterpolant ...')
    z = scatteredInterpolant (slabcoord, slabdepth);
    s = scatteredInterpolant (slabstrxy, slabstrike);
    d = scatteredInterpolant (slabdipxy, slabdip);
    disp ('scatteredInterpolant calculated.')
    disp (' ')
elseif slab == 1.1
    disp ('Loading Slab1.0 Data ...')
    load slabcoord.dat; load slabdepth.dat;
    disp ('Calculating scatteredInterpolant ...')
    z = scatteredInterpolant (slabcoord, slabdepth); 
    s = 0; d = 0;
    disp ('scatteredInterpolant calculated.')
    disp (' ')
else
    z = 0; s = 0; d = 0;
end

end