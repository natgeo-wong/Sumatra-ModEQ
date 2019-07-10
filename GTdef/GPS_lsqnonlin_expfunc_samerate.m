function [ diff ] = GPS_lsqnonlin_expfunc_samerate(xx,tt,yy,yyErr,Teq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      GPS_lsqnonlin_expfunc_samerate			%
% Exponential function with the same rate for lsqnonlin			%
%									%
% Equation: 								%
% t < Teq:  y = b + v*t 						%
% t >= Teq: y = b + v*t + O + a*(1-exp(-(t-Teq)/tau))			%
%					  t-Teq				%
% t >= Teq: y = b + v*t + O + a*(1-exp(- -------))			% 
%					   tau				% 
%									%
% Independent Parameters: t						%
% Dependent Parameters:   y                                             %
% Coefficients: 							%
%   Teq - earthquake time						%
%     b - nominal value of intercept					%
%     v - interseismic velocity						%
%     O - coseismic offset						%
%     a - amplitude of the exponential term				%
%   tau - decay time constant						%
%   tau is the only non-linear parameter				%
%									%
% INPUT:								%
%    xx - unknown parameters that need to be estimated 			%
%       = [ b v O a tau ]						%
%    tt - independent vector						%
%    yy - dependent vector						%
% yyErr - errors associated with yy					%
%   Teq - earthquake time						%
%									%
% Reference: Thomas Herring's tsview manual				%
% IMPORTANT: use Teq as time reference point! b is common intercept!	%
%	     otherwise rate can not be estimated correctly		%
%                                                                       %
% called by GPS_fitrneu_exp_samerate.m					%
% first created by lfeng Thu Mar  8 14:27:16 SGT 2012			%
% added tt-Teq lfeng Sun Mar 11 06:08:31 SGT 2012			%
% added yyErr lfeng Tue Mar 20 11:05:03 SGT 2012			%
% last modified by lfeng Tue Mar 20 11:05:32 SGT 2012			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b   = xx(1);
v   = xx(2);
O   = xx(3);
a   = xx(4);
tau = xx(5);

modelyy = b + v*(tt-Teq);

ind2 = tt>=Teq;
modelyy(ind2) = modelyy(ind2) + O + a*(1-exp((Teq-tt(ind2))/tau));

% output needs to be residual vector
diff = bsxfun(@rdivide,modelyy-yy,yyErr);
