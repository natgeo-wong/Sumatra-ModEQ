function [ eparam,err,wrms,rchi2 ] = GPS_fitrneu_exp_samerateN(rneuCell,dflagCell,Teq,dday)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_fitrneu_exp_samerateN.m				%
% estimate an earthquake offset with an exponential decay of afterslip		%
% + the same rate before and after the earthquake				%
% + the same tau for three components (tau=tau_n=tau_e=tau_u)			%
%										%
% INPUT:									% 
% rneuCell - each cell stores rneu data for one site			        %
% rneu = [ day time north east vert north_err east_err vert_err ] 		%
% dflag - data flag: 1 means data; 0 means outliers 				%
% dflagCell - each cell stores dflag data for one site			        %
% dflag,day,time,north,east,vert,north_err,east_err,vert_err all column vectors	%
% Teq  - decimal year for earthquake						%
% dday - exclude num of days before and after earthquake from fitting		%
%										%
% OUTPUT:                   							%
% eparam = [ b_n v_n O_n a_n tau						%	
%	     b_e v_e O_e a_n tau						%
%	     b_u v_u O_u a_u tau ]	[row vector]				%
%  err - errors that correspond to the parameters in eparam			%
%        Note: no errors returned so far					%
%  wrms  - weighted root mean squares	[scalar]				%
%  rchi2 - mse [scalar]      							%
%										%
% Reference: Thomas Herring's tsview manual					%
%	     Cleve Moler's Numerical computing with Matlab: chapter 5		%
%										%
% uses GPS_lsqnonlin_expfunc_samerateN.m					%
% [ diff ] = GPS_lsqnonlin_expfunc_samerateN(xx,rneu,Teq)			%
%   xx = [ n_b n_v n_O n_a      						%
%          e_b e_v e_O e_a      						%
%          u_b u_v u_O u_a tau ]						%
% first created by lfeng Wed Mar 28 11:45:40 SGT 2012                           %
% last modified by lfeng Wed Mar 28 12:13:18 SGT 2012				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Equation: 								 
% t < Teq:  y = b + v*t 						 
%					  t-Teq
% t >= Teq: y = b + v*t + O + a*(1-exp(- -------))			 
%					   tau			 
% Independent Parameters: t						 
% Dependent Parameters:   y                                              
% Coefficients: 							 
%  Teq - earthquake time						 
%    b - nominal value of intercept					 
%    v - interseismic velocity						 
%    O - coseismic offset						 
%    a - amplitude of the exponential term				 
%  tau - decay time constant						 
%  tau is the only non-linear parameter

wrms    = 0;
err     = [];
usedNum = 0;
sparNum = 13;	% parameter number for each site
fparNum = 15;   % full parameter for each component
staNum  = length(rneuCell);
% 1st parameter is tau
x0      = 0.001;
lb      = 0;
ub      = 50;

rneuCurrCell = rneuCell;
for ii=1:staNum
   rneu = rneuCell{ii};
   dflag = dflagCell{ii};

   % exclude some data before and after earthquake
   if dday>0
      dT = (dday+0.1)/365.0;
      ind = rneu(:,2)>(Teq-dT) & rneu(:,2)<(Teq+dT);
      dflag(ind) = 0;
   end
   
   % range for displacement
   ind       = dflag==1;
   rneuCurr  = rneu(ind,:);                             % exclude some data from fitting
   rneuCurrCell{ii} = rneuCurr; 				
   usedNum   = usedNum + size(rneuCurr,1);
   dispMin   = min(min(rneuCurr(:,3:5)));
   dispMax   = max(max(rneuCurr(:,3:5)));
   dispRange = dispMax-dispMin;
   
   % xx = [ tau n_b n_v n_O n_a 
   %            e_b e_v e_O e_a 
   %            u_b u_v u_O u_a ]
   x0 = [ x0 1 1 100 1 ...
             1 1 100 1 ...
             1 1 100 1 ];
   lb = [ lb dispMin -1e3 -dispRange -1e4 ...
             dispMin -1e3 -dispRange -1e4 ...
             dispMin -1e3 -dispRange -1e4 ];
   ub = [ ub dispMax  1e3  dispRange  1e4 ...
             dispMax  1e3  dispRange  1e4 ...
             dispMax  1e3  dispRange  1e4 ];
end
parNum  = length(x0);				               % num of unknown parameters in the model

% non-linear least squares			
% resnorm  - the squared 2-norm of the residual = chi2
% residual - the value of the residual fun(x) at the solution x rr = abs(residual)
options = optimset('MaxFunEvals',500*parNum,'MaxIter',2000,'TolFun',1e-12,'TolX',1e-12);
[ xx,resnorm,residual,exitflag ] = ...
lsqnonlin(@(xx) GPS_lsqnonlin_expfunc_samerateN(xx,rneuCurrCell,Teq),x0,lb,ub,options);	
% check if successful
%if exitflag~=1, error('GPS_fitrneu_exp_samerateN ERROR: do not converge!'); end
% how good is the fit!
chi2  = resnorm;					% residual is weighted
rchi2 = chi2/(usedNum-parNum);

% output parameters
tau    = xx(1);                                                % tau
oparam = reshape(xx(2:end),sparNum-1,[])';		       % exclude tau
eparam = zeros(staNum,fparNum);
eparam(:,1:4)       = oparam(:,1:4);
eparam(:,6:9)       = oparam(:,5:8);
eparam(:,11:14)     = oparam(:,9:12);
eparam(:,[5 10 15]) = tau;
