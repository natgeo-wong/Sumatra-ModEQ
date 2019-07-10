function y = GPS_func_exp(t,b,v,O,a,tau,Teq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_func_exp				%
% Exponential function for fitting data especially for afterslip	%
%									%
% Equation: 								%
% t < Teq:  y = b + v*t 						%
% t >= Teq: y = b + v*t + O + a*(1-exp(-(t-Teq)/tau))			%
%									%
% Independent Parameters: t						%
% Dependent Parameters:   y                                             %
% Coefficients: 							%
%  Teq - earthquake time						%
%    b - nominal value of intercept					%
%    v - interseismic velocity						%
%    O - coseismic offset						%
%    a - amplitude of the exponential term				%
%  tau - decay time constant						%
%									%
% Reference: Thomas Herring's tsview manual				%
%                                                                       %
% first created by Lujia Feng Wed Nov 30 11:56:40 SGT 2011		%
% added t-Teq lfeng Thu Dec  1 16:39:33 SGT 2011			%
% last modified by Lujia Feng Thu Dec  1 16:42:36 SGT 2011		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = zeros(size(t));

% for t<Teq, a linear fit
ind = t<Teq;
y(ind) = b+v*(t(ind)-Teq);

% for t>=Teq, a exp fit
ind = t>=Teq;
% to make the two functions continuous p is determined by other parameters
y(ind) = b+v*(t(ind)-Teq)+O+a*(1-exp((Teq-t(ind))/tau));

end
