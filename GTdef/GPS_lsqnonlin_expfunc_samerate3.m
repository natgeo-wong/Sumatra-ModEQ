function [ diff ] = GPS_lsqnonlin_expfunc_samerate3(xx,rneu,Teq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      GPS_lsqnonlin_expfunc_samerate3			%
% Simultaneously fit three components with 				%
% Exponential function & same rates & same tau for lsqnonlin 		%
%									%
% Equation: 								%
% t < Teq:  y = b + v*t 						%
% t >= Teq: y = b + v*t + O + a*(1-exp(-(t-Teq)/tau))			%
%					  t-Teq				%
% t >= Teq: y = b + v*t + O + a*(1-exp(- -------))			% 
%					   tau				% 
%									%
% Independent Parameters: tt						%
% Dependent Parameters:   nn ee uu                                      %
% Coefficients: 							%
%  Teq - earthquake time						%
%    b - nominal value of intercept					%
%    v - interseismic velocity						%
%    O - coseismic offset						%
%    a - amplitude of the exponential term				%
%  tau - decay time constant						%
%  tau is the only non-linear parameter					%
%									%
% INPUT:								%
%   xx - unknown parameters that need to be estimated 			%
%      = [ n_b n_v n_O n_a      					%
%          e_b e_v e_O e_a      					%
%          u_b u_v u_O u_a tau ]					%
% rneu = [ day tt nn ee uu nnErr eeErr uuErr ]				%
%   tt - independent vector						%
%   nn - dependent vector north component 				%
%   ee - dependent vector east component 				%
%   uu - dependent vector vertical component 				%
%  Teq - earthquake time						%
%									%
% OUTPUT:								%
% diff - weighted residual						%
%									%
% Reference: Thomas Herring's tsview manual				%
% IMPORTANT: use Teq as time reference point! b is common intercept!	%
%	     otherwise rate can not be estimated correctly		%
%                                                                       %
% called by GPS_fitrneu_exp_samerate3.m					%
% first created by lfeng Tue Mar 20 10:39:21 SGT 2012			%
% last modified by lfeng Tue Mar 20 15:17:35 SGT 2012			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters
n_b = xx(1);  e_b = xx(5);  u_b = xx(9);
n_v = xx(2);  e_v = xx(6);  u_v = xx(10);
n_O = xx(3);  e_O = xx(7);  u_O = xx(11);
n_a = xx(4);  e_a = xx(8);  u_a = xx(12);
tau = xx(13);

% data
tt = rneu(:,2);
nn = rneu(:,3); nnErr = rneu(:,6);
ee = rneu(:,4); eeErr = rneu(:,7);
uu = rneu(:,5); uuErr = rneu(:,8);

ind2 = tt>=Teq;

% north component
modelnn       = n_b + n_v*(tt-Teq);
modelnn(ind2) = modelnn(ind2) + n_O + n_a*(1-exp((Teq-tt(ind2))/tau));
diffnn        = bsxfun(@rdivide,modelnn-nn,nnErr);

% east component
modelee       = e_b + e_v*(tt-Teq);
modelee(ind2) = modelee(ind2) + e_O + e_a*(1-exp((Teq-tt(ind2))/tau));
diffee        = bsxfun(@rdivide,modelee-ee,eeErr);

% vertical component
modeluu       = u_b + u_v*(tt-Teq);
modeluu(ind2) = modeluu(ind2) + u_O + u_a*(1-exp((Teq-tt(ind2))/tau));
diffuu        = bsxfun(@rdivide,modeluu-uu,uuErr);

% output needs to be residual vector
diff = [ diffnn; diffee; diffuu ];
