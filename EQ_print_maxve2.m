function [ veName ] = EQ_print_maxve2 (veName,vedata,data,k)

%                            EQ_print_maxve2.m
%    EQ Function that prints weighted variance explained data into files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints a data matrix into text file containing the weighted
% variance-explained information.
%
% INPUT:
% -- veName : filename
% -- vedata : data containing weighted variance-explained
% -- data   : earthquake event input information
% -- k      : 1,2,3 denoting whether first, second or third bestfit
%
% OUTPUT:
% -- veName : filename
%
% FORMAT OF CALL: EQ_print_maxve2 (fileName,vedata,eqinfo,rakeii)
% 
% OVERVIEW:
% 1) This function prints the weighted variance-explained data
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190811 by Nathanael Wong

fmve = fopen (veName,'w');
vedata(:,8:10) = [];

fprintf (fmve,'# Misfit DataFile for EQID: %s\n',data.EQID);
fprintf (fmve,'#                     SIZE: SW (%d)\n',k);
fprintf (fmve,'#\n');
fprintf (fmve,'# This file contains the relevant misfit data for the abovementioned\n');
fprintf (fmve,'# earthquake event.\n');
fprintf (fmve,'#\n');
fprintf (fmve,[ '# ii     ID      lon1 (d)   lat1 (d)' ...
    '   ' ... 
    'clon (d)   clat (d)   rake     varew (%%)\n']);

fprintf (fmve,[ '  %-4d   %-5d   %-8.3f   %-7.3f' ...
    '    ' ...
    '%-8.3f   %-7.3f    %-6.1f   %-9.4f\n' ], vedata');

fclose(fmve);

end