function EQ_create_printHead (fEQ,ID)

%                           EQ_create_printHead.m
%        EQ Function that prints the header information in .eq files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints the header information found at the top of .eq files
% to give the reader more information.
%
% INPUT:
% -- fEQ : .eq file ID
% -- ID  : earthquake ID information
%
% OUTPUT: N/A
%
% FORMAT OF CALL: EQ_create_printHead (fEQ,ID)
% 
% OVERVIEW:
% 1) This function prints the header in the .eq files
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

fprintf (fEQ, '# Earthquake DataFile for EQID: %s\n', ID.name);
fprintf (fEQ, '  EQID   %s\n\n', ID.name);
fprintf (fEQ, '# This DataFile compiles all data for the EQ event, to be extracted\n');
fprintf (fEQ, '# by EQ_ series functions.  NaN is indicative that there is no need\n');
fprintf (fEQ, '# to extract these particular datapoints because they will be replaced\n');
fprintf (fEQ, '# or because they are not applicable to this particular flt type.\n\n');

end