function y = NIC_exp(x,a,b,c,d)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             NIC_exp					  %
% Define the subduction interface for Nicoya Peninsula			  %
% using exponential for all depths					  %
%									  %
% Independent Parameters: x						  %
% Coefficients: a,b,c,d							  %
% Dependent Parameters: y                                                 %
%                                                                         %
% first created by Lujia Feng Sun Nov 28 18:52:16 EST 2010		  %
% last modified by Lujia Feng Wed Dec  1 21:41:22 EST 2010		  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fix the intercept at -4.5 km
y = zeros(size(x));
c = -a-4.5;
y = a.*exp(b.*x)+c.*exp(d.*x);
