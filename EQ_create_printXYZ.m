function EQ_create_printXYZ (fEQ,pos)

%                           EQ_create_printXYZ.m
%    EQ function that prints the event position to string for filename
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints the event position information into the .eq file.
%
% INPUT:
% -- fEQ : .eq file ID
% -- pos : structure containing event position information
%          - .xy for (lon,lat) positioning
%          - .z for (burial,locking) depth
%
% OUTPUT: N/A
%
% FORMAT OF CALL: EQ_create_printXYZ (fEQ,position information)
% 
% OVERVIEW:
% 1) This function prints the GTdef model type into the .eq file
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

fprintf (fEQ, '# XYZ    lon1       lat1');
fprintf (fEQ, '      ');
fprintf (fEQ, 'lon2       lat2');
fprintf (fEQ, '      ');
fprintf (fEQ, 'z1       z2\n');

fprintf (fEQ, '#        (d)        (d)');
fprintf (fEQ, '       ');
fprintf (fEQ, '(d)        (d)');
fprintf (fEQ, '       ');
fprintf (fEQ, '(m)      (m)\n');

fprintf (fEQ, '  XYZ    %-08.3f   %-07.3f   %-08.3f   %-07.3f', pos.xy);
fprintf (fEQ, '   ');
fprintf (fEQ, '%-06d   %-06d\n\n', pos.z);

end