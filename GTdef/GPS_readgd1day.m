function [ site,day,lat,dlat,lon,dlon,height,dheight ] = GPS_readgd1day(fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           	GPS_readgd1day.m				%
% read gipsy daily gd files                             			%
%										%
% INPUT:                                                                        %
% gd FORMAT example								%
% ABGS       LAT   07JAN01      0.220824642  +-     0.0008  -0.033586  -0.017738%
% ABGS       LON   07JAN01     99.387520914  +-     0.0018   0.022608		%
% ABGS       RAD   07JAN01         236.2533  +-     0.0034			%
%										%
% OUTPUT: 									%
% site - site name 	 [string]						%
% day  - date in YYMONDD [string] 						%
% Lat(deg)+/-Sigma(m)    Lon(deg)+/-Sigma(m) Height(m)+/-Sigma(m)    		%
%										%
% first created by lfeng Fri Jul 15 15:59:40 SGT 2011				%
% last modified by lfeng Mon Jul 18 12:59:42 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file')  
    error('GPS_readgd1day ERROR: %s does not exist!',fileName); 
end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(fileName,'r');

%%%%%%%%%% read 1st line %%%%%%%%%%
gdCell = textscan(fin,'%s %*s %s %f %*s %f %*[^\n]');	% skip the rest of a line %*[~\n]
site   = char(gdCell{1}(1,:)); 			% convert cell to string; cell won't work
day    = char(gdCell{2}(1,:));				% convert cell to string; cell won't work
lat    = gdCell{3}(1); lon    = gdCell{3}(2); height  = gdCell{3}(3);
dlat   = gdCell{4}(1); dlon   = gdCell{4}(2); dheight = gdCell{4}(3);

fclose(fin);
