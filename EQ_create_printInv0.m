function EQ_create_printInv0 (fEQ,O)

%                           EQ_create_printInv0.m
%      EQ Function that prints the inversion information in .eq files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints the inversion information found at the top of .eq
% files to give the reader more information.
%
% INPUT:
% -- fEQ : .eq file ID
% -- O   : inversion information for original setting
%
% OUTPUT: N/A
%
% FORMAT OF CALL: EQ_create_printInv0 (fEQ,O)
% 
% OVERVIEW:
% 1) This function prints the inversion in the .eq files
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

fprintf (fEQ, '# Inv0   rake0   rs0');
fprintf (fEQ, '       ');
fprintf (fEQ, 'ds0       ss0       ts0\n');

fprintf (fEQ, '#        (d)     (m)');
fprintf (fEQ, '       ');
fprintf (fEQ, '(m)       (m)       (m)\n');

fprintf (fEQ, '  Inv0   %-5.1f   %-7.4f', O(1:2));
fprintf (fEQ, '   ');
fprintf (fEQ, '%-7.4f   %-7.4f   %-7.4f\n\n', O(3:5));

end