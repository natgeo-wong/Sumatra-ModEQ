function [ diff ] = GPS_lsqnonlin_logfunc_diffrate(xx,tt,yy,yyErr,Teq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   GPS_lsqnonlin_logfunc_diffrate			%
% Logrithmic function with different rates for lsqnonlin 		%
% especially for Omori law 						%
%									%
% Equation: 								%
% t < Teq:  y = b + v1*t 						%
%				                       t-Teq		%
% t >= Teq: y = b + v1*Teq + v2*(t-Teq) + O + a*log(1+-------)		%
%					                tau		%
% Independent Parameters: t						%
% Dependent Parameters:   y                                             %
% Coefficients: 							%
%   Teq - earthquake time						%
%     b - nominal value of intercept					%
%    v1 - velocity before offset					%
%    v2 - velocity after offset						%
%     O - coseismic offset						%
%     a - coefficient for log						%
%   tau - time constant							%
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
% Reference: Langbein et al. BSSA 2006					%
% IMPORTANT: use Teq as time reference point! b is common intercept!	%
%	     otherwise rate can not be estimated correctly		%
%                                                                       %
% called by GPS_fitrneu_log_diffrate.m					%
% first created by lfeng Sun Mar 11 01:54:46 SGT 2012			%
% added tt-Teq lfeng Sun Mar 11 06:29:24 SGT 2012			%
% added yyErr lfeng Tue Mar 20 11:06:16 SGT 2012			%
% last modified by lfeng Tue Mar 20 11:08:53 SGT 2012			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b   = xx(1);
v1  = xx(2);
v2  = xx(3);
O   = xx(4);
a   = xx(5);
tau = xx(6);

modelyy = b + v1*(tt-Teq);

ind2 = tt>=Teq;
modelyy(ind2) = b + v2*(tt(ind2)-Teq) + O + a*log10(1+(tt(ind2)-Teq)/tau); 

% output needs to be residual vector
diff = bsxfun(@rdivide,modelyy-yy,yyErr);
