function [] = GeoTiff2grd(fin_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GeoTiff2grd.m				        %
% matlab program to convert GeoTiff format (used by ASTER GDEM or GeoMapApp) to %
% Netcdf grd format (used by GMT)						%
% Note:										%
% (1) GeoTiff uses Node/Pixel Registration                                      %
%     so Netcdf grd uses Node/Pixel Registration too				%
%     node_offset = 1: node/pixel registration                                  %
%     e.g. x range = [-180 180], the data are -179.5,178.5,-177.5,......        %
%     node_offset = 0: gridline registraion                                     %
%     e.g. x range = [-180 180], the data are -180,-179,-178,......             %
% (2) matrix format conversion							%
%  if y_first > y_last			      if y_first < y_last		%
%  usually case for GeoTiff		      usually case for grd		%
%            width                                                              %
%  [   |       |		]           [  /|\     /|\		]       %
%  [   |       |		]           [ / | \   / | \		]       %
%  [   |       |		]   height  [   |       |		]       %
%  [ \ | /   \ | /		]           [   |       |  		]       %
%  [  \|/     \|/		]           [   |       | 		]       %
% INPUT:									%
% (1) GeoTiff file name								%
%										%
% Related Programs: GeoTiff2dem.m						%
% first created by Lujia Feng Mon Jul 26 14:45:03 EDT 2010			%
% last modified by Lujia Feng  Mon Jul 26 16:00:06 EDT 2010			%
% run with crash problem of grdwrite						%
% unsolved									%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get information about GeoTiff file
fprintf(1,'reading %s info\n',fin_name);
info = geotiffinfo(fin_name);

% get variables from GeoTiff file
width         	= info.Width; 
height   	= info.Height;                  % height = file_length in *.dem.rsc
x_first         = info.BoundingBox(1,1);	% x = longitude that corresponds to width
x_last	        = info.BoundingBox(2,1);
y_first         = info.BoundingBox(2,2);	% y = latitude that corresponds to height
y_last          = info.BoundingBox(1,2); 

% get data from GeoTiff file
[elev] = geotiffread(fin_name);

% turn upside down
if y_first > y_last
   elev = flipud(elev);
end

% IMPORTANT: convert to float
elev = single(elev);

prefix_name = strtok(fin_name,'.');
fout_name = strcat(prefix_name,'.grd');
% write grd file
fprintf(1,'writing %s \n',fout_name);
xmin = x_first; 	      xmax = x_last;
ymin = min([y_first y_last]); ymax = max([y_first y_last]);
zmin= min(min(elev));
zmax= max(max(elev)); 
% 1 = pixel registration; 0 = grid registration
D = [ xmin xmax ymin ymax zmin zmax 1 ];
% Y&X needs to correspond to Z
%grdwrite2(X,Y,Z,fout_name);
grdwrite(elev,D,fout_name,'elevation');
fprintf(1,'GeoTiff2grd done!\n');
