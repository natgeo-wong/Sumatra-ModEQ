function EQ_create_printSlip (fEQ,slip)

%                           EQ_create_printSlip.m
%      EQ Function that prints the Fault Slip information in .eq files
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints the fault slip information into the .eq file.
%
% INPUT:
% -- fEQ  : .eq file ID
% -- slip : event slip information
%
% OUTPUT: N/A
%
% FORMAT OF CALL: EQ_create_printSlip (fEQ,slip)
% 
% OVERVIEW:
% 1) This function prints the slip information to the .eq files
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

fprintf (fEQ, '# Slip   Rake    Rig');
fprintf (fEQ, '        ');
fprintf (fEQ, 'rSlip     dSlip     sSlip     tSlip\n');

fprintf (fEQ, '#        (d)     (N m^-2)');
fprintf (fEQ, '   ');
fprintf (fEQ, '(m)       (m)       (m)       (m)\n');

fprintf (fEQ, '  Slip   %-5.1f   %-2d', slip.MME);
fprintf (fEQ, '         ');
fprintf (fEQ, '%-7.4f   %-7.4f   %-7.4f   %-7.4f\n\n', slip.disp);

end