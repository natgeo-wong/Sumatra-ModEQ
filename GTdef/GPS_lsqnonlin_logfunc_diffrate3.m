function [ diff ] = GPS_lsqnonlin_logfunc_diffrate3(xx,rneu,Teq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     GPS_lsqnonlin_logfunc_diffrate3			%
% Simultaneously fit three components with 				%
% Logrithmic function & different rates & same tau for lsqnonlin 	%
% especially for Omori law 						%
%									%
% Equation: 								%
% t < Teq:  y = b + v1*t 						%
%				                       t-Teq		%
% t >= Teq: y = b + v1*Teq + v2*(t-Teq) + O + a*log(1+-------)		%
%					                tau		%
% Independent Parameters: tt						%
% Dependent Parameters:   nn ee uu                                      %
% Coefficients: 							%
%  Teq - earthquake time						%
%    b - nominal value of intercept					%
%   v1 - velocity before offset					 	%
%   v2 - velocity after offset						%
%    O - coseismic offset						%
%    a - coefficient for log						%
%  tau - time constant							%
%  tau is the only non-linear parameter					%
%									%
% INPUT:								%
%   xx - unknown parameters that need to be estimated 			%
%      = [ n_b n_v1 n_v2 n_O n_a        				%
%          e_b e_v1 e_v2 e_O e_a        				%
%          u_b u_v1 u_v2 u_O u_a tau ]					%
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
% Reference: Langbein et al. BSSA 2006					%
% IMPORTANT: use Teq as time reference point! b is common intercept!	%
%	     otherwise rate can not be estimated correctly		%
%                                                                       %
% called by GPS_fitrneu_log_diffrate3.m					%
% first created by lfeng Mon Mar 19 17:32:09 SGT 2012			%
% last modified by lfeng Tue Mar 20 10:11:46 SGT 2012			%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters
n_b  = xx(1);  e_b  = xx(6);  u_b  = xx(11);
n_v1 = xx(2);  e_v1 = xx(7);  u_v1 = xx(12);
n_v2 = xx(3);  e_v2 = xx(8);  u_v2 = xx(13);
n_O  = xx(4);  e_O  = xx(9);  u_O  = xx(14);
n_a  = xx(5);  e_a  = xx(10); u_a  = xx(15);
tau  = xx(16);

% data
tt = rneu(:,2);
nn = rneu(:,3); nnErr = rneu(:,6);
ee = rneu(:,4); eeErr = rneu(:,7);
uu = rneu(:,5); uuErr = rneu(:,8);

ind2 = tt>=Teq;

% north component
modelnn       = n_b + n_v1*(tt-Teq);
modelnn(ind2) = n_b + n_v2*(tt(ind2)-Teq) + n_O + n_a*log10(1+(tt(ind2)-Teq)/tau); 
diffnn        = bsxfun(@rdivide,modelnn-nn,nnErr);

% east component
modelee       = e_b + e_v1*(tt-Teq);
modelee(ind2) = e_b + e_v2*(tt(ind2)-Teq) + e_O + e_a*log10(1+(tt(ind2)-Teq)/tau); 
diffee        = bsxfun(@rdivide,modelee-ee,eeErr);

% vertical component
modeluu       = u_b + u_v1*(tt-Teq);
modeluu(ind2) = u_b + u_v2*(tt(ind2)-Teq) + u_O + u_a*log10(1+(tt(ind2)-Teq)/tau); 
diffuu        = bsxfun(@rdivide,modeluu-uu,uuErr);

% output needs to be residual vector
diff = [ diffnn; diffee; diffuu ];
