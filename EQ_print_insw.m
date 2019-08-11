function [ fID ] = EQ_print_insw (xx,inmat,data)

%                              EQ_print_insw.m
%           EQ Function that defines the names of the input files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints the data for the weighted variance-explained into
% text file.
%
% INPUT:
% -- xx    : rake ID
% -- inmat : model data
% -- data  : event initial information
%
% OUTPUT:
% -- fID   : file name
%
% FORMAT OF CALL: EQ_print_insw (rakeii,inmat,data)
% 
% OVERVIEW:
% 1) This function extracts information on the event to create the filename
%
% 2) The function then creates the file
%
% 3) The function then prints the data into the file
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190811 by Nathanael Wong

EQID = data.EQID; EQID = strrep (EQID,'co','');
regID = data.type(5); mu = data.slip(2);
regname = EQ_create_printregname (regID);

fID = [ EQID '_' regname '_' 'Rig' num2str(mu) '_' ...
              'insw' xx '_co.txt' ];

fin = fopen (fID,'w');

fprintf (fin,'# Input DataFile for EQID: %s\n',data.EQID);
fprintf (fin,'#                   COUNT: %s\n',xx);
fprintf (fin,'#                    SIZE: S (WEIGHTED)\n\n');

fprintf (fin,'# This file contains all the relevant input data for the abovementioned\n');
fprintf (fin,'# earthquake event.  This includes the following datasets:\n');
fprintf (fin,'#     - Longitude / Latitude (d)\n');
fprintf (fin,'#     - Surface Longtitude / Latitude (d)\n');
fprintf (fin,'#     - z1 and z2 Depth (m)\n');
fprintf (fin,'#     - Strike, Dip, Rake (d)\n');
fprintf (fin,'#     - Rake-, Strike-, Dip- and Tensile-Slip (m)\n\n');

fprintf (fin,[ '# ii     ID      lon1 (d)   lat1 (d)   lon2 (d)' ...
    '   ' ... 
    'lat2 (d)   slon1 (d)   slat1 (d)   slon2 (d)   slat2 (d)' ...
    '   ' ...
    'z1 (m)    z2 (m)    str (d)   dip (d)   rake (d)' ...
    '   ' ...
    'rs (m)    ss (m)    ds (m)    ts (m)\n']);

fprintf (fin,[ '  %-4d   %-5d   %-8.3f   %-7.3f    %-8.3f   %-7.3f' ...
    '    ' ...
    '%-8.3f    %-7.3f     %-8.3f    %-7.3f     %-6.0f    %-6.0f' ...
    '    ' ...
    '%-5.1f     %-5.1f     %-5.1f' ...
    '      ' ...
    '%-7.4f   %-7.4f   %-7.4f   %-7.4f\n' ], inmat');

fclose(fin);