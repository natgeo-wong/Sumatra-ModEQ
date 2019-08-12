function [ fID ] = EQ_print_swbfit (fID,mfitmat,data,k)

%                              EQ_print_swbfit.m
%         EQ Function that prints eq information for bestfit model
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints the earthquake data for the bestfit model
%
% INPUT:
% -- fID  : filename
% -- mfit : model data
% -- data : event initial information
% -- k    : 1,2,3 denoting whether first, second or third bestfit
%
% OUTPUT:
% -- fID   : filename
%
% FORMAT OF CALL: EQ_print_swbfit (fID,mfit,data,k)
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

fmfit = fopen (fID,'w');
mfitmat(:,8:10) = [];

fprintf (fmfit,'# Misfit DataFile for EQID: %s\n',data.EQID);
fprintf (fmfit,'#                     SIZE: BEST MFIT (%d) (SW)\n\n',k);

fprintf (fmfit,'# This file contains all the relevant misfit data for the abovementioned\n');
fprintf (fmfit,'# earthquake event.  This includes the following datasets:\n');
fprintf (fmfit,'#     - Absolute misfit (mm)\n');
fprintf (fmfit,'#     - Variance Explained (%%)\n');
fprintf (fmfit,'#     - Weighted Variance\n');
fprintf (fmfit,'#     - Kernel Density\n\n');

fprintf (fmfit,[ '# ii     ID      lon1 (d)   lat1 (d)' ...
    '   ' ... 
    'clon (d)   clat (d)   rake     varew (%%)\n']);

fprintf (fmfit,[ '  %-4d   %-5d   %-8.3f   %-7.3f' ...
    '    ' ...
    '%-8.3f   %-7.3f    %-6.1f   %-9.4f\n' ], mfitmat');

fclose(fmfit);

end