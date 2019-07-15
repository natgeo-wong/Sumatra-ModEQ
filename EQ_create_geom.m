function EQgeom = EQ_create_geom (EQtype)

%                             EQ_input_geom.m
%         EQ Function that creates the strike and dip of the fault
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of determining the strike and
% the dip of the fault.  If the fault strike and dip are to be taken by
% external parameters (such as Slab1.0), then the strike and dip are set to
% NaN.  Otherwise, the strike and dip will be defined by user input that is
% taken from previous results such as gCMT or ANSS.
%
% INPUT:
% -- EQtype : dataset containing fault modelling information
%
% OUTPUT:
% -- EQgeom : vector containing fault geometry information
%             [ strike dip ]
%
% FORMAT OF CALL: EQ_create_geom (EQtype)
%
% OVERVIEW:
% 1) This calls as input EQtype which contains the fault modelling
%    information, and then extracts the type of model and GPS data needed
%
% 2) The function then determines if the geometry is to be determined by
%    Slab input data.  If yes, then both strike and dip are set to NaN,
%    while otherwise the function calls subfunctions to get user inputs for
%    the strike and dip parameters.
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
%    -- Modified on 20160615 by Nathanael Wong
%    -- Now calls subfunctions for strike and dip
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%% INITIALIZING "TYPE" STRUCTURE %%%%%%%%%%%%%%%%%%%%%%

flt = EQtype(1); slab = EQtype(3);

%%%%%%%%%%%%%%%%%%%%%%%%% IMPORT THE FAULT STRIKE %%%%%%%%%%%%%%%%%%%%%%%%%

if slab == 1, str = NaN; dip = NaN;
else,         str = EQ_create_geomstr(flt); dip = EQ_create_geomdip;
end

EQgeom = [ str dip ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end