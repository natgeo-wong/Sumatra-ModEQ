function [ slip ] = EQ_load_slipvec (rake,data,size)

%                          EQ_load_slipvec.m
%      EQ Function that calculates the slip vectors for each rake
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the slip vectors for each rake.  The slip along
% the rake of course remains constant, but the slip along the strike, dip
% and tensile directions all change depending on the rake angle.
%
% INPUT:
% -- rake : rake for this iteration
% -- data : event information
% -- size : grid size
%
% OUTPUT:
% -- slip : array containing the slip vectors (replicated to match the grid
%           size for calling and printing)
%
% FORMAT OF CALL: EQ_load_slipvec (rake,event data,grid size)
%
%
% OVERVIEW:
% 1) Takes as input the rake of the loop iteration, the earthquake initial
%    data and the grid size of the loop
%
% 2) Calculate the strike-slip from the rake
%
% 3) Converts the rake to the equivalent in (0,360), then calculate the
%    dip-slip and strike-slip
%
% 3) Create the slip array.
%
% VERSIONS:
% 1) -- Created sometime in 2017
%
% 2) -- Final version validated and commented on 20190715 by Nathanael Wong

rs = data.slip(3); rake = mod(rake,360); ss = rs * cosd(rake);

if rake <= 180, ds = rs * sind(rake); ts = 0;
else,           ts = rs * sind(rake); ds = 0;
end

slip = [ rs ss ds ts ]; slip = repmat(slip,size,1);

end