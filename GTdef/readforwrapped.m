% script readrsc;
%   readhgtrsc       - reads a wrapped header file
% usage:  readhgtrsc;
% At this point, the script expects that the variable 'rscfile' points
% to the *.int.rsc file
% 
% reads a ...int.rsc header file
%
% AVN, created Fri Feb 24 18:53:21 EST 2006

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% open file
fid=fopen(rscfile,'r');
line=fgetl(fid); [junk,RSC_WIDTH]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_FILE_LENGTH]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_XMIN]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_XMAX]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_YMIN]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_YMAX]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_RLOOKS]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_ALOOKS]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_X_FIRST]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_X_STEP]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_X_UNIT]=strread(line,'%s%s');
line=fgetl(fid); [junk,RSC_Y_FIRST]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_Y_STEP]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_Y_UNIT]=strread(line,'%s%s');
line=fgetl(fid); [junk,RSC_TIME_SPAN_YEAR]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_COR_THRESHOLD]=strread(line,'%s%f');
%%line=fgetl(fid); [junk,RSC_MSK_THRESHOLD]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_ORBIT_NUMBER]=strread(line,'%s%s');
line=fgetl(fid); [junk,RSC_VELOCITY]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_HEIGHT]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_EARTH_RADIUS]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_WAVELENGTH]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_DATE]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_DATE12]=strread(line,'%s%s');
line=fgetl(fid); [junk,RSC_HEADING_DEG]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_RGE_REF1]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LOOK_REF1]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LAT_REF1]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LON_REF1]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_RGE_REF1]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LOOK_REF1]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LAT_REF1]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LON_REF1]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_RGE_REF3]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LOOK_REF3]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LAT_REF3]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LON_REF3]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_RGE_REF4]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LOOK_REF4]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LAT_REF4]=strread(line,'%s%f');
line=fgetl(fid); [junk,RSC_LON_REF4]=strread(line,'%s%f');
