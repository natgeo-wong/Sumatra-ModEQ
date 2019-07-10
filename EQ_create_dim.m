function EQdim = EQ_create_dim (EQID,EQtype)

%                           EQ_input_fltreg.m
%      EQ Function that defines input for Fault-Rupture Dimensions
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the fault parameters that are defined not only
% by external information, but also by mathematical equations defined by
% heavily research regression models.  It returns as output the regression
% model and the dimensions of the fault-rupture.
%
% INPUT:
% -- Mw    : moment magnitude of earthquake (X.XX)
% -- dip   : dip of fault (?)
% -- z1    : vertical burial depth (m)
%
% OUTPUT:
% -- RM    : regression model
% -- len   : subsurface rupture length (m),
%            calculated from regression equations and Mw
% -- width : downdip rupture width (m),
%            calculated from regression equations and Mw
% -- z2    : vertical locking depth from surface (m),
%            calculated from z1, dip and width
%
% FORMAT OF CALL: EQ_input_fltreg (Moment Magnitude)
%
% OVERVIEW:
% 1) 
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%% INITIALIZING "TYPE" STRUCTURE %%%%%%%%%%%%%%%%%%%%%%

Mw = EQID.ID(2); evt = EQtype(4); reg = EQtype(5);

if reg == 1, EQdim = EQ_create_dimWC (Mw,evt);
elseif reg == 2, EQdim = EQ_create_dimBKOS (Mw,evt);
elseif reg == 3, EQdim = EQ_create_dimSAB (Mw,evt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end