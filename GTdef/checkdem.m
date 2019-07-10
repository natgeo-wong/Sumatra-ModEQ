function [] = checkdem(fdem_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              interpdem.m				          %
% matlab program to fill NaN holes in dem data using the average of nearby points %
% INPUT:									  %
% (1) dem file name								  %
% (2) output new dem file							  %
% OUTPUT:									  %
% (1) new *.dem file								  %
% (2) related resource *.dem.rsc file						  %
% not complete
%										  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in *.dem.rsc first
frsc_name = strcat(fdem_name,'.rsc');
fprintf(1,'reading %s\n',frsc_name);
[width,file_length,x_first,y_first,x_step,y_step,z_offset,z_scale] = readrsc(frsc_name);

% read in .dem
fprintf(1,'reading %s\n',fdem_name);
fdem = fopen(fdem_name,'r');
Z = fread(fdem,'int16');
fclose(fdem);

% ASTER_GDEM uses -9999 as NaN; STRM uses -32768
% reset all -9999 as -32768
ind = find(Z==-9999&Z==-32768);
size(ind)

min(Z)
max(Z)
