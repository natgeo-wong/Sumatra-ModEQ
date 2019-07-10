function [ ] = GPS_rneu_project(rneuName,str)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_rneu_project.m                                        % 
% project *.rneu along a direction & perpendicular to a direction                       %
%                                                                                       %
% INPUT:                                                                                %
% (1) *.rneu                           	                                                %
% 1        2         3     4    5    6    7    8                                        %
% YEARMODY YEAR.DCML NORTH EAST VERT Nerr Eerr Verr                          	        %
%                                                                                       %
% (2) str - strike direction clockwise from N [deg]                                     %
%                                                                                       %
% OUTPUT: one new *.rneu files                                                          %
% *.rneu - parallel and normal velocities replacing Vew & Vns + vertical velocity       %
% 1        2           3   4   5   6      7      8                                      %
% YEARMODY YEAR.DCML   P   N   U   Perr   Nerr   Uerr                                   %
%                                                                                       %
% Note:                                                                                 %
% Parallel+ is along str direction                                                      %
% Normal+   is 90 degree clockwise from Parallel+                                       %
%                                                                                       % 
% first created by Lujia Feng Wed Jul 13 18:53:39 SGT 2011                              %
% separated from GPS_rneu.m lfeng Thu Jun 20 00:18:29 SGT 2013                          %
% to be consistent with NEU convention, reversed trench-normal sign lfeng Mar 14 2014   %
% corrected errors for the 1st point (was 0) lfeng Thu Mar 27 17:52:46 SGT 2014         %
% added rneu empty check lfeng Thu Jul  2 19:13:08 SGT 2015                             %
% last modified by Lujia Feng Thu Jul  2 19:13:17 SGT 2015                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in *.rneu file
fprintf(1,'\n.......... reading %s  ...........\n\n',rneuName);
[ rneu ] = GPS_readrneu(rneuName,[],1);
if isempty(rneu)  
   fprintf(1,'GPS_rneu_project WARNING: %s is empty',frneuName); 
   return;
end

% prepare a new velocity file for both normal and parallel
[ ~,basename,~ ] = fileparts(rneuName);
outName = [ basename '_str' num2str(str,'%.0f') '.rneu' ];
fout    = fopen(outName,'w'); 
fprintf(fout,'# project %s parallel and normal to strike %f \n',rneuName,str);
fprintf(fout,'# 1        2           3   4   5   6      7      8\n');
fprintf(fout,'# YEARMODY YEAR.DCML   P   N   U   Perr   Nerr   Uerr     [m]\n');

% rate removed from the 1st point
tt    = rneu(:,2);
% position change reference to the 1st point
ns    = rneu(:,3) - rneu(1,3);  
ew    = rneu(:,4) - rneu(1,4); 
ud    = rneu(:,5) - rneu(1,5);
% errors
errNS = rneu(:,6);
errEW = rneu(:,7);
errUD = rneu(:,8);

ccNE = 0;
num  = size(rneu,1);
pp   = zeros(num,1); errPP = zeros(num,1);
nn   = zeros(num,1); errNN = zeros(num,1);
for ii=1:num
   % skip the 1st point which is zero
   [ parall,normal,errParall,errNormal,cc ] = GPS_vel2strike(ns(ii),ew(ii),errNS(ii),errEW(ii),ccNE,str);
   pp(ii)    =  parall;
   nn(ii)    = -normal;  % trench-normal is 90 degree clockwise from trench-parallel!!!!!
   errPP(ii) = errParall;
   errNN(ii) = errNormal;
end

rpnu = rneu;
rpnu(:,3:8) = [ pp nn ud errPP errNN errUD ];
fprintf(fout,'%8.0f %14.6f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',rpnu'); 
fclose(fout);
