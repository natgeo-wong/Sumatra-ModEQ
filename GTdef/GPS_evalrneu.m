function [ rneuNew ] = GPS_evalrneu(fitobj,time)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_evalrneu.m				        %
% create new rneu using fitobj and time 					%	
%										%
% INPUT:									% 
% (1) fitobj - results returned in fit object					%
%     fitobj.north fitobj.east fitobj.vert					%
% (2) time   - time range for output values [num*2]				%
%     time = [ yearmmdd decyr ]							%
% first created by lfeng Thu Dec  1 10:25:23 SGT 2011				%
% last modified by lfeng Thu Dec  1 10:31:36 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

len = size(time,1);
err = zeros(len,3);			% use zero errors
decyr = time(:,2);
nn  = fitobj.north(decyr);
ee  = fitobj.east(decyr);
uu  = fitobj.vert(decyr);
rneuNew = [ time nn ee uu err ];
