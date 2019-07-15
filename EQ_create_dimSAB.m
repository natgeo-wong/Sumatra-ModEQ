function size = EQ_create_dimSAB (Mw,evt)

%                          EQ_create_dimSAB.m
%      EQ Function that defines fault dimensions using SAB regression
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the fault parameters that are defined not only
% by external information, but also by mathematical equations defined by
% the SAB regression model [Strasser et al. 2010].  It returns as output
% the regression model and the dimensions of the fault-rupture.
%
% INPUT:
% -- Mw   : moment magnitude of earthquake (X.XX)
% -- evt  : event type (thrust, normal, strikeslip)
%
% OUTPUT:
% -- size : vector containing fault dimensions
%           [ length width area ]
%
% FORMAT OF CALL: EQ_create_dimSAB (Magnitude,Event Type)
%
% OVERVIEW:
% 1) Function takes in moment magnitude and event type as inputs and passes
%    to the regression function for SAB
%
% 2) Function takes the average length and width of the SAB regression
%    model and then calculates the area
%
% 3) Function takes all three dimensional variables and combines into a
%    vector and passes it as output
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
%
% 2) -- Modified sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINE EVENT TYPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ ~,~,len,~,~,wid ] = EQ_reg_SAB (Mw,evt);
area = len * wid;
size = [ len wid area ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end