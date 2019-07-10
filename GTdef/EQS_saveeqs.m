function [ ] = EQS_saveeqs(eqs,foutName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               	   EQS_saveeqs						%
% read in an eqs file									    	%
%											    	%
% INPUT:					  		  			    	%
% eqs = [ yy mm dd hh min sec lon lat dep mag id decyr ]					%
% all column vectors										%
%                                                                       			%
% OUTPUT:                                  							%
% 1    2  3  4  5  6       7          8          9       10	    11		12		%
% YEAR MO DY HR MI SS.SSSS LONGITUDE  LATITUDE   DEPTH   MAGNITUDE  EVENT ID    DECYR           %
% 2008 07 04 19 46 30.3100 -118.81384 37.57717   6.3500  0.86                                   %
% 2011 07 10 05 09 06.2600 95.09900    4.61800  35.3000  4.70    201107101008  2011.521918      %
%                                                                       			%
% first created by lfeng Tue Jul 12 11:14:03 SGT 2011						%
% last modified by lfeng Tue Jul 12 13:02:06 SGT 2011						%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% open the file %%%%%%%%%%
fout = fopen(foutName,'w');

%%%%%%%%%% write the file %%%%%%%%%%
%             1   2    3    4    5    6      7      8      9     10    11   12
fprintf(fout,'%4d %02d %02d %02d %02d %07.4f %11.5f %10.5f %8.4f %5.2f %15.0f %15.6f\n',eqs');

%%%%%%%%%% close the file %%%%%%%%%%
fclose(fout);
