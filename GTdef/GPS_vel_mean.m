function [ ave,ave_err ] = GPS_vel_mean(fvel_name,vv_col,err_col)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate the weighted mean velocity of many sites				%
% assuming no correlation between sites						%
%										%
% INPUT:									% 
% *.vel files									%
% 1   2   3   4    5  6  7  8   9   10  11     12 13  14 15    16               %
% Sta Lon Lat Elev VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D   Cne              %
% Note: Cne is correlation coefficient between North and East uncertainties!	%
% vv_col - column number in *.vel for velocity					%
% err_col - column number in *.vel for the associated error			%
%										%
% OUTPUT:                   							%
% ave - weighted average/mean							%
% ave_err - its standard error							%
%										%
% first created by lfeng Sun Mar  6 23:28:30 EST 2011				%
% removed Ceu Cnu lfeng Sun Apr  3 20:34:00 EDT 2011				%
% last modified by lfeng Sun Apr  3 21:22:56 EDT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in
[ site,vel ] = GPS_readvel(fvel_name);

% -1 for site name
vv = vel(:,vv_col-1); vv_err = vel(:,err_col-1);
nn = length(vv);
vv_wgt = 1./vv_err.^2; 		% use inverse of variance as weight

% calculate the weighted average
T = vv_wgt/sum(vv_wgt);
ave = T'*vv;

% calculate the associated error
% two methods have the same result
%----------------------------------------
% method 1
%covmat = spdiags(vv_err.^2,0,nn,nn);
%ave_err2 = T'*covmat*T;
%ave_err = sqrt(ave_err2);

%----------------------------------------
% method 2
ave_err = sqrt(1/sum(vv_wgt));
