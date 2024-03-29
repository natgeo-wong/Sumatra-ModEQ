function type = EQ_create_type

%                            EQ_create_type.m
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
% INPUT: N/A
%
% OUTPUT:
% -- type : GTdef model type information
%
% FORMAT OF CALL: EQ_create_type
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
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%% INITIALIZING "TYPE" STRUCTURE %%%%%%%%%%%%%%%%%%%%%%

flt  = EQ_create_typeflt;
pnt  = EQ_create_typepnt;
slab = EQ_create_typeslab;
evt  = EQ_create_typeevt (slab);
reg  = EQ_create_typereg (evt);

type = [ flt pnt slab evt reg ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end