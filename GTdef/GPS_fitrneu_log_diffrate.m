function [ gparam,err,wrms,rchi2 ] = GPS_fitrneu_log_diffrate(rneu,dflag,Teq,dday)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_fitrneu_log_diffrate.m				%
% estimate an earthquake offset with an logarithmic decay of afterslip		%
% and different rates before and after the earthquake				%
%										%
% INPUT:									% 
% rneu = [ day time north east vert north_err east_err vert_err ] 		%
% dflag - data flag: 1 means data; 0 means outliers 				%
% dflag,day,time,north,east,vert,north_err,east_err,vert_err all column vectors	%
% Teq  - decimal year for earthquake						%
% dday - exclude num of days before and after earthquake from fitting		%
%										%
% OUTPUT:                   							%
% gparam - parameters for offset & same rates before and after earthquakes 	%
%  gparam = [ b_n v1_n v2_n O_n a_n tau_n ...					%	
%	      b_e v1_e v2_e O_e a_n tau_n ...					%
%	      b_u v1_u v2_u O_u a_u tau_u ]					%
%  err - errors that correspond to the parameters in gparam			%
%        Note: no errors returned so far					%
%  wrms  - weighted root mean squares	[1*3 row vector]			%
%  rchi2 - mse [1*3 row vector]      						%
%										%
% Reference: Langbein et al. BSSA 2006						%
%										%
% uses GPS_lsqnonlin_logfunc_diffrate.m						%
% [ diff ] = GPS_lsqnonlin_logfunc_diffrate(xx,tt,yy,yyErr,Teq)			%
%       xx = [ b v1 v2 O a tau ]						%
% first created by lfeng Sun Mar 11 02:19:01 SGT 2012				%
% last modified by lfeng Tue Mar 20 14:47:42 SGT 2012				%
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

% initialize
err      = [];
parNum   = 6;						% num of unknown parameters in the model
rchi2 = zeros(1,3);
wrms  = zeros(1,3);

% exclude some data before and after earthquake
if dday>0
   dT = (dday+0.1)/365.0;
   ind = rneu(:,2)>(Teq-dT) & rneu(:,2)<(Teq+dT);
   dflag(ind) = 0;
end

% range for displacement
ind       = dflag==1;
rneuCurr  = rneu(ind,:);
usedNum   = size(rneuCurr,1);
dispMin   = min(min(rneuCurr(:,3:5)));
dispMax   = max(max(rneuCurr(:,3:5)));
dispRange = dispMax-dispMin;

% xx = [ b v1 v2 O a tau ]
x0 = [ 1 1 1 100 -1 0.001 ];
lb = [ dispMin -1e3 -1e3 -dispRange -1e4   0 ];
ub = [ dispMax  1e3  1e3  dispRange  1e4 100 ];

% least square offset fit, iteration through 3 components
tt = rneuCurr(:,2);
for ii=1:3
   pos   = rneuCurr(:,ii+2);
   err   = rneuCurr(:,ii+5);
   wgt   = 1./rneuCurr(:,ii+5).^2;			% weight is the inverse of squared formal error
   % non-linear least squares			
   % resnorm  - the squared 2-norm of the residual = chi2
   % residual - the value of the residual fun(x) at the solution x rr = abs(residual)
   options = optimset('MaxFunEvals',250*parNum,'MaxIter',2000,'TolFun',1e-12,'TolX',1e-12);
   [ xx,resnorm,residual,exitflag ] = ...
   lsqnonlin(@(xx) GPS_lsqnonlin_logfunc_diffrate(xx,tt,pos,err,Teq),x0,lb,ub,options);	
   % check if successful
   %if exitflag~=1, error('GPS_fitrneu_log_diffrate ERROR: do not converge!'); end
   gparam(1,(ii-1)*parNum+1:(ii-1)*parNum+parNum) = xx;
   % how good is the fit!
   chi2      = resnorm;
   rchi2(ii) = chi2/(usedNum-parNum);
   wrms2     = usedNum*chi2/sum(wgt)/(usedNum-1);	% num/(num-1) unbiased estimate
   wrms(ii)  = sqrt(wrms2);
end
