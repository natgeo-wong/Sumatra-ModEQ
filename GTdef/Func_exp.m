function y = Func_exp(x,b)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                Func_exp                                 %
% Define the subduction interface for Sumatran subduction zone            %
% using exponential for all depths					  %
%									  %
% Independent Parameters: x						  %
% Coefficients: b    							  %
% Dependent Parameters: y                                                 %
%                                                                         %
% first created by Lujia Feng Sun Nov 28 18:52:16 EST 2010		  %
% modified based on NIC_exp.m lfeng Sun Aug  4 12:32:25 SGT 2013          %
% last modified by Lujia Feng Sun Aug  4 12:47:40 SGT 2013                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%y = a*exp(b.*x);
%a = -3.0;
y = -3.0*exp(b.*x);
