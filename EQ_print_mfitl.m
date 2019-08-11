function [ fID ] = EQ_print_mfitl (xx,mfitmat,data)

%                            EQ_print_mfitl.m
%             EQ Function that prints misfit data into files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints a data matrix into text file containing the
% misfit information for the large loop
%
% INPUT:
% -- xx      : rake ii
% -- mfitmat : misfit data matrix
% -- data    : earthquake event information
%
% OUTPUT:
% -- fID : filename
%
% FORMAT OF CALL: EQ_print_mfitl (rakeii,mfitmat,data)

% OVERVIEW:
% 1) This function prints the misfit data into the file
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190811 by Nathanael Wong

EQID = data.EQID; EQID = strrep (EQID,'co','');
regID = data.type(5); mu = data.slip(2);
regname = EQ_create_printregname (regID);

fID = [ EQID '_' regname '_' 'Rig' num2str(mu) '_' 'mfitl' xx '_co.txt' ];

fmfit = fopen (fID,'w');

fprintf (fmfit,'# Misfit DataFile for EQID: %s\n',data.EQID);
fprintf (fmfit,'#                    COUNT: %s\n',xx);
fprintf (fmfit,'#                     SIZE: L\n\n');

fprintf (fmfit,'# This file contains all the relevant misfit data for the abovementioned\n');
fprintf (fmfit,'# earthquake event.  This includes the following datasets:\n');
fprintf (fmfit,'#     - Absolute misfit (mm)\n');
fprintf (fmfit,'#     - Variance Explained (%%)\n');
fprintf (fmfit,'#     - Weighted Variance\n');
fprintf (fmfit,'#     - Kernel Density\n\n');

fprintf (fmfit,[ '# ii     ID      lon1 (d)   lat1 (d)   clon (d)' ...
    '   ' ... 
    'clat (d)   rake     mfit (mm)    vare (%%)    mfitw (m)    varew (%%)\n']);

fprintf (fmfit,[ '  %-4d   %-5d   %-8.3f   %-7.3f    %-8.3f   %-7.3f' ...
    '    ' ...
    '%-6.1f   %-9.6f    %-9.4f   %-9.6f    %-9.4f\n' ], mfitmat');

fclose(fmfit);