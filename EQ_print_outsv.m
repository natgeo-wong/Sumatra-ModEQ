function [ outName ] = EQ_print_outsv (xx,outmat,data,GPS)

%                            EQ_print_outsv.m
%             EQ Function that prints misfit data into files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints a data matrix into text file containing the
% GPS displacement information for the small (variance explained) loop
%
% INPUT:
% -- xx     : rake ii
% -- outmat : modelled GPS displacement
% -- data   : earthquake event information
% -- GPS    : GPS displacement information
%
% OUTPUT:
% -- fID : filename
%
% FORMAT OF CALL: EQ_print_outsv (rakeii,mfitmat,data)

% OVERVIEW:
% 1) This function prints the output data into the file
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190811 by Nathanael Wong

EQID = data.EQID; EQID = strrep (EQID,'co','');
regID = data.type(5); mu = data.slip(2);
regname = EQ_create_printregname (regID);

outName = [ EQID '_' regname '_' 'Rig' num2str(mu) '_' ...
              'outsv' xx '_co.txt' ];

sites = GPS.sites; n = numel(sites);

fout = fopen (outName,'w');

fprintf (fout,'# Output DataFile for EQID: %s\n',data.EQID);
fprintf (fout,'#                    COUNT: %s\n',xx);
fprintf (fout,'#                     SIZE: S\n\n');

fprintf (fout,'# This file contains all the relevant output data for the abovementioned\n');
fprintf (fout,'# earthquake event.  This includes the following datasets:\n');
fprintf (fout,'#     - Observed Easting Displacement for all stations (m)\n');
fprintf (fout,'#     - Observed Northing Displacement for all stations (m)\n');
fprintf (fout,'#     - Observed Vertical Displacement for all stations (m)\n\n');

fprintf (fout,'# The following GPS stations recorded significant displacement\n');
for ii = 1 : n
    fprintf (fout,'#     - (%02d) %s\n',ii,sites{ii});
end
fprintf (fout,'\n');

fprintf (fout,'# ii     ID  '); formatspec = '  %-4d   %-5d';
for ii = 1 : n
    fprintf (fout,'    %02dE (m)    %02dN (m)    %02dV (m)',ii,ii,ii);
    formatspec = [ formatspec '   %-8.5f   %-8.5f   %-8.5f' ]; %#ok<AGROW>
end
fprintf (fout,'\n');

formatspec = [ formatspec '\n' ];
fprintf (fout,formatspec, outmat');

fclose(fout);