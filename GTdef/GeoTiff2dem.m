function [] = GeoTiff2dem(fin_name,fout_prefix)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GeoTiff2dem.m				        %
% matlab program to convert GeoTiff format (used by ASTER GDEM) to 		%
% .dem & .dem.rsc (DEM inputs to InSAR ROI_PAC)					%
% Note:										%
%  (1) GeoTiff uses Node/Pixel Registration, while dem is gridline registration %
%      Netcdf grd flag - Node_offset                                            %
%      node_offset = 1: node/pixel registration                                 %
%      e.g. x range = [-180 180], the data are -179.5,178.5,-177.5,......       %
%      node_offset = 0: gridline registraion                                    %
%      e.g. x range = [-180 180], the data are -180,-179,-178,......            %
%  (2) Adjacent tiles have one col/row overlapping that need to be removed	%
%      when merging tiles							%
%  (3) NaN value is -9999, SRTM use -32768                           		%
% INPUT:									%
% (1) GeoTiff file name								%
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
% Related Programs: multiGeoTiff2dem.m						%
% first created by Lujia Feng Tue Jun  8 03:29:58 EDT 2010			%
% last modified by Lujia Feng Wed Jun  9 22:31:23 EDT 2010			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get information about GeoTiff file
fprintf(1,'reading %s info\n',fin_name);
info = geotiffinfo(fin_name);

% set variables for .rsc file
FILE_DIR 	= pwd;
WIDTH         	= info.Width;
FILE_LENGTH   	= info.Height;                                           
XMIN            = 0;                                              
XMAX            = WIDTH-1;
YMIN            = 0;                                               
YMAX            = FILE_LENGTH-1;
X_FIRST         = info.BoundingBox(1,1);
x_last	        = info.BoundingBox(2,1);
Y_FIRST         = info.BoundingBox(2,2);	% y_first > y_last
y_last          = info.BoundingBox(1,2); 
%X_STEP          = (x_last-X_FIRST)/(WIDTH-1); 
X_STEP          = (x_last-X_FIRST)/WIDTH; 	% test show more accurate due to Pixel Registration
%Y_STEP          = (y_last-Y_FIRST)/(FILE_LENGTH-1);
Y_STEP          = (y_last-Y_FIRST)/FILE_LENGTH;
X_UNIT        	= 'degres';                                   
Y_UNIT          = 'degres';                                                       
Z_OFFSET        = 0;
Z_SCALE         = 1;                                                           
PROJECTION      = 'LATLON';                                                       

% convert from node/pixel registration to gridline registration
X_FIRST = X_FIRST+0.5*X_STEP;
Y_FIRST = Y_FIRST+0.5*Y_STEP;

% write .rsc file
fout_rsc_name = strcat(fout_prefix,'.dem.rsc');
fout_rsc = fopen(fout_rsc_name,'w');
fprintf(1,'writing %s \n',fout_rsc_name);
fprintf(fout_rsc,'FILE_DIR\t%s \nWIDTH\t\t%d \nFILE_LENGTH\t%d \nXMIN\t\t%d \nXMAX\t\t%d \nYMIN\t\t%d \nYMAX\t\t%d \nX_FIRST\t\t%-15.9f \nY_FIRST\t\t%-15.9f \nX_STEP\t\t%-15.9f \nY_STEP\t\t%-15.9f \nX_UNIT\t\t%s \nY_UNIT\t\t%s \nZ_OFFSET\t%-10.5f \nZ_SCALE\t\t%-15.9f \nPROJECTION\t%s\n',...
        FILE_DIR,WIDTH,FILE_LENGTH,XMIN,XMAX,YMIN,YMAX,X_FIRST,Y_FIRST,X_STEP,Y_STEP,X_UNIT,Y_UNIT,Z_OFFSET,Z_SCALE,PROJECTION);
fclose(fout_rsc);

% write .dem file
[elev] = geotiffread(fin_name);
% important: round float values to int16
elev = int16(elev);
fout_dem_name = strcat(fout_prefix,'.dem');
fout_dem = fopen(fout_dem_name,'w');
fprintf(1,'writing %s \n',fout_dem_name);
elev = reshape(elev',1,[]);
fwrite(fout_dem,elev,'int16','l');	% l is little-endian; can be ignored if using on the same machine
fclose(fout_dem);
fprintf(1,'GeoTiff2dem done!\n');
