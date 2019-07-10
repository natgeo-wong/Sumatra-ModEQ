function [ diff ] = GPS_lsqnonlin_expfunc_diffrate(xx,tt,yy,yyErr,Teq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      GPS_lsqnonlin_expfunc_diffrate			%
% Exponential function with different rates for lsqnonlin		%
%									%
% Equation: 								%
% t < Teq:  y = b + v1*t 						%
% t >= Teq: y = b + v1*Teq + v2*(t-Teq) + O + a*(1-exp(-(t-Teq)/tau))	%
%					                  t-Teq		%
% t >= Teq: y = b + v1*Teq + v2*(t-Teq) + O + a*(1-exp(- -------))	% 
%					                   tau		% 
%									%
% Independent Parameters: t						%
% Dependent Parameters:   y                                             %
% Coefficients: 							%
%   Teq - earthquake time						%
%     b - nominal value of intercept					%
%    v1 - velocity before offset					%
%    v2 - velocity after offset						%
%     O - coseismic offset						%
%     a - amplitude of the exponential term				%
%   tau - decay time constant						%
%   tau is the only non-linear parameter				%
%									%
% INPUT:								%
%    xx - unknown parameters that need to be estimated 			%
%       = [ b v1 v2 O a tau ]						%
%    tt - independent vector						%
%    yy - dependent vector						%
% yyErr - errors associated with yy					%
%   Teq - earthquake time						%
%									%
% Reference: Thomas Herring's tsview manual				%
% IMPORTANT: use Teq as time reference point! b is common intercept!	%
%	     otherwise rate can not be estimated correctly		%
%                                                                       %
% called by GPS_fitrneu_exp_diffrate.m					%
% first created by lfeng Sun Mar 11 01:51:35 SGT 2012			%
% added tt-Teq lfeng Sun Mar 11 06:09:25 SGT 2012			%
% added yyErr lfeng Tue Mar 20 10:59:04 SGT 2012			%
% last modified by lfeng Tue Mar 20 11:04:17 SGT 2012			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b   = xx(1);
v1  = xx(2);
v2  = xx(3);
O   = xx(4);
a   = xx(5);
tau = xx(6);

modelyy = b + v1*(tt-Teq);

ind2 = tt>=Teq;
modelyy(ind2) = b + v2*(tt(ind2)-Teq) + O + a*(1-exp((Teq-tt(ind2))/tau));

% output needs to be residual vector
diff = bsxfun(@rdivide,modelyy-yy,yyErr);
