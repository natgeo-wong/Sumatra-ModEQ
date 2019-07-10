function [ diff ] = GPS_lsqnonlin_logfunc_samerate(xx,tt,yy,yyErr,Teq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    GPS_lsqnonlin_logfunc_samerate			%
% Logrithmic function with the same rate for lsqnonlin 			%
% especially for Omori law 						%
%									%
% Equation: 								%
% t < Teq:  y = b + v*t 						%
%				       t-Teq				%
% t >= Teq: y = b + v*t + O + a*log(1+-------)			 	%
%					tau			 	%
% Independent Parameters: t						%
% Dependent Parameters:   y                                             %
% Coefficients: 							%
%   Teq - earthquake time						%
%     b - nominal value of intercept					%
%     v - interseismic velocity						%
%     O - coseismic offset						%
%     a - coefficient for log						%
%   tau - time constant							%
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
% Reference: Langbein et al. BSSA 2006					%
% IMPORTANT: use Teq as time reference point! b is common intercept!	%
%	     otherwise rate can not be estimated correctly		%
%                                                                       %
% called by GPS_fitrneu_log_samerate.m					%
% first created by lfeng Thu Mar  8 16:25:29 SGT 2012			%
% added tt-Teq lfeng Sun Mar 11 06:09:25 SGT 2012			%
% added yyErr lfeng Tue Mar 20 11:09:30 SGT 2012			%
% last modified by lfeng Tue Mar 20 11:12:01 SGT 2012			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b   = xx(1);
v   = xx(2);
O   = xx(3);
a   = xx(4);
tau = xx(5);

modelyy = b + v*(tt-Teq);

ind2 = tt>=Teq;
modelyy(ind2) = modelyy(ind2) + O + a*log10(1+(tt(ind2)-Teq)/tau); 

% output needs to be residual vector
diff = bsxfun(@rdivide,modelyy-yy,yyErr);
