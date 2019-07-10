function [ ] = EQS_project(eq_name,flt_type,flt)

% e.g. EQS_project('Ghosh_etal_2008.catalog.interface.xyz',2,[ -85.39900767 8.88187545 -86.68729517 10.15240176 0 60e3 11 ])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EQS_project				  %
% Program to read earthquake file and get fault info from GTdef.m input   %
% and call EQ_prjpnt to project microseismicity to fault surface	  %
% coordinate								  %
% still need more work to make it more compatible			  %
%									  %
% first created by Lujia Feng Fri Dec 10 16:21:59 EST 2010		  %
% last modified by Lujia Feng Fri Dec 10 17:09:46 EST 2010		  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pnt = load(eq_name);

% output point file
[ ~,basename,~ ] = fileparts(eq_name);
fout_pname = strcat(basename,'_point.out');
fpnt = fopen(fout_pname,'w');
fprintf(fpnt,'# EQ input: %s\n# Fault input: type %d info %-14.8f %-12.8f %-14.8f %-12.8f %12.4e %12.4e %8.2f\n',eq_name,flt_type,flt);
fprintf(fpnt,'#(1)lon  (2)lat  (3)z  (4)Dstr1  (5)Dstr2  (6)Ddip  (7)Dvert\n'); 
EQ_prjpnt(fpnt,pnt,flt_type,flt);
fclose(fpnt);
