function flt = EQ_create_typeflt

%                          EQ_create_typeflt.m
%             EQ Function that defines the GTdef model type
%                    Nathanael Wong Zhixin, Feng Lujia
%
% This function defines the GTdef model fault type and therefore the type
% of input information that is required.
%
% INPUT: N/A
%
% OUTPUT:
% -- flt : GTdef model fault type information
%
% FORMAT OF CALL: EQ_create_typeflt
% 
% OVERVIEW:
% 1) This calls as input the type of fault model and exports it to the
%    parent function
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%% SELECTION OF FAULT MODEL %%%%%%%%%%%%%%%%%%%%%%%%%

disp ('Type of Fault Model ranges from 1 to 4');
flt = input ('Type of Fault Model: ');
disp (' ');

while ~any(flt == 1:4)
    disp ('Error!  Please input a valid fault model type.');
    disp ('Type of GTdef Fault Model that can be run by EQ_ functions');
    disp ('ranges from 1 to 4');
    flt = input ('Type of Fault Model: ');
    disp (' ');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end