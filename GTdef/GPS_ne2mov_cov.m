function [ v_err,dir_err ] = GPS_ne2mov_cov(ns,ew,Cneu)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate the errors for the magnitude and azimuth of horizontal motion		%
% from ne and ew and their associated errors						%
%											%
% INPUT:										% 
% ns & ns_err - rate and its error in north-south direction	[mm/yr]			%
% ew & ew_err - rate and its error in east-west direction   [mm/yr]                 	%
% Cneu  - covariance matrix in local geodetic topocentric system (v NEU)		%
%         only the components for ns and ew are used					%
%         [ Cnn Cne Cnu ]              							%
%       = [ Cen Cee Ceu ]                                                      		%
%         [ Cun Cue Cuu ]                                                      		%
%											%
% OUTPUT: 										%
% mov_v_err and mov_dir_err								% 
%											%
% Note: the results are different output of MORVEL output				%
% first created by lfeng Fri Mar  4 13:29:04 EST 2011					%
% last modified by lfeng Fri Mar  4 15:12:39 EST 2011					%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ns_err2 = Cneu(1,1); ew_err2 = Cneu(2,2); ne_coerr2 = Cneu(1,2);
%%%%%%%%%%%%%%%% magnitude of horizontal plate motion %%%%%%%%%%%%%%%%
%  mov_v = (v_ns^2 + v_ew^2)^0.5

v2 = ns^2 + ew^2;
v4 = v2^2;
v_err2 = ns_err2*ns^2/v2 + ew_err2*ew^2/v2 - ne_coerr2*2*ns*ew*v2^(-1.5);
v_err = sqrt(v_err2);

%%%%%%%%%%%%%%%% direction of horizontal plate motion %%%%%%%%%%%%%%%%
%  mov_dir = 90 - atan(v_ns/v_ew)*180/pi;
%  or 
%  mov_dir = 270 - atan(v_ns/v_ew)*180/pi;

coeff = 180/pi;
dir_err2 = ns_err2*coeff^2*ew^2/v4 + ew_err2*coeff^2*ns^2/v4 + ne_coerr2*2*coeff*(ew^2-ns^2)/v4;
dir_err = sqrt(dir_err2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% symbolic box to help calculate the derivatives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% syms ns ew;
% vv = sym('sqrt(ns^2+ew^2)');
% dir = sym('-atan(ns/ew)*180/pi');
%
% dns = diff(vv,ns);
% dew = diff(vv,ew);
% dne = diff(diff(vv,ns),ew);
% den = diff(diff(vv,ew),ns);
%
% ddns = simplify(diff(dir,ns));
% ddew = simplify(diff(dir,ew));
% ddne = simplify(diff(diff(dir,ns),ew));
% dden = simplify(diff(diff(dir,ew),ns));
