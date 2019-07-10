function name = EQ_create_printregname (regind)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHOOSE REGRESSION %%%%%%%%%%%%%%%%%%%%%%%%%%%%

if regind == 1, name = 'WC';
elseif regind == 2, name = 'BKOS';
elseif regind == 3, name = 'SAB';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end