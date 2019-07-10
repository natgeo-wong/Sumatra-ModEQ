function [ xx,yy,zz ] = readxyz(xyzName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               	readxyz					%
% read in xyz file								%
% Format:   1   2   3								%
%           Lon Lat Height							%
%										%
% INPUT:					  		  		%
% xyzName: name for the xyz file especially for DEM				%
%                                                                       	%
% OUTPUT: 									%
% xx,yy,zz  [column vectors]							%
%										%
% first created by lfeng Tue Sep 27 15:16:42 SGT 2011				%
% last modified by lfeng Tue Sep 27 20:26:17 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if polygon file exists %%%%%%%%%%
if ~exist(xyzName,'file')  
    error('readxyz ERROR: %s does not exist!',xyzName); 
end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(xyzName,'r');
xyzCell = textscan(fin,'%f %f %f','CommentStyle','#');	% Delimiter default White Space
xyz = cell2mat(xyzCell);
xx = xyz(:,1); yy = xyz(:,2); zz = xyz(:,3);
fclose(fin);
