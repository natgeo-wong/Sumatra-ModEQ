function [ yynew,yynos,bb,vv,AA,BB ] = GPS_kalman_RTS_rateannual(tt,yy,ee,errScale,svecScale,x0,P0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     GPS_kalman_RTS_rateannual.m                       %
% apply kalman filter with RTS smoother to time series                  %
% Observation Equation is                                               %
% yy = bb + vv*tt + AA*cos(2*pi*tt/T) + BB*sin(2*pi*tt/T) + error       %
%                                                                       %
% yk = bk + AAk*cos(2*pi*tk/T) + BBk*sin(2*pi*tk/T) + Rk                %
% bk = bk-1 + vk-1*dtk                                                  %
%                                                                       %
% State vector - a column vector                                        %
% x = [ bb vv AA BB ]'                                                  %
%                                                                       %
% Design Matrix - a row vector                                          %
% H = [ 1 0 cos(2*pi*tt/T) sin(2*pi*tt/T) ]                             %
%                                                                       %
% Transition Matrix                                                     %
% F = [ 1 dt 0 0;                                                       %
%       0 1  0 0;                                                       %
%       0 0  1 0;                                                       %
%       0 0  0 1 ];                                                     %
% F is sometimes named T                                                %
% --------------------------------------------------------------------- %
% INPUT:                                                                %
% x0        - initial values for state vector                           %
%           = [ b0 v0 A0 B0 ]' (must be a column vector)                %
% P0        - initial covariance matrix for state vector                %
%           = diag([1000 1000 1000 1000])                               %
% tt        - time                                                      %
% yy        - position                                                  %
% ee        - error                                                     %
% errScale  - measurement error scale, e.g., 100                        %
% svecScale - state vector error scale, e.g., 0.01                      %
%                                                                       %
% OUTPUT:                                                               %
% yynew - predicted position                                            %
% yynos - raw data with seasonal signals removed                        %
% bb    - nominal reference                                             %
% vv    - predicted instantaneous rates                                 %
% AA    - amplitude of annual signal                                    %
% BB    - amplitude of annual signal                                    %
%                                                                       %
% REFERENCES:                                                           %
% (1) Poor Man's Explanation of Kalman Filtering                        %
% (2) Dan Simon, Optimal State Estimation, 2006                         %
%                                                                       %
% first created based on GPS_kalman_RTS_rate.m by Lujia Feng May 7 2015 %
% output yynos lfeng Tue May 26 17:51:08 SGT 2015                       %
% last modified by Lujia Feng Tue May 26 18:00:36 SGT 2015              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% initialization %%%%%%%%%%%%%%%%
% read in data
dataNum = size(yy,1);
yynew   = yy;
yynos   = yy;
bb      = zeros(dataNum,1);
vv      = zeros(dataNum,1);
AA      = zeros(dataNum,1);
BB      = zeros(dataNum,1);
TT      = 1;

% measurement noise covariance
%RR = 30^2;
ee = ee*errScale;
RR = diag(ee.^2);

%%%%%%%%%%%%%%%% forward filter %%%%%%%%%%%%%%%%
for ii=1:dataNum
   if ii>1
      % time step
      dt = tt(ii,1) - tt(ii-1,1);
      % covariance matrix of state vector
      QQ = diag(svecScale*[1 dt 100*dt 100*dt]);
      % transition matrix
      FF = [ 1 dt 0 0;
             0 1  0 0;
             0 0  1 0;
             0 0  0 1 ];
   else
      QQ = diag(svecScale*[1 0 0 0]);
      FF = [ 1 0  0 0;
             0 1  0 0;
             0 0  1 0;
             0 0  0 1 ];
   end
   % design matrix (must be a row vector)
   HH = [ 1 0 cos(2*pi*tt(ii)/TT) sin(2*pi*tt(ii)/TT) ];

   % --------------- time update equations -> a priori estimates ---------------
   % state vector at t=ii based on measurements before ii
   x1 = FF*x0;          % eq5.11 in ref2
   xfminus{ii} = x1;
   % estimation error covariance matrix at t=ii based on measurements before ii
   P1 = FF*P0*FF' + QQ; % eq5.14 in ref2
   Pfminus{ii} = P1;

   % --------------- measurement update equations -> a posteriori estimates ---------------
   % Scalar Kalman filter gain = maximum likelihood weighting (Analogous to eq12 in ref1)
   KK = P1*HH'*inv(HH*P1*HH'+RR(ii,ii)); % eq13 in ref1, eq5.19 in ref2

   % state vector at t=ii based on measurements before and including ii
   % update state vector based on Kalman gain
   x0 = x1 + KK*(yy(ii)-HH*x1);
   xfplus{ii} = x0;
   % estimation error covariance matrix at t=ii based on measurements before and including ii
   % update estimation error covariance matrix (mean square error)
   P0 = (eye(4)-KK*HH)*P1; % note there are three eqs to calculate P (p129 in ref2)
   Pfplus{ii} = P0;
end


% calculate position prediction
yynew(dataNum) = HH*x0;
% record state vectors
bb(dataNum) = x0(1);
vv(dataNum) = x0(2);
AA(dataNum) = x0(3);
BB(dataNum) = x0(4);

%%%%%%%%%%%%%%%% backward filter %%%%%%%%%%%%%%%%
for kk=dataNum-1:-1:1
   % time step
   dt = tt(kk+1,1) - tt(kk,1);
   % transition matrix
   FF = [ 1 dt 0 0;
          0 1  0 0;
          0 0  1 0;
          0 0  0 1 ];

   II = inv(Pfminus{kk+1});
   KK = Pfplus{kk}*FF'*II;
   P0 = Pfplus{kk} - KK*(Pfminus{kk+1}-P0)*KK';
   x0 = xfplus{kk} + KK*(x0 - xfminus{kk+1});

   % calculate position prediction
   yynew(kk) = HH*x0;
   yynos(kk) = yy(kk) - HH(3:end)*x0(3:end); % raw data - seasonal signals

   % record state vectors
   bb(kk) = x0(1);
   vv(kk) = x0(2);
   AA(kk) = x0(3);
   BB(kk) = x0(4);
end
