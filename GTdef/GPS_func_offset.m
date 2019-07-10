function y = GPS_func_offset(t,b,v,O,Teq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_func_offset				%
% Step function for fitting offsets					%
%									%
% Equation: 								%
% t < Teq:  y = b + v*t 						%
% t >= Teq: y = b + v*t + O						%
%									%
% Independent Parameters: t						%
% Dependent Parameters:   y                                             %
% Coefficients: 							%
%  Teq - earthquake time						%
%    b - nominal value of intercept					%
%    v - interseismic velocity						%
%    O - coseismic offset						%
%                                                                       %
% first created by Lujia Feng Wed Nov 30 13:25:18 SGT 2011		%
% last modified by Lujia Feng Thu Dec  1 09:49:05 SGT 2011		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = b+v.*(t-Teq)+O.*(t>=Teq);
