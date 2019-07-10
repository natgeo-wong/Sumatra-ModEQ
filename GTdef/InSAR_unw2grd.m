function [ xmesh,ymesh,amp,pd ] = InSAR_unw2grd(funwName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              InSAR_unw2grd.m				        %
% convert InSAR ROI_PAC unwrapped file *.unw to GMT grd file *.grd		%
% Note: need to install GMT mex for grdwrite.m					%
%										%
% INPUT:									%
% (1) funwName - input *.unw file         					%
% (2) implicitly input *.unw.rsc file						%
%										%
% OUTPUT:									%
% (1) GMT Grid file								%
% (2) meshgrid for both amplitude and phase					%
%										%
% Conversion Notes:								%
% UNW: gridline registration; 1st point is top left  				%
% GMT: default gridline registration; 1st point is bottom left			%
%										%
% based on unw2grd.m by Emma Hill  6/5/2006 					%
% function used: InSAR_readrsc.m 						%
% first created by lfeng Thu Oct 13 15:41:39 SGT 2011				%
% last modified by lfeng Fri Oct 14 14:44:28 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

frscName = [ funwName '.rsc' ];

%%%%%%%%%% read in resource file for *.unw %%%%%%%%%%
[ rsc ] = InSAR_readrsc(frscName);
fprintf(1,'\nfile width = %.0f length = %.0f\n',rsc.width,rsc.length);

%%%%%%%%%% create x and y coordinates %%%%%%%%%%
xcoords = [ rsc.xfirst:rsc.xstep:rsc.xlast ];			% longitude
ycoords = [ rsc.yfirst:rsc.ystep:rsc.ylast ];			% latitude

%%%%%%%%%% read in unw file %%%%%%%%%%
%%% Read in binary interleave file
%%% Little-endian (Linux) = 'ieee-le'
%%% Big-endian (Sun) = 'ieee-be'
imgSize = [ rsc.length,rsc.width,2 ];
fprintf(1,'\n.......... InSAR_unw2grd: reading in .unw file (amplitude band) ..........\n');
amp = multibandread(funwName, imgSize, 'float', 0, 'bil', 'ieee-le', {'Band', 'Direct', 1});

fprintf(1,'\n.......... InSAR_unw2grd: reading in .unw file (phase band) ..........\n');
pd = multibandread(funwName, imgSize, 'float', 0, 'bil', 'ieee-le', {'Band', 'Direct', 2});

%%%%%%%%%% mesh grid %%%%%%%%%%
[ xmesh,ymesh ] = meshgrid(xcoords,ycoords);
mesh(xmesh,ymesh,pd);

%%%%%%%%%% save GMT grid file %%%%%%%%%%
cellName = regexp(funwName,'\.','split');
basename = char(cellName(1));
fgrdName = [ basename '.grd' ];
% will automatically reverse the y axis
% 0 - gridline registration; 1 - pixel registration
grdwrite(xcoords, ycoords, pd, fgrdName, 'converted by InSAR_unw2grd', 0);	
