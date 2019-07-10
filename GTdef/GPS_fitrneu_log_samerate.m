function [ gparam,err,wrms,rchi2 ] = GPS_fitrneu_log_samerate(rneu,dflag,Teq,dday)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        GPS_fitrneu_log_samerate.m				%
% estimate an earthquake offset with an logarithmic decay of afterslip		%
% and the same rate before and after the earthquake				%
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
%  gparam = [ b_n v_n O_n a_n tau_n ...						%	
%	      b_e v_e O_e a_n tau_n ...						%
%	      b_u v_u O_u a_u tau_u ]						%
%  err - errors that correspond to the parameters in gparam			%
%        Note: no errors returned so far					%
%  wrms  - weighted root mean squares	[1*3 row vector]			%
%  rchi2 - mse [1*3 row vector]      						%
%										%
% Reference: Langbein et al. BSSA 2006						%
%										%
% uses GPS_lsqnonlin_logfunc_samerate.m						%
% [ diff ] = GPS_lsqnonlin_logfunc_samerate(xx,tt,yy,yyErr,Teq)			%
%       xx = [ b v O a tau ]							%
% first created by lfeng Thu Mar  8 16:52:40 SGT 2012				%
% last modified by lfeng Tue Mar 20 14:49:34 SGT 2012				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Equation: 								 
% t < Teq:  y = b + v*t 						 
%				       t-Teq
% t >= Teq: y = b + v*t + O + a*log(1+-------)			 
%					tau			 
%									 
% Independent Parameters: t						 
% Dependent Parameters:   y                                              
% Coefficients: 							 
%  Teq - earthquake time						 
%    b - nominal value of intercept					 
%    v - interseismic velocity						 
%    O - coseismic offset						 
%    a - coefficient for log						 
%  tau - time constant							 
%  tau is the only non-linear parameter

err      = [];
parNum   = 5;						% num of unknown parameters in the model
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
rneuCurr  = rneu(ind,:); 				% exclude some data from fitting
usedNum   = size(rneuCurr,1);
dispMin   = min(min(rneuCurr(:,3:5)));
dispMax   = max(max(rneuCurr(:,3:5)));
dispRange = dispMax-dispMin;

% xx = [ b v O a tau ]
x0 = [ 1 1 100 -1 0.001 ];
lb = [ dispMin -1e3 -dispRange -1e4   0 ];
ub = [ dispMax  1e3  dispRange  1e4 100 ];

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
   lsqnonlin(@(xx) GPS_lsqnonlin_logfunc_samerate(xx,tt,pos,err,Teq),x0,lb,ub,options);	
   % check if successful
   %if exitflag~=1, error('GPS_fitrneu_log_samerate ERROR: do not converge!'); end
   gparam(1,(ii-1)*parNum+1:(ii-1)*parNum+parNum) = xx;
   % how good is the fit!
   chi2      = resnorm;
   rchi2(ii) = chi2/(usedNum-parNum);
   wrms2     = usedNum*chi2/sum(wgt)/(usedNum-1);	% num/(num-1) unbiased estimate
   wrms(ii)  = sqrt(wrms2);
end
