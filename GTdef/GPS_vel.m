function [ ] = GPS_vel(vel1Name,oper,var2,foutExt,scaleIn,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                    GPS_vel.m                                          % 
% manipulate *.vel data	                                                                %
% make sure two *.vel files have the same units	                                        %
% better to use mm/yr for *.vel and use m/yr for GTdef	                                %
%                                                                                       %
% INPUT:                                                                                %
% (1) *.vel for models	                                                                %
%   1   2   3   4      5  6  7  8   9   10  11     12 13  14 15  16  17  18             %
%   Sta Lon Lat Height VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D Cne Ceu Cnu            %
% Note: Cne is correlation coefficient between North and East uncertainties!            %
%                                                                                       %
% (2) oper - operator                                                                   %
%    '-':      1.vel - 2.vel								%
%        var2 = vel2_name                                                               %
%                                                                                       %
%    'baseline': form baselines for sites in 1.vel                                      %
%        var2 - reference site name                                                     %
%     if var2 = '', all sites are used as reference sites                               %
%        e.g. GPS_vel('SMT.vel','baseline','NTUS')				        %
%                                                                                       %
%    'euler':  remove an euler vector from 1.vel                                        %
%        var2 = *.euler (a file storing euler pole info)                                %
%                                                                                       %
%    'strike':   project 1.vel to along strike & normal to strike                       %
%        var2 = strike                                                                  %
%        e.g. GPS_vel('NIC_ca_1996-2004.vel','strike',135)                              %
%                                                                                       %
% first created by Lujia Feng Wed Nov  3 13:42:31 EDT 2010                              %
% added scaleIn & scaleOut lfeng Mon Oct 20 17:17:01 SGT 2014                           %
% added foutExt lfeng Wed Feb  3 17:15:11 SGT 2016                                      %
% last modified by Lujia Feng Wed Feb  3 17:22:14 SGT 2016                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin <= 3
   foutExt = []; scaleIn = []; scaleOut = [];
elseif nargin <=4
   scaleIn = []; scaleOut = [];
end

switch oper
   %%%%% - %%%%%
   case '-'
   GPS_vel_minus(vel1Name,var2,scaleIn,scaleOut);

   %%%%% baseline %%%%%
   case 'baseline'
   GPS_vel_baseline(vel1Name,var2,scaleIn,scaleOut);

   %%%%% euler %%%%%
   case 'euler'
   GPS_vel_euler(vel1Name,var2,foutExt,scaleIn,scaleOut);
      
   %%%%% strike %%%%%
   case 'strike'
   GPS_vel_project(vel1Name,var2,scaleIn,scaleOut);
end
