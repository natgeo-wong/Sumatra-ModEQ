function [ x0,x0_std,rate,rate_std,rate_err,rchi2,wrms,w_amp,f_amp,datanum,TT,dflag ] = GPS_fitrneu_linear(rneu,dflag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_fitrneu_linear.m				%
% calculate long-term/interseismic rates and associated errors 			%
% for all 3 components using empirical equations 				%
% in terms of WRMS (weighted root-mean-square scatter) 				%
%										%
% INPUT:									% 
% rneu = [ day time north east vert north_err east_err vert_err ] 		%
% dflag - data flag: 1 means data; 0 means outliers 				%
% dflag,day,time,north,east,vert,north_err,east_err,vert_err all column vectors	%
%										%
% OUTPUT:                   							%
% ----------------------------- column vectors -------------------------------- %
% --------- the order is north, east, vertical as in *.rneu files  ------------	%
% x0 - intercept of linear fit to the time series				%
% rate,rate_err - long-term rate and its associated error [mm/yr]		%
% rchi2 - reduced chi-square							%
% wrms - weighted root-mean-square scatter/residual [mm]			%
% w_amp - amplitude for white noise [mm]					%
% f_amp - amplitude for flicker noise [mm/yr^0.25]				%
% x0, rate,rate_err, rchi2, wrms, w_amp, and f_amp all column vectors		%
% ----------------------------------------------------------------------------- %
% datanum - number of data used							%
% TT - length of time period							%
%                                                                               %
% Reference:                                                                    %
% Dixon_etal_Tectonics_2000 eq1 and eq.a-f in table 3				%
%										%
% first created by lfeng Thu Oct 21 13:23:54 EDT 2010				%
% renamed GPS_3rates.m as GPS_fitrneu_linear.m lfeng Wed Jul 27 SGT 2011	%
% change exclusion from two to one component lfeng Wed Aug 10 14:43:08 SGT 2011 %
% added x0_std & rate_std lfeng Thu Oct 18 11:19:04 SGT 2012                    %
% last modified by lfeng Thu Oct 18 11:19:13 SGT 2012                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Iteration to fit a line and find out outliers
% y = b + vt; 			y - model prediction; b - intercept; v - rate
% d = Ax 			d - observation corresponding to y
% d = [ y0 y1 ... yn ]'
% A = [ 1 t1 ] 
%     [ 1 t2 ]
%     [ .... ] 
%     [ 1 tn ]
% x = [ b ]
%     [ v ] 

% form coefficiency matrix
err_ratio = 3;						% 3*sigma is 99% confidence interval
allnum = size(rneu,1); 					% num of data points

% form weight vectors
for ii=1:3
   wgt0(:,ii) = 1./rneu(:,ii+5).^2;			% weight is the inverse of squared formal error
end

% least square linear fit, iteration through 3 components
%ecomp = 1;						% exclude data when one component shows abnormal
ecomp = 2;						% exclude data when two components show abnormal
while(1)
   eflag = zeros(allnum,1);				% outlier flag - 0 is normal, 1 is outlier
   ind = find(dflag); datanum = length(ind);
   for ii=1:3
      % least square fit
      AA0 = dflag.*ones(allnum,1); tt0 = dflag.*rneu(:,2);
      AA = [ AA0 tt0 ];
      pos = dflag.*rneu(:,ii+2);
      wgt = wgt0(:,ii);
      [ xx,stdx ] = lscov(AA,pos,wgt);			% xx - estimated results; stdx - standard errors of xx; mse - mean squared error
      x0(ii,1)       = xx(1); 				% intercept [mm]
      x0_std(ii,1)   = stdx(1);
      rate(ii,1)     = xx(2); 				% rate [mm/yr]
      rate_std(ii,1) = stdx(2);
      % calculate rchi2
      rr = abs(AA*xx-pos);				% residuals of model prediction
      rr2 = rr.^2;
      chi2 = sum(rr2.*wgt);
      rchi2(ii,1) = chi2/(datanum-2);
      % calculate wrms
      wrms2 = datanum*chi2/sum(dflag.*wgt)/(datanum-1);	% num/(num-1) unbiased estimate
      wrms(ii,1) = sqrt(wrms2);
      wrmsm = err_ratio*wrms(ii,1);
      % find out outliers
      ind = find(rr>=wrmsm);
      eflag(ind) = eflag(ind)+1;
   end
   if eflag<ecomp						
      break;
   else 
      ind = find(eflag>=ecomp);
      dflag(ind) = 0;
   end
end

% form covariance matrix


% noise coefficients for different components: amplitude = a*WRMS+b [mm]
%        N       E       U
w_a = [ 0.613;  0.767;  0.843 ];
w_b = [ 0.259; -0.182; -1.772 ];
f_a = [ 1.139;  1.041;  0.668 ];
f_b = [ 0.117; -0.342;  5.394 ];

% calculate amplitudes of different noises
w_amp  = w_a.*wrms+w_b;					% amplitude for white noise 
w_amp2 = w_amp.^2;
f_amp  = f_a.*wrms+f_b;					% amplitude for flicker noise
f_amp2 = f_amp.^2;
aa = 1.78; bb = 0.22;
% calculate rate error
ind = find(dflag);
TT = rneu(ind(end),2)-rneu(ind(1),2);			% length of time period
gg = datanum/TT;
rate_err2 = 12*w_amp2/gg/TT^3 + aa*f_amp2/gg^bb/TT^2;
rate_err  = sqrt(rate_err2);
