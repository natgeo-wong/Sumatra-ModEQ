function [ mfit ] = EQ_mfit (outmat,r,d_act,d_err)

% %                              EQ_mfit.m
%       EQ Function that calculates Misfit for each Loop Iteration
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the misfit, or in layman terms the difference
% between the model projection displacements and the observed displacements
% recorded by SuGAr stations.  The misfit has units of meters, as all
% displacements are in meters.
%
% INPUT:
% -- input  : the name of the input file
% -- output : the name of the output file
% -- r      : the number of SuGAr stations
%
% OUTPUT:
% -- misfit : the difference calculated in the displacements between the
%             model projection and the recorded observations
%
% FORMAT OF CALL: EQ_loopsize_para1 (input output, r)
%
% OVERVIEW:
% 1) This function will first call for the input file, which contains the
%    actual GPS displacements recorded, and using GTdef_open will import
%    the actual displacements
%
% 2) Then the function will call for the output file that was generated
%    using GTdef on the input file, before using GTdef_open to import the
%    displacements predicted by the model.
%
% 3) The function will then calculate the misfit via taking the
%    root-mean-square of the differences between the individual parameters
%
% 4) The misfit will then be exported to the parent function.
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong

%%%%%%%%%%%%% IMPORT PREDICTED DISPLACEMENT RECORDED BY SUGAR %%%%%%%%%%%%%

d_act = reshape (d_act',1,r);
d_err = reshape (d_err',1,r);
d_out = outmat;

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