function [] = interpdem(fdem_name,fout_name,zmin,zmax)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              interpdem.m				          %
% matlab program to fill NaN holes in dem data using the average of nearby points %
% INPUT:									  %
% (1) dem file name								  %
% (2) output new dem file							  %
% OUTPUT:									  %
% (1) new *.dem file								  %
% (2) related resource *.dem.rsc file						  %
%										  %
% first created by Lujia Feng Thu Jun 10 02:43:30 EDT 2010			  %
% last modified by Lujia Feng Thu Jun 10 04:10:28 EDT 2010			  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in *.dem.rsc first
frsc_name = strcat(fdem_name,'.rsc');
fprintf(1,'reading %s\n',frsc_name);
[width,file_length,x_first,y_first,x_step,y_step,z_offset,z_scale] = readrsc(frsc_name);
% make a copy
foutrsc_name = strcat(fout_name,'.rsc');
copyfile(frsc_name,foutrsc_name,'f');

% read in .dem
fprintf(1,'reading %s\n',fdem_name);
fdem = fopen(fdem_name,'r');
Z = fread(fdem,'int16');
fclose(fdem);

% ASTER_GDEM uses -9999 as NaN; STRM uses -32768
% reset all -9999 as -32768
ind = find(Z==-9999);
Z(ind) = -32768;

% set unreasonable values (<zmin or >zmax) as -32768
% set a very large or small value like -9999 or 9999 if not using this feature
ind = find(Z<zmin|Z>zmax);
Z(ind) = -32768;

% fill NaN using the average of nearby non-NaN points
fprintf(1,'filling holes ');
tic
ind = find(Z==-32768);
num = size(ind);
total = file_length*width;
for nn = 1:num
   nbsum = 0; nbnum = 0;
   dd = ind(nn); 
   % up neighbor
   nbind = dd-1;
   if nbind>0&&nbind<=total
       nb = Z(nbind); 
       if nb>-32768, nbsum = nbsum+nb; nbnum = nbnum+1; end
   end
   % down neighbor
   nbind = dd+1;
   if nbind>0&&nbind<=total
       nb = Z(nbind); 
       if nb>-32768, nbsum = nbsum+nb; nbnum = nbnum+1; end
   end
   % left neighbor
   nbind = dd-file_length;
   if nbind>0&&nbind<=total
       nb = Z(nbind); 
       if nb>-32768, nbsum = nbsum+nb; nbnum = nbnum+1; end
   end
   % upleft neighbor
   nbind = dd-file_length-1;
   if nbind>0&&nbind<=total
       nb = Z(nbind); 
       if nb>-32768, nbsum = nbsum+nb; nbnum = nbnum+1; end
   end
   % downleft neighbor
   nbind = dd-file_length+1;
   if nbind>0&&nbind<=total
       nb = Z(nbind); 
       if nb>-32768, nbsum = nbsum+nb; nbnum = nbnum+1; end
   end
   % right neighbor
   nbind = dd+file_length;
   if nbind>0&&nbind<=total
       nb = Z(nbind); 
       if nb>-32768, nbsum = nbsum+nb; nbnum = nbnum+1; end
   end
   % upright neighbor
   nbind = dd+file_length-1;
   if nbind>0&&nbind<=total
       nb = Z(nbind); 
       if nb>-32768, nbsum = nbsum+nb; nbnum = nbnum+1; end
   end
   % downright neighbor
   nbind = dd+file_length+1;
   if nbind>0&&nbind<=total
       nb = Z(nbind); 
       if nb>-32768, nbsum = nbsum+nb; nbnum = nbnum+1; end
   end
   if nbnum>0, Z(dd) = nbsum/nbnum; end
end
toc

% write .dem file
% important: round float values to int16
fprintf(1,'writing %s \n',fout_name);
fdem = fopen(fout_name,'w');
fwrite(fdem,Z,'int16','l');		% l is little-endian; can be ignored if using on the same machine
fclose(fdem);
fprintf(1,'DEM is ready!\n');
