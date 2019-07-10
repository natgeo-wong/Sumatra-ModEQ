function [ eqs ] = EQS_readeqs(filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               	   EQS_readeqs						%
% read in an eqs file									    	%
%											    	%
% INPUT:					  		  			    	%
% 1    2  3  4  5  6       7          8          9       10	    11		12		%
% YEAR MO DY HR MI SS.SSSS LONGITUDE  LATITUDE   DEPTH   MAGNITUDE  EVENT ID    DECYR           %
% 2008 07 04 19 46 30.3100 -118.81384 37.57717   6.3500  0.86                                   %
% 2011 07 10 05 09 06.2600 95.09900    4.61800  35.3000  4.70    201107101008  2011.521918      %
%                                                                       			%
% OUTPUT:                                  							%
% eqs = [ yy mm dd hh min sec lon lat dep mag id decyr ]					%
% all column vectors										%
%                                                                       			%
% first created by Lujia Feng Tue Jul 12 09:37:07 SGT 2011                                      %
% last modified by Lujia Feng Tue Jul 12 10:34:56 SGT 2011                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(filename,'file'), error('EQS_readeqs ERROR: %s does not exist!',filename); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(filename,'r');

%%%%%%%%%% read in %%%%%%%%%%%
%                        1  2  3  4  5  6  7  8  9  10 11 12 skip remaining
eqs_cell = textscan(fin,'%f %f %f %f %f %f %f %f %f %f %f %f %*[^\n]','CommentStyle','#');	 % Delimiter default White Space
eqs = cell2mat(eqs_cell);

fclose(fin);
