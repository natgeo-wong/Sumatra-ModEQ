function ypred = Func_linear_quad2(xx,xdata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Func_linear_quad2                              %	
% curve fitting for 2D slab profile                                       %
% using linear for shallow and quadratic for deep			  %
% This function calculates responses, not responses minus data            %
% It is designed to be used by lsqcurvefit                                %
%                                                                         %
% Data:       xdata                                                       %
% Parameters: a,b,m,n,d                                                   %
% Function:                                                               %
% (1) xdata<=d -> ypred = a*xdata + b                                     %
% (2) xdata>d  -> ypred = m*xdata*xdata + n*xdata + p                     %
%                                                                         %
% first created by Lujia Feng Thu Sep 19 15:26:37 SGT 2013                %
% modified based on Func_linear_quad lfeng Thu Sep 19 15:26:58 SGT 2013   %
% last modified by Lujia Feng Thu Sep 19 15:47:56 SGT 2013                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aa = xx(1);
bb = xx(2);
mm = xx(3);
nn = xx(4);
dd = xx(5);
% to make the two functions continuous p is determined by other parameters
pp = aa*dd + bb - mm*dd*dd - nn*dd;

% for x<=d, a linear fit
ypred = aa*xdata + bb;

% for x>d, a quadratic polynomial fit
ind   = xdata>dd;
ypred(ind) = mm*bsxfun(@times,xdata(ind),xdata(ind)) + nn*xdata(ind) + pp;
