function [ ] = GPS_saverneu(frneuName,saveType,rneu,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_saverneu.m				        %
% save SITE.rneu format GPS time series files					%
% SITE.rneu is my reduced format inherited from usgs raw .rneu			%
%										%
% INPUT:                                                                        %
% frneuName - file name to be output						%
% saveType  = 'w' creat a new file						%
%           = 'a' append to an old file						%
% rneu      - an pntNumx8 array                             			%
% scaleOut  - scale to meter to output                                          %
%										%
% OUTPUT:									%
% The format of *.rneu is [m]							%
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
%										%
% first created by lfeng Mon Aug 29 13:00:38 SGT 2011				%
% last modified by lfeng Fri Jul  3 16:21:03 SGT 2015                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fout = fopen(frneuName,saveType);
if ~exist(frneuName,'file')  
   error('GPS_saverneu ERROR: %s does not exist!',frneuName); 
end

%----------------------- unit info -----------------------
if ~isempty(scaleOut)
    fprintf(fout,'# SCALE2M %8.3e\n',scaleOut);
end

fprintf(fout,'# 1        2           3   4   5   6      7      8\n');
fprintf(fout,'# YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err\n');
fprintf(fout,'%8.0f %14.6f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',rneu'); 
fclose(fout);
