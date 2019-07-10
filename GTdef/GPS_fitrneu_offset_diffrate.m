function [ oparam,err,wrms,rchi2 ] = GPS_fitrneu_offset_diffrate(rneu,dflag,Teq,dday)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         GPS_fitrneu_offset_diffrate.m				%
% estimate offsets with different rates before and after earthquakes		%
% for GPS time series using the Least Squares method				%
% Matlab function lscov is used to perform least squares estimation!		%
% lscov is applicable to linear equation system only!				%
%										%
% INPUT:									% 
% rneu = [ day time north east vert north_err east_err vert_err ] 		%
% dflag - data flag: 1 means data; 0 means outliers 				%
% dflag,day,time,north,east,vert,north_err,east_err,vert_err all column vectors	%
% Teq  - decimal year for earthquake						%
% dday - exclude num of days before and after earthquake from fitting		%
%										%
% OUTPUT:                   							%
% oparam - parameters for offset & same rates before and after earthquakes 	%
%           |       north      |	east  	 |	  up  	    |		%
%  oparam = [ b_n v1_n v2_n O_n b_e v1_e v2_e O_e b_u v1_u v2_u O_u ]		%
%  err   - errors that correspond to the parameters in oparam			%
%  wrms  - weighted root mean squares	[1*3 row vector]			%
%  rchi2 - mse [1*3 row vector]      						%
%										%
% based on GPS_fitrneu_offset_samerate.m					%
% first created by lfeng Wed Mar  7 00:48:23 SGT 2012				%
% last modified by lfeng Tue Mar 13 14:19:49 SGT 2012				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Equation: 								 
% t < Teq:  y = b + v1*t 						 
% t >= Teq: y = b + v1*Teq + v2*(t-Teq) + O				 
%									 
% Independent Parameters: t						 
% Dependent Parameters:   y                                              
% Coefficients: 							 
%  Teq - earthquake time						 
%    b - nominal value of intercept					 
%    v1 - velocity before offset					 
%    v2 - velocity after offset						 
%    O - coseismic offset						 
%--------------------------------------------------------------------------------
% Input for lscov:
% d = Ax 			d - observation corresponding to y
% A cannot be rank deficient; otherwise no single solution
% d = [ y0 y1 ... yn ]'
% A = [ 1 t1    0    0 ] 
%     [ 1 t2    0    0 ]
%     [ ......  0    0 ] 
%     [ 1 Teq ti-Teq 1 ] 
%     [ 1 Teq tn-Teq 1 ]
% x = [ b  ]
%     [ v1 ] 
%     [ v2 ] 
%     [ O  ]

errRatio = 3;					% 3*sigma is 99% confidence interval
parNum = 4;						% num of unknown parameters in the model
rneuCurr = rneu;
rchi2 = zeros(1,3);
wrms  = zeros(1,3);

% exclude some data before and after earthquake
if dday>0
   dT = (dday+0.1)/365.0;
   ind = rneu(:,2)>(Teq-dT) & rneu(:,2)<(Teq+dT);
   dflag(ind) = 0;
end

% least square offset fit, iteration through 3 components
%ecomp = 1;						% exclude data when one component shows abnormal
ecomp = 2;						% exclude data when two components show abnormal
while(1)
   ind	    = dflag==1;
   rneuCurr = rneuCurr(ind,:); 				% exclude some data from fitting
   usedNum  = size(rneuCurr,1);
   dflag    = ones(usedNum,1);
   eflag    = zeros(usedNum,1);				% outlier flag - 0 is normal, 1 is outlier
   for ii=1:3
      % least square fit can not have extra rows with zeros
      tt0  = rneuCurr(:,2); tt1 = tt0;
      ind1 = tt0<Teq;      ind2 = tt0>=Teq; 
      % 1st column
      AA0 = ones(usedNum,1); 
      % 2nd column
      tt0(ind2) = Teq;
      % 3rd column
      tt1(ind1) = 0; tt1(ind2) = tt1(ind2)-Teq; 
      % 4th column
      AA1 = AA0; AA1(ind1) = 0;
      % form coefficiency matrix
      AA = [ AA0 tt0 tt1 AA1 ];
      pos = rneuCurr(:,ii+2);
      wgt = 1./rneuCurr(:,ii+5).^2;			% weight is the inverse of squared formal error
      %-------------------------------------------------
      % xx   - estimated results;  
      % stdx - standard errors of xx stdx = sqrt(diag(S))
      % mse  - mean squared error     mse = rchi2; 
      % S    - estimated covariance matrix of xx
      %-------------------------------------------------
      [ xx,stdx,mse,S ] = lscov(AA,pos,wgt);		
      oparam(1,(ii-1)*parNum+1:(ii-1)*parNum+parNum) = xx';
      err(1,   (ii-1)*parNum+1:(ii-1)*parNum+parNum) = stdx';
      % calculate rchi2 = mse
      rr        = abs(AA*xx-pos);			% residuals of model prediction
      rr2       = rr.^2;
      chi2      = sum(rr2.*wgt);
      rchi2(ii) = mse;
      %rchi2 = chi2/(usedNum-parNum);
      % calculate wrms
      wrms2     = usedNum*chi2/sum(wgt)/(usedNum-1);	% num/(num-1) unbiased estimate
      wrms(ii)  = sqrt(wrms2);
      wrmsm     = errRatio*wrms(ii);
      % find out outliers
      ind   = rr>=wrmsm;
      eflag(ind) = eflag(ind)+1;
   end
   if eflag<ecomp						
      % no more outliers
      break;		
   else 
      % remove outliers
      ind = eflag>=ecomp;
      dflag(ind) = 0;
      fprintf(1,'GPS_fitrneu_offset_diffrate WARNING: %.0f outliers excluded!\n',sum(ind));
   end
end
