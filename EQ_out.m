function [ d_out ] = EQ_out (outFile)

%                              EQ_misfit.m
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

[ ~,~,~,~,~,~,~,~,~,~,~,pnt_out,~,~,~,~,~,~,~ ] = GTdef_open(outFile);
  d_out = pnt_out.disp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end