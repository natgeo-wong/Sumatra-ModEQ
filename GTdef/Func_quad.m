function y = Func_quad(x,m,n,p)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                Func_quad                                %	
% Define the subduction interface for Sumatran subduction zone            %
% using quadratic function                                                %
% y = m*x^2+n*x+p                                                         %
%									  %
% Independent Parameters: x						  %
% Coefficients: m,n,p	                                                  %
% Dependent Parameters: y                                                 %
%                                                                         %
% first created by Lujia Feng Sun Aug  4 09:27:06 SGT 2013                %
% modified based on NIC_linear_quad.m lfeng Sun Aug  4 09:27:22 SGT 2013  %
% last modified by Lujia Feng Sun Aug  4 09:43:42 SGT 2013                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% a quadratic polynomial fit
y = m*bsxfun(@times,x,x)+n*x+p;
