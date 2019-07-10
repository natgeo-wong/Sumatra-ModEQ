function EQgeom = EQ_create_geom (EQtype)

%                           EQ_input_fltext.m
%         EQ Function that imports values for fault strike and dip
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of calling the fault parameters
% that are defined by external data, namely the fault strike and dip.  For
% flttypes 2 and 4 which do not require inputs for strike, the variable str
% is saved as 0, and is not used in the parent function.
%
% The data is taken from the GCMT catalog.
%
% INPUT:
% -- Type of Fault Model (flttype)
%
% OUTPUT:
% -- Fault Strike (str) (for flttypes 1 & 3 only)
% -- Fault Dip (dip)
%
% FORMAT OF CALL: EQ_input_fltext (Fault Type)
% 
% OVERVIEW:
% 1) This calls as input the flttype in order to determine the appropriate
%    subfunctions to call to define the strike.  If strike is not required
%    for the fault type, then the strike is automatically set to 0.
%
% 2) The function will then call subfunctions to import the fault strike
%    and dip.
%
% 3) The subfunctions that are called will define the strike and dip of the
%    fault depending on the flttype that was input and return these
%    coordinates as output.
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
%    -- Modified on 20160615 by Nathanael Wong
%    -- Now calls subfunctions for strike and dip

%%%%%%%%%%%%%%%%%%%%%% INITIALIZING "TYPE" STRUCTURE %%%%%%%%%%%%%%%%%%%%%%

flt = EQtype(1); slab = EQtype(3);

%%%%%%%%%%%%%%%%%%%%%%%%% IMPORT THE FAULT STRIKE %%%%%%%%%%%%%%%%%%%%%%%%%

if slab == 1, str = NaN; dip = NaN;
else str = EQ_create_geomstr (flt); dip = EQ_create_geomdip;
end

EQgeom = [ str dip ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end