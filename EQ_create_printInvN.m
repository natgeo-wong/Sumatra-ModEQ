function EQ_create_printInvN (fEQ,N)

%                           EQ_create_printInvN.m
%      EQ Function that prints the inversion information in .eq files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints the inversion information found at the top of .eq
% files to give the reader more information.
%
% INPUT:
% -- fEQ : .eq file ID
% -- N   : inversion information for number of patches
%
% OUTPUT: N/A
%
% FORMAT OF CALL: EQ_create_printInvN (fEQ,N)
% 
% OVERVIEW:
% 1) This function prints the inversion in the .eq files
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

fprintf (fEQ, '# InvN   Nd   Ns\n');

fprintf (fEQ, '  InvN   %-2d   %-2d', N);

end