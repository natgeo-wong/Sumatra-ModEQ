function EQpos = EQ_create_pos (EQtype,EQdim,EQgeom)

%                              EQ_create_pos.m
%        EQ Function that defines position (lon,lat,depth) for event
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function calls subfunctions based on prior information to define the
% position (lon,lat,depth) of the fault events.
%
% INPUT:
% -- EQtype : model type input
% -- EQdim  : event rupture dimensions information
% -- EQgeom : event geometry information
%
% OUTPUT:
% -- EQpos  : structure containing the xy position and depths of the event
%             .xy - lon,lat information
%             .z  - depth information
%
% FORMAT OF CALL: EQ_create_pos (model type,dimensions,geometry)
% 
% OVERVIEW:
% 1) This calls as input the modelling, dimensions and geometry
%    information, to extract the model fault type, slab information, as
%    well as the width and dip information.
%
% 2) The function will then call subfunctions to determine the (lon,lat)
%    and depth information
%
% 3) The function then exports the information into the parent
%    script/function.
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
%    -- Modified on 20160615 by Nathanael Wong
%    -- Input of individual parameters are called by individual functions
%
%    -- Modified on 20160701 by Nathanael Wong
%    -- For fault types 1 & 3, EQlon1 and EQlat1 serve as the coordinates
%       of the epicenter
%    -- For fault types 2 & 4, the function will call for an input of the
%       epicenter coordinates in order to find the depth of the fault
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%% INITIALIZING "TYPE" STRUCTURE %%%%%%%%%%%%%%%%%%%%%%

flt = EQtype(1); slab = EQtype(3); wid = EQdim(2); dip = EQgeom(2);
EQpos.xy = []; EQpos.z = [];

%%%%%%%%%%%%%%%%%%%%%% IMPORT LONGITUDE AND LATITUDE %%%%%%%%%%%%%%%%%%%%%%

EQpos.xy = EQ_create_posxy(flt);
EQpos.z  = EQ_create_posz (slab,wid,dip);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end