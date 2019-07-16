function EQ_create_printType (fEQ,type)

%                           EQ_create_printType.m
%    EQ function that prints the model type info to string for filename
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints the model type information into the .eq file.
%
% INPUT:
% -- fEQ  : .eq file ID
% -- tyoe : GTdef model type information
%
% OUTPUT: N/A
%
% FORMAT OF CALL: EQ_create_printType (fEQ,GTdef model type)
% 
% OVERVIEW:
% 1) This function prints the GTdef model type into the .eq file
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

fprintf (fEQ, '# Type   flt   pnt   slab   evt   reg\n');
fprintf (fEQ, '  Type   %d     %d     %3.1f    %d     %d\n\n', type);

end