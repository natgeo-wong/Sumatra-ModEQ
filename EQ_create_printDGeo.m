function EQ_create_printDGeo (fEQ,dim,geom)

%                           EQ_create_printDGeo.m
%              EQ Function that print the event geometry to .eq
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of printing the dimensions and
% geometryinformation into .eq files, to be read and used in GTdef
%
% INPUT:
% -- fEQ  : file name
% -- dim  : dimension information
% -- geom : geometry information
%
% OUTPUT: N/A
%
% FORMAT OF CALL: EQ_create_printDGeo (fEQ,dim,geom)
% 
% OVERVIEW:
% 1) This function prints the event dimensions and geometry
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRINT HEADER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf (fEQ, '# DGeo   Len      Wid      Area');
fprintf (fEQ, '           ');
fprintf (fEQ, 'Str     Dip\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRINT UNITS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf (fEQ, '#        (m)      (m)      (m^2)');
fprintf (fEQ, '          ');
fprintf (fEQ, '(d)     (d)\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRINT DETAILS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf (fEQ, '  DGeo   %-6.0f   %-6.0f   %-e', dim);
fprintf (fEQ, '   ');
fprintf (fEQ, '%-5.1f   %-4.1f\n\n', geom);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end