function [ mfit ] = EQ_mfit (d_out,r,d_act,d_err)

%                                EQ_mfit.m
%       EQ Function that calculates Misfit for each Loop Iteration
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the misfit, or in layman terms the difference
% between the model projection displacements and the observed displacements
% recorded by SuGAr stations.  The misfit has units of meters, as all
% displacements are in meters.
%
% INPUT:
% -- d_out : modelled displacement vectors (array)
% -- d_act : observed displacement vectors (vector)
% -- d_err : uncertainty in observed displacement vectors
% -- r     : number of GPS displacement vectors
%            if pnt = 1, (1 * number of stations)
%            if pnt = 2, (2 * number of stations)
%            if pnt = 3, (3 * number of stations)
%
% OUTPUT:
% -- mfit : array of calculated misfit for current iteration
%
% FORMAT OF CALL: EQ_mfit (modelled,number,observed,uncertainty)
%
% OVERVIEW:
% 1) This function take in as input the observed displacement vectors and
%    their uncertainties (taken from GPS data), as well as the modelled
%    displacements from the entire loop (imported as array).
%
% 2) The function then proceeds to calculate the rms, and the misfit.
%
% 3) The function then exports the misfit variables to the parent function.
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
% 
% 2) -- Modified sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%% IMPORT PREDICTED DISPLACEMENT RECORDED BY SUGAR %%%%%%%%%%%%%

d_act = reshape(d_act',1,r); d_err = reshape(d_err',1,r);

d_var  = d_out - d_act;  %d_var  = bsxfun(@minus,d_out,d_act);
d_actw = d_act ./ d_err; %d_actw = bsxfun(@rdivide,d_act,d_err);
d_varw = d_var ./ d_err; %d_varw = bsxfun(@rdivide,d_var,d_err);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALCULATE MISFIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dvar = sum(d_act.^2,2); dvarw = sum(d_actw.^2,2);
var  = sum(d_var.^2,2); varw  = sum(d_varw.^2,2);

d_vare = var ./ dvar; d_varew = varw ./ dvarw;
d_rms  = var ./ r;    d_rmsw  = varw ./ r;

%d_vare = bsxfun(@rdivide,var,dvar); d_varew = bsxfun(@rdivide,varw,dvarw);
%d_rms  = bsxfun(@rdivide,var,r);    d_rmsw  = bsxfun(@rdivide,varw,r);

vare = (1 - d_vare)*100; varew = (1 - d_varew)*100;
rms  = sqrt(d_rms)*1000; rmsw  = sqrt(d_rmsw);

mfit = [ rms vare rmsw varew ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end