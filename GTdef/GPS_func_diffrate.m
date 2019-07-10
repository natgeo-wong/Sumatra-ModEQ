function y = GPS_func_diffrate(t,b,v1,v2,O,Teq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_func_diffrate				%
% step function & rate change before and after earthquakes		%
%									%
% Equation: 								%
% t < Teq:  y = b + v1*t 						%
% t >= Teq: y = b + v1*Teq + v2*(t-Teq) + O				%
%									%
% Independent Parameters: t						%
% Dependent Parameters:   y                                             %
% Coefficients: 							%
%  Teq - earthquake time						%
%    b - nominal value of intercept					%
%    v1 - velocity before offset					%
%    v2 - velocity after offset						%
%    O - coseismic offset						%
%                                                                       %
% first created by Lujia Feng Wed Nov 30 13:25:18 SGT 2011		%
% last modified by Lujia Feng Wed Nov 30 13:57:15 SGT 2011		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = zeros(size(t));

% for t<Teq, a linear fit
ind = t<Teq;
y(ind) = b+v1*(t(ind)-Teq);

% for t>=Teq, a linear fit + step
ind = t>=Teq;
% to make the two functions continuous p is determined by other parameters
y(ind) = b+v2*(t(ind)-Teq)+O;

end
