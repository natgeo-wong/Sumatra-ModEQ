function [ gamra,gamout ] = GAMRA_readhdf5(fsumName,fdatName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GAMRA_readhdf5                                  %
% read GAMRA output including summary and the associated data files             %
%                                                                               %
% INPUT:                                                                        %
% fsumName - GAMRA HDF5 summary files                                           %
% fdatName - GAMRA HDF5 data files                                              %
%                                                                               %
% OUTPUT:                                                                       %
% gamra  - struct for summary info                                              %
% gamout - cell arrays for all patches                                          %
%                                                                               %
% first created by Lujia Feng Tue Nov  5 11:43:44 SGT 2013                      %
% last modified by Lujia Feng Tue Nov  5 14:17:35 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in the summary info
[ gamra ] = GAMRA_readhdf5_summary(fsumName);

% loop through patches to read in data
gamout    = cell(gamra.patchNum,1);
for ii=1:gamra.patchNum
   % data
   clevel = gamra.patch_map.level_number(ii);
   cpatch = gamra.patch_map.patch_number(ii);
   [ lambda,mu,disp,strain ] = GAMRA_readhdf5_data(fdatName,clevel,cpatch);
   gamout{ii}.lambda = lambda; 
   gamout{ii}.mu     = mu; 
   gamout{ii}.disp   = disp; 
   gamout{ii}.strain = strain; 
   % extents & center
   xlo    = gamra.patch_extents.xlo(:,ii);
   xup    = gamra.patch_extents.xup(:,ii);
   [ xloCell,xupCell,levelCell ] = GAMRA_extents2cell(xlo,xup,clevel,gamra.dx);
   [ xcrCell ] = GAMRA_extents2center(xloCell,xupCell);
   gamout{ii}.cellNum= length(levelCell); % number of cells within one patch
   gamout{ii}.xlo    = xloCell; % cell lower bounds
   gamout{ii}.xup    = xupCell; % cell upper bounds
   gamout{ii}.xcr    = xcrCell; % cell centers
   gamout{ii}.level  = levelCell; % cell levels
end
