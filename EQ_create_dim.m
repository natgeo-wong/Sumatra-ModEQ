function EQdim = EQ_create_dim (EQID,EQtype)

%                            EQ_create_dim.m
%         EQ Function that calculates dimensions of fault rupture
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the fault parameters that are defined not only
% by external information, but also by mathematical equations defined by
% heavily research regression models.  It returns as output the regression
% model and the dimensions of the fault-rupture.
%
% INPUT:
% -- EQID   : data structure containing EQname, date and magnitude of event
% -- EQtype : data vector containing information on type of modelling to be
%             done, and on the type of event and GPS data
%
% OUTPUT:
% -- EQdim  : data structure containing dimensions of earthquake rupture
%
% FORMAT OF CALL: EQ_create_dim (EQID,EQtype)
%
% OVERVIEW:
% 1) From the input, the function extracts the magnitude, event type and
%    the regression model to be used
%
% 2) Based on the selection of regression model, the function calls the
%    relevant subfunctions containing the specifics of the appropriate
%    regression model to obtain EQdim, which contains the information of
%    the dimensions of the fault rupture.
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
%
% 2) -- Modified sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%% INITIALIZING "TYPE" STRUCTURE %%%%%%%%%%%%%%%%%%%%%%

Mw = EQID.ID(2); evt = EQtype(4); reg = EQtype(5);

if reg == 1, EQdim = EQ_create_dimWC (Mw,evt);
elseif reg == 2, EQdim = EQ_create_dimBKOS (Mw,evt);
elseif reg == 3, EQdim = EQ_create_dimSAB (Mw,evt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end