function [] = dem2grd(fdem_name,fout_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              dem2grd.m				        %
% matlab program to convert .dem & .dem.rsc (DEM inputs to InSAR ROI_PAC)	%
% to grd file recognized by GMT							%
% Note: 									%
% DEMs use gridline registration, though GeoTiff uses node/pixel registration	%
%     node_offset = 1: node/pixel registration                                  %
%     e.g. x range = [-180 180], the data are -179.5,178.5,-177.5,......        %
%     node_offset = 0: gridline registraion                                     %
%     e.g. x range = [-180 180], the data are -180,-179,-178,......             %
% INPUT:									%
% (1) input *.dem file         							%
% (2) implicitly input *.dem.rsc file						%
%     example of *.dem.rsc file							%
%     FILE_DIR      /home/SAR/TEST_DIR/DEM					%
%     WIDTH         1885                                                        %
%     FILE_LENGTH   909                                                         %
%     XMIN          0                                                           %
%     XMAX          1884                                                        %
%     YMIN          0                                                           %
%     YMAX          908                                                         %
%     X_FIRST       -116.911667902                                              %
%     Y_FIRST       35.285000686                                                %
%     X_STEP        0.000833333                                                 %
%     Y_STEP        -0.000833333                                                %
%     X_UNIT        degres                                                      %
%     Y_UNIT        degres                                                      %
%     Z_OFFSET      100                                                         %
%     Z_SCALE       1                                                           %
%     PROJECTION    LATLON                                                      %
% OUTPUT:									%
% (1) Netcdf grd file								%
%										%
% Programs used: 								%
% readrsc.m written by Lujia Feng						%
% (1) GMT mex program grdwrite.m (recommended)					%
% (2) grdwrite2.m by Kelsey Jordahl (Marymount Manhattan Colleg)		%
%     This needs Netcdf libs only available in Matlab2008b or higher 		% 
% first created by Lujia Feng Tue Jun  8 16:00:50 EDT 2010			%
% last modified by Lujia Feng Mon Jul 26 16:19:36 EDT 2010			%
% The results are not robust yet        					%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in *.dem.rsc first
frsc_name = strcat(fdem_name,'.rsc');
fprintf(1,'reading %s\n',frsc_name);
[width,file_length,x_first,y_first,x_step,y_step,z_offset,z_scale] = readrsc(frsc_name);

% read .dem
fprintf(1,'reading %s\n',fdem_name);
fdem = fopen(fdem_name,'r');
Z = fread(fdem,'int16');
Z = Z*z_scale+z_offset;
zmin = min(Z); zmax = max(Z);
Z = reshape(Z,file_length,width);
% upside down when y_stemp < 0
if y_step<0
   Z = flipud(Z);
end
fclose(fdem);

% write .grd
fprintf(1,'writing %s\n',fout_name);
% y_first not necessary < y_last
x_last  = x_first+(width-1)*x_step;
y_last  = y_first+(file_length-1)*y_step;
% ymin < ymax
xmin = x_first; xmax = x_last;
ymin = min([y_first y_last]); ymax = max([y_first y_last]);
% 1 = pixel registration; 0 = grid registration
D = [ xmin xmax ymin ymax zmin zmax 0 ];
% Y&X needs to correspond to Z
%grdwrite2(X,Y,Z,fout_name);
grdwrite(Z,D,fout_name,'elevation');
fprintf(1,'grdwrite2 done!\n');
fprintf(1,'dem2grd done!\n');
