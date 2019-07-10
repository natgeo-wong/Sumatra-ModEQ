function [ ] = trimcont(contName,polyName,outName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 trimcont                                      %
% Only keep contours within a polygon                                           % 
%                                                                               %
% INPUT:                                                                        %
% (1) contName: contour file                                                    %
% 1     2       3    								% 
% LON   LAT     DEPTH     							%
% contour line divider is '>'							%
%                                                                               %
% (2) polyName: polygon file specifying the region	                        %
% 1     2                                                                       %
% LON   LAT                                                                     %
%                                                                               %
% OUTPUT:                                                                       %
% outName: a new contour file                                                   %
%                                                                               %
% first created by Lujia Feng Fri Aug  2 05:08:11 SGT 2013                      %
% last modified by Lujia Feng Fri Aug  2 05:21:40 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% read in contour file %%%%%%%%%%
[ contLon,contLat,conthh ] = readcont(contName);

%%%%%%%%%%%%%%%%% read in polygon file %%%%%%%%%%%%%%%%%
[ polyLon,polyLat ] = readpoly(polyName);

%%%%%%%%%%%% keep data only in the specified region %%%%%%%%%
polyInd = inpolygon(contLon,contLat,polyLon,polyLat);    % inpoly returns the same size as contLon,contLat
nanInd  = isnan(contLon);
keepInd = polyInd | nanInd;

%%%%%%%%%% write out trimmed contour lines %%%%%%%%%%
keepLon = contLon(keepInd);
keepLat = contLat(keepInd);
keephh  = conthh(keepInd);
writecont(outName,keepLon,keepLat,keephh);
