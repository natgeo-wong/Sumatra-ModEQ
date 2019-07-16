function EQ_create_printInvX (fEQ,X)

%                           EQ_create_printInvX.m
%      EQ Function that prints the inversion information in .eq files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints the inversion information found at the top of .eq
% files to give the reader more information.
%
% INPUT:
% -- fEQ : .eq file ID
% -- X   : inversion information for sweep settings
%
% OUTPUT: N/A
%
% FORMAT OF CALL: EQ_create_printInvX (fEQ,X)
% 
% OVERVIEW:
% 1) This function prints the inversion in the .eq files
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

fprintf (fEQ, '# InvX   rakeX   rsX');
fprintf (fEQ, '       ');
fprintf (fEQ, 'dsX       ssX       tsX\n');

fprintf (fEQ, '#        (d)     (m)');
fprintf (fEQ, '       ');
fprintf (fEQ, '(m)       (m)       (m)\n');

fprintf (fEQ, '  InvX   %-5.1f   %-7.4f', X(1:2));
fprintf (fEQ, '   ');
fprintf (fEQ, '%-7.4f   %-7.4f   %-7.4f\n\n', X(3:5));

end