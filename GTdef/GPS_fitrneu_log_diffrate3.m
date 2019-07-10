function [ gparam,err,wrms,rchi2 ] = GPS_fitrneu_log_diffrate3(rneu,dflag,Teq,dday)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         GPS_fitrneu_log_diffrate3.m				%
% estimate an earthquake offset with an logarithmic decay of afterslip		%
% + different rates before and after the earthquake				%
% + same tau for three components (tau=tau_n=tau_e=tau_u)			%
%										%
% INPUT:									% 
% rneu = [ day time north east vert north_err east_err vert_err ] 		%
% dflag - data flag: 1 means data; 0 means outliers 				%
% dflag,day,time,north,east,vert,north_err,east_err,vert_err all column vectors	%
% Teq  - decimal year for earthquake						%
% dday - exclude num of days before and after earthquake from fitting		%
%										%
% OUTPUT:                   							%
% gparam = [ b_n v1_n v2_n O_n a_n tau ...					%
%	     b_e v1_e v2_e O_e a_e tau ...					%
%	     b_u v1_u v2_u O_u a_u tau ]    [row vector]			%
% err - errors that correspond to the parameters in gparam			%
%        Note: no errors returned so far					%
%  wrms  - weighted root mean squares	[scalar]				%
%  rchi2 - mse [scalar]      							%
%										%
% Reference: Langbein et al. BSSA 2006						%
%										%
% uses GPS_lsqnonlin_logfunc_diffrate3.m					%
% [ diff ] = GPS_lsqnonlin_logfunc_diffrate3(xx,rneu,Teq)			%
%  xx  = [ n_b n_v1 n_v2 n_O n_a        					%
%          e_b e_v1 e_v2 e_O e_a        					%
%          u_b u_v1 u_v2 u_O u_a tau ]						%
% first created by lfeng Tue Mar 20 15:39:43 SGT 2012				%
% last modified by lfeng Tue Mar 27 10:01:50 SGT 2012				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Equation: 								 
% t < Teq:  y = b + v1*t 						 
%				                       t-Teq		 
% t >= Teq: y = b + v1*Teq + v2*(t-Teq) + O + a*log(1+-------)		 
%					                tau		 
% Independent Parameters: t						 
% Dependent Parameters:   y                                              
% Coefficients: 							 
%  Teq - earthquake time						 
%    b - nominal value of intercept					 
%   v1 - velocity before offset					 	 
%   v2 - velocity after offset						 
%    O - coseismic offset						 
%    a - coefficient for log						 
%  tau - time constant							 
%  tau is the only non-linear parameter

err      = [];
parNum   = 16;						% num of unknown parameters in the model

% exclude some data before and after earthquake
if dday>0
   dT = (dday+0.1)/365.0;
   ind = rneu(:,2)>(Teq-dT) & rneu(:,2)<(Teq+dT);
   dflag(ind) = 0;
end

% range for displacement
ind       = dflag==1;
rneuCurr  = rneu(ind,:); 				% exclude some data from fitting
usedNum   = size(rneuCurr,1);
dispMin   = min(min(rneuCurr(:,3:5)));
dispMax   = max(max(rneuCurr(:,3:5)));
dispRange = dispMax-dispMin;

% xx = [ n_b n_v1 n_v2 n_O n_a 
%        e_b e_v1 e_v2 e_O e_a 
%        u_b u_v1 u_v2 u_O u_a tau ]
x0 = [ 1 1 1 100 1 ... 
       1 1 1 100 1 ... 
       1 1 1 100 1 0.001 ];
lb = [ dispMin -1e3 -1e3 -dispRange -1e4 ...
       dispMin -1e3 -1e3 -dispRange -1e4 ...
       dispMin -1e3 -1e3 -dispRange -1e4   0 ];
ub = [ dispMax  1e3  1e3  dispRange  1e4 ...
       dispMax  1e3  1e3  dispRange  1e4 ...
       dispMax  1e3  1e3  dispRange  1e4  50 ];

% non-linear least squares			
% resnorm  - the squared 2-norm of the residual = chi2
% residual - the value of the residual fun(x) at the solution x rr = abs(residual)
options = optimset('MaxFunEvals',500*parNum,'MaxIter',2000,'TolFun',1e-12,'TolX',1e-12);
[ xx,resnorm,residual,exitflag ] = ...
lsqnonlin(@(xx) GPS_lsqnonlin_logfunc_diffrate3(xx,rneuCurr,Teq),x0,lb,ub,options);	
% check if successful
%if exitflag~=1, error('GPS_fitrneu_log_diffrate3 ERROR: do not converge!'); end
% how good is the fit!
chi2  = resnorm;
rchi2 = chi2/(usedNum-parNum);
wgt   = [ 1./rneuCurr(:,6).^2; 1./rneuCurr(:,7).^2; 1./rneuCurr(:,8).^2 ];	% weight is the inverse of squared formal error
wrms2 = usedNum*chi2/sum(wgt)/(usedNum-1);		% num/(num-1) unbiased estimate
wrms  = sqrt(wrms2);
gparam = [ xx(1:5) xx(16) xx(6:10) xx(16) xx(11:15) xx(16) ];		% row vector
