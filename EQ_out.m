function [ d_out ] = EQ_out (fout)

%                                EQ_out.m
%     EQ Function that extracts the displacement from the GTdef output
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function extracts the modelled displacements from the GTdef output
% files
%
% INPUT:
% -- fout : output file name
%
% OUTPUT:
% -- d_out : modelled displacement
%
% FORMAT OF CALL: EQ_out (output file)
%
% OVERVIEW:
% 1) This function will open the output file and extract the modelled
%    displacement data at the GPS stations.
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190716 by Nathanael Wong

%%%%%%%%%%%%% IMPORT PREDICTED DISPLACEMENT RECORDED BY SUGAR %%%%%%%%%%%%%

[ ~,~,~,~,~,~,~,~,~,~,~,pnt_out,~,~,~,~,~,~,~ ] = GTdef_open(fout);
  d_out = pnt_out.disp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end