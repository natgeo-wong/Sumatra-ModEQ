function [ ] = sites2unicycle(fileName,lon0,lat0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              sites2unicycle 			               %
%									       %
% Convert output from Emma's code to input for Sylvain Barbot's unicycle code  %
% also convert geographic coordinate to local fault coordinate                 %
%                                                                              %
% INPUT:                                                                       %
% (1) fileName - output from Emma's code                                       %
%                                                                              %
% OUTPUT:                                                                      %
%									       %
% first created by Lujia Feng Mon Sep  9 11:33:31 SGT 2013                     %
% last modified by Lujia Feng 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in 
if ~exist(fileName,'file'), error('sites2unicycle ERROR: %s does not exist!',fileName); end

fin = fopen(fileName,'r');
efm_cell = textscan(fin,'%f %f %f %f %f %f %f %f %f','CommentStyle','#');       % Delimiter default white space
efm = cell2mat(efm_cell);
fclose(fin);

% write out
[ ~,basename,~ ] = fileparts(fileName);
foutname = [ basename '.flt' ];
fout = fopen(foutname,'w');
%fault type name lon lat z1 z2 len str dip rake rs ts rake0 rakeX rs0  rsX ts0 tsX Nd Ns
fprintf(fout,'# output from sites2unicycle.m written by Lujia Feng\n');
fprintf(fout,'# no. slip north    east depth length width strike  dip rake\n');
out = [ num slip yleftup xleftup zleftup len width str dip rake ]';
fprintf(fout,'%-8d %14.6e %14.6e %15.6e %14.6e %14.6e %14.6e %8.4f %8.4f %8.4f\n',out);
fclose(fout);
