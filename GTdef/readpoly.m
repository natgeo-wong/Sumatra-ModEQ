function [ polyLon,polyLat ] = readpoly(polyName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             readpoly                                 %
% read in a polygon file                                               %
%                                                                      %
% INPUT:                                                               %
% polyName: name for the polygon file specifying the region            %
% Format:                                                              %
% 1   2	                                                               %
% lon lat                                                              %
%                                                                      %
% OUTPUT:                                                              %
% polyLon,polyLat  [column vectors]                                    %
%                                                                      %
% first created by Lujia Feng Tue Jul 12 10:52:15 SGT 2011             %
% last modified by Lujia Feng Fri Aug  2 04:52:43 SGT 2013             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if polygon file exists %%%%%%%%%%
if ~exist(polyName,'file')  
    error('readpoly ERROR: %s does not exist!',polyName); 
end

%%%%%%%%%% open the file %%%%%%%%%%
fin      = fopen(polyName,'r');
polyCell = textscan(fin,'%f %f','CommentStyle','#');	% Delimiter default White Space
polyMat  = cell2mat(polyCell);
polyLon  = polyMat(:,1); 
polyLat  = polyMat(:,2);
fclose(fin);
