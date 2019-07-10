function [] = multiGeoTiff2dem(range,fout_prefix)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         multiGeoTiff2dem.m					%
% matlab program to convert multiple GeoTiff files (format of ASTER GDEM)       %
% to .dem & .dem.rsc (DEM inputs to InSAR ROI_PAC)			 	%
% Note: 									%
%  (1) GeoTiff uses Node/Pixel Registration, while dem is gridline registration %
%      Netcdf grd flag - Node_offset                                            %
%      node_offset = 1: node/pixel registration                                 %
%      e.g. x range = [-180 180], the data are -179.5,178.5,-177.5,......       %
%      node_offset = 0: gridline registraion                                    %
%      e.g. x range = [-180 180], the data are -180,-179,-178,......            %
%  (2) Adjacent tiles have one col/row overlapping that need to be removed	%
%      when merging tiles							%
%  (3) NaN value is -9999, SRTM use -32768					% 
%      adjacent tiles have one col/row overlapping				%
% INPUT:									%
% (1) range - GMT type specifys [lonmin lonmax latmin latmax] [1x4]		%
% (2) output file basename							%
% OUPUT:									%
% (1) fout_prefix.dem - signed integer 2-byte binary file in Lon Lat		%
% (2) fout_prefix.dem.rsc - metadata for .dem including	fields			%
%     FILE_DIR	/home/lfeng/SLM2010/SLM_ALOS/DEM/ASTER_GDEM/ASTGTM_S08E158      %
%     WIDTH		3601                                                    %
%     FILE_LENGTH	3601                                                    %
%     XMIN		0                                                       %
%     XMAX		3600                                                    %
%     YMIN		0                                                       %
%     YMAX		3600                                                    %
%     X_FIRST		158.000000000                                           %
%     Y_FIRST		-7.000000000                                            %
%     X_STEP		0.000277778                                             %
%     Y_STEP		-0.000277778                                            %
%     X_UNIT		degres                                                  %
%     Y_UNIT		degres                                                  %
%     Z_OFFSET		0.00000                                                 %
%     Z_SCALE		1.000000000                                             %
%     PROJECTION	LATLON                                                  %
%										%
% Related Programs: GeoTiff2dem.m						%
% first created by Lujia Feng Tue Jun  8 05:49:06 EDT 2010			%
% last modified by Lujia Feng Wed Jun  9 22:24:04 EDT 2010			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lonmin = range(1); lonmax = range(2);
latmin = range(3); latmax = range(4);
if lonmin>180||lonmax>180, error('use longitude in [-180 180]'); end
if lonmin>=lonmax, error('lonmin must be smaller than lonmax'); end
if latmin>=latmax, error('latmin must be smaller than latmax'); end

% some default parameters for one GDEM tile
GDEM_prefix = 'ASTGTM_';
GDEM_suffix = '_dem.tif';
% ASTER GDEM default directory includes tile folders like ASTGTM_S08E158
FILE_DIR 	= '/home/lfeng/SLM2010/SLM_ALOS/DEM/ASTER_GDEM/';
GDEM_WIDTH      = 3601;
width		= GDEM_WIDTH-1;
GDEM_LENGTH   	= 3601;                                           
length		= GDEM_LENGTH-1;
X_STEP          = 0.000277778;		% 1/3600
xinc            = 0.000277778;
xinc_half       = xinc*0.5;
Y_STEP          = -0.000277778;
yinc            = 0.000277778;
yinc_half       = yinc*0.5;
X_UNIT        	= 'degres';                                   
Y_UNIT          = 'degres';                                                       
Z_OFFSET        = 0;
Z_SCALE         = 1;                                                           
PROJECTION      = 'LATLON';                                                       

% integer values for tiles needed
% these values are good starting points for gridline registration
%lon0 = floor(lonmin); lat0 = floor(latmin);
lon0 = floor(lonmin+xinc_half); lat0 = floor(latmin+yinc_half);
%lon9 = floor(lonmax); lat9 = floor(latmax);
lon9 = floor(lonmax-xinc_half); lat9 = floor(latmax-yinc_half);

% num of cols/rows outside the region
xnum_left = round((lonmin-lon0)/xinc); 
xnum_rght = round((lon9+1-lonmax)/xinc);
ynum_up   = round((lat9+1-latmax)/yinc);  
ynum_dw   = round((latmin-lat0)/yinc);   

% values for tiles that don't exist are zeros by default
alltiles = zeros((lat9-lat0+1)*length+1,(lon9-lon0+1)*width+1); 	
% combine all tiles first
for yy = lat9:-1:lat0
    for xx = lon0:lon9
       if yy>=0 ns = 'N'; else ns = 'S'; end
       if xx>=0 ew = 'E'; else ew = 'W'; end
       tile = strcat(ns,num2str(abs(yy),'%02d'),ew,num2str(abs(xx),'%03d'));
       path_name = strcat(FILE_DIR,GDEM_prefix,tile);
       tile_name = strcat(GDEM_prefix,tile,GDEM_suffix);
       full_name = strcat(path_name,'/',tile_name);
       fprintf(1,'processing %s\n',full_name);
       % when tile exists
       if exist(path_name,'dir')==7
       	   dx = xx-lon0; dy = lat9-yy; 
 	   [elev] = geotiffread(full_name);
	   alltiles(dy*length+1:dy*length+GDEM_LENGTH,dx*width+1:dx*width+GDEM_WIDTH) = elev;
       end
    end
end

% remove cols/rows outside the range box
newtiles = alltiles(1+ynum_up:end-ynum_dw,1+xnum_left:end-xnum_rght);

% set other information about GeoTiff file
[ FILE_LENGTH WIDTH ] = size(newtiles);
XMIN = 0; XMAX = WIDTH-1;
YMIN = 0; YMAX = FILE_LENGTH-1;
X_FIRST = (xnum_left-1)*xinc+lon0;
Y_FIRST = (1-ynum_up)*yinc+(lat9+1);

% reshape
newtiles = reshape(newtiles',1,[]);

% write .dem file
% important: round float values to int16
newtiles = int16(newtiles);
fout_dem_name = strcat(fout_prefix,'.dem');
fprintf(1,'writing %s \n',fout_dem_name);
fout_dem = fopen(fout_dem_name,'w');
fwrite(fout_dem,newtiles,'int16','l');		% l is little-endian; can be ignored if using on the same machine
fclose(fout_dem);

% write .rsc file
fout_rsc_name = strcat(fout_prefix,'.dem.rsc');
fprintf(1,'writing %s \n',fout_rsc_name);
fout_rsc = fopen(fout_rsc_name,'w');
fprintf(fout_rsc,'FILE_DIR\t%s \nWIDTH\t\t%d \nFILE_LENGTH\t%d \nXMIN\t\t%d \nXMAX\t\t%d \nYMIN\t\t%d \nYMAX\t\t%d \nX_FIRST\t\t%-15.9f \nY_FIRST\t\t%-15.9f \nX_STEP\t\t%-15.9f \nY_STEP\t\t%-15.9f \nX_UNIT\t\t%s \nY_UNIT\t\t%s \nZ_OFFSET\t%-10.5f \nZ_SCALE\t\t%-15.9f \nPROJECTION\t%s\n',...
        FILE_DIR,WIDTH,FILE_LENGTH,XMIN,XMAX,YMIN,YMAX,X_FIRST,Y_FIRST,X_STEP,Y_STEP,X_UNIT,Y_UNIT,Z_OFFSET,Z_SCALE,PROJECTION);
fclose(fout_rsc);
fprintf(1,'multiGeoTiff2dem done!\n');
