function dip = EQ_create_geomdip

%                            EQ_input_geomdip.m
%          EQ Function that defines user input for the fault dip
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of determining the dip of the
% fault by user input.
%
% INPUT: N/A
%
% OUTPUT:
% -- dip : fault dip
%
% FORMAT OF CALL: EQ_create_geomdip
%
% OVERVIEW:
% 1) This asks for the user to input the dip, and exports it as a variable
%    output after checking to see if the dip is valid.
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORT THE FAULT DIP %%%%%%%%%%%%%%%%%%%%%%%%%%%

disp ('The value of dip ranges from 0 to 90.  All angles are measured');
disp ('with respect to the surface.');
dip = input ('Dip of Fault (d): ');
disp (' ')
while dip < 0 || dip > 90
    disp ('Error!  Dip must be between 0 to 90.')
    dip = input ('Dip of Fault (d): ');
    disp (' ')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end