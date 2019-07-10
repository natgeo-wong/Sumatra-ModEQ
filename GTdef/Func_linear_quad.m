function y = Func_linear_quad(x,a,b,m,n,d)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Func_linear_quad				  %	
% curve fitting for 2D slab profile                                       %
% using linear for shallow and quadratic for deep			  %
%									  %
% Independent Parameters: x						  %
% Coefficients: a,b,m,n,d                                                 %
% Dependent Parameters: y                                                 %
%                                                                         %
% first created by Lujia Feng Sun Nov 28 14:12:29 EST 2010		  %
% last modified by Lujia Feng Thu Sep 19 15:32:04 SGT 2013                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = zeros(size(x));

% for x<=d, a linear fit
ind = x<=d;
y(ind) = a*x(ind)+b;

% for x>d, a quadratic polynomial fit
ind = x>=d;
% to make the two functions continuous p is determined by other parameters
p = a*d+b-m*d*d-n*d;
y(ind) = m*bsxfun(@times,x(ind),x(ind))+n*x(ind)+p;
