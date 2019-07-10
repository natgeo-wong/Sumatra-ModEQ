function flt = EQ_create_typeflt

%                          EQ_input_datatype.m
%        EQ Function that defines the fault model and GPS datatype
%                    Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of defining the type of data
% that will be created in the source input file and in determining how the
% functions read the input files and the GPS data.  Different types of
% faults and points in the GTdef_input files have different formats and 
% will be read differently by the functions GTdef and GTdef_open which
% necessitates a function to define these important parameters.
%
% INPUT:
% -- N/A
%
% OUTPUT:
% -- Type of Fault Model (type.flt)
% -- Type of GPS Data Format (type.pnt)
%
% FORMAT OF CALL: EQ_imput_datatype
% 
% OVERVIEW:
% 1) This calls as input the type of fault model and the type of GPS data
%    format used and save them into the structured variable "type".
%
% 	 If the inputs are not in the specified format, it will generate an
%    error message and ask for the user for an input of the fault model and
%    the GPS data format used until the input formats entered are valid.
%
% 2) The variables are all exported into the parent function as output.
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong

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