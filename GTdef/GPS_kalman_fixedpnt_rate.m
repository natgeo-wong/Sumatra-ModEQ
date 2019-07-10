function [ yynew,bb,vv ] = GPS_kalman_fixedpnt_rate(tt,yy,ee,errScale,svecScale,x0,P0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    GPS_kalman_fixedpnt_rate.m                         %
% apply Kalman filter with fixed-point smoothing to time series         %
% Note: standard Kalman filter must be computed too                     %
% Observation Equation is                                               %
% yy = bb + vv*tt + error                                               %
%                                                                       %
% yk = bk + Rk                                                          %
% bk = bk-1 + vk-1*dt                                                   %
%                                                                       %
% State vector - a column vector                                        %
% x = [ bb vv ]'                                                        %
%                                                                       %
% Design Matrix - a row vector                                          %
% H = [ 1 0 ]                                                           %
%                                                                       %
% Transition Matrix                                                     %
% F = [ 1 dt                                                            %
%       0 1; ]                                                          %
% F is sometimes named T                                                %
% --------------------------------------------------------------------- %
% INPUT:                                                                %
% x0        - initial values for state vector                           %
%           = [ b0 v0 ]' (must be a column vector)                      %
% P0        - initial covariance matrix for state vector                %
%           = diag([1000 1000])                                         %
% tt        - time                                                      %
% yy        - position                                                  %
% ee        - error                                                     %
% errScale  - measurement error scale, e.g., 100                        %
% svecScale - state vector error scale, e.g., 0.01                      %
%                                                                       %
% OUTPUT:                                                               %
% yynew - predicted position                                            %
% bb    - nominal reference                                             %
% vv    - predicted instantaneous rates                                 %
%                                                                       %
% REFERENCES:                                                           %
% (1) Poor Man's Explanation of Kalman Filtering                        %
% (2) Dan Simon, Optimal State Estimation, 2006                         %
%                                                                       %
% first created based on GPS_kalman_rate.m by Lujia Feng May 5 SGT 2015 %
% added svecScale lfeng Wed May  6 12:50:05 SGT 2015                    %
% added standard Kalman filter lfeng Wed May  6 19:08:47 SGT 2015       %
% added x0 & P0 lfeng Thu May  7 16:48:12 SGT 2015                      %
% last modified by Lujia Feng Thu May  7 17:47:21 SGT 2015              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% initialization %%%%%%%%%%%%%%%%
% read in data
dataNum  = size(yy,1);
yynew    = yy;
bb       = zeros(dataNum,1);
vv       = zeros(dataNum,1);
TT       = 1;

% design/measurement matrix (must be a row vector)
HH = [ 1 0 ];
% measurement noise covariance
%RR = 30^2;
ee = ee*errScale;
RR = diag(ee.^2);

%%%%%%%%%%%%%%%% loop through %%%%%%%%%%%%%%%%
for jj=1:dataNum
   if jj>1
      % time step
      dt = tt(jj,1) - tt(jj-1,1);
      % state vector covariance matrix
      QQ = diag(svecScale*[1 dt]);
      % transition matrix
      FF = [ 1 dt;
             0 1 ];
   else
      QQ = diag(svecScale*[1 0]);
      FF = [ 1 0;
             0 1 ];
   end

   % --------------- time update equations -> a priori estimates ---------------
   % state vector for t=jj based on measurements before jj
   x1 = FF*x0;          % eq5.11 in ref2
   % estimation error covariance matrix for t=jj based on measurements before jj
   P1 = FF*P0*FF' + QQ; % eq5.14 in ref2

   % --------------- fixed-point smoother --------------- p269 in ref2
   % initialization
   % error covarinance matrix of smoothed estimate for t=jj at time jj
   MM = P1; 
   % crosss covariance between MM & P1
   NN = P1;
   %
   x0 = x1;
   xk = x1;
   P0 = P1;
   
   if jj==1, continue; end
   for kk=jj:dataNum
      % time step
      dt = tt(kk,1) - tt(kk-1,1);
      % state vector covariance matrix
      QQ = diag(svecScale*[1 dt]);
      % transition matrix
      FF = [ 1 dt;
             0 1 ];

      % redefined Kalman filter gain
      LL = FF*P0*HH'*inv(HH*P0*HH' + RR(kk,kk));
      lamda = NN*HH'*inv(HH*P0*HH' + RR(kk,kk));

      % a priori estimate of xj/(k+1)
      x0 = x0 + lamda*(yy(kk)-HH*xk);
      % a priori estimate of x-/(k+1)
      xk = FF*xk + LL*(yy(kk)-HH*xk);

      % update estimation error covariance
      P0 = FF*P0*(FF-LL*HH)' + QQ;
      MM = MM - NN*HH'*lamda';
      NN = NN*(FF-LL*HH)';
   end

   % calculate position prediction
   yynew(jj) = HH*x0;
   % record state vectors
   bb(jj) = x0(1);
   vv(jj) = x0(2);

   % --------------- measurement update equations -> a posteriori estimates ---------------
   % Scalar Kalman filter gain = maximum likelihood weighting (Analogous to eq12 in ref1)
   KK = P1*HH'*inv(HH*P1*HH'+RR(jj,jj)); % eq13 in ref1, eq5.19 in ref2

   % state vector at t=jj based on measurements before and including jj
   % update state vector based on Kalman gain
   x0 = x1 + KK*(yy(jj)-HH*x1);
   % estimation error covariance matrix at t=jj based on measurements before and including jj
   % update estimation error covariance matrix (mean square error)
   P0 = (eye(2)-KK*HH)*P1; % note there are three eqs to calculate P (p129 in ref2)
   % ------------------------------------------------------------------------------
end
