function [ covmat,cc ] = GPS_formcov(rneu,dflag,rate,rate_err)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_formcov.m				        %
% form covariance matrix and correlation coefficient for rate uncertainties	%
% in local geodetic topocentric system (NEU)					%
%										%
% INPUT:									% 
% rneu = [ day time north east vert north_err east_err vert_err ] 		%
% dflag - data flag: 1 means data; 0 means outliers 				%
% rate_err - the associated error of long-term rates (north, east, vertical)	%
% all column vectors								%
%										%
% OUTPUT: 									%
% covmat - covariance matrix for three components				%
%          [ Cnn Cne Cnu ]              					%
%        = [ Cen Cee Ceu ]                                                      %
%          [ Cun Cue Cuu ]                                                      %
%										%
% corrcoef - correlation coefficient						%
%          [ cc_nn cc_ne cc_nu ]  						%
%        = [ cc_en cc_ee cc_eu ]                                  		%
%          [ cc_un cc_ue cc_uu ]                                  		%
%		 Cne			   Cnu			   Ceu		%
%  cc_ne = ---------------   cc_nu = ---------------  cc_eu = --------------    %
%	    sqrt(Cnn*Cee)   	      sqrt(Cnn*Cuu)   	      sqrt(Cee*Cuu)     %
%										%
% Note: not 100% certain about whether the calculation is right 		%
%       but do not affect the final rate_err					%
% first created by lfeng Mon Feb 28 12:35:01 EST 2011				%
% detrend to obtain the uncertainties lfeng Sun Apr  3 20:17:42 EDT 2011	%
% last modified by lfeng Mon Apr  4 02:29:50 EDT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% data only, exclude outliers
ind = find(dflag); 

% remove linear trend to obtain noise 
t0 = rneu(1,2);	% the 1st record used as time origin
v_ns = rate(1); v_ew = rate(2); v_ud = rate(3);
ns_residual = rneu(ind,3)-(rneu(ind,2)-t0)*v_ns;
ew_residual = rneu(ind,4)-(rneu(ind,2)-t0)*v_ew;
ud_residual = rneu(ind,5)-(rneu(ind,2)-t0)*v_ud;

% cov(X) when X is a matrix: each row is an observation, and each column is a variable
%covmat = cov([ns_err ew_err ud_err]);
% correlation coefficient for noises!!!!
cc = corrcoef([ns_residual ew_residual ud_residual]);

% covariance incorporating time-correlated error
n_err = rate_err(1); e_err = rate_err(2); u_err = rate_err(3);
covmat = [ n_err*n_err n_err*e_err n_err*u_err;
           e_err*n_err e_err*e_err e_err*u_err;
           u_err*n_err u_err*e_err u_err*u_err ];
covmat = covmat.*cc;
