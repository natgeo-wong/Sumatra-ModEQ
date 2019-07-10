function [ CC,Cw,Crw,Cp ] = GPS_noisum2cov(rneu,noisum)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GPS_noisum2cov.m                                    %
% use noisum struct to form covariance matrix for given rneu                        %
%                                                                                   %
% INPUT:                                                                            %
% rneu - fit residual or data (only time info used)                                 %
%      = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                                %
% --------------------------------------------------------------------------------- %
% noisum struct including                                                           %
% noisum.site     - site name                                                       %
% noisum.loc      - site location                                                   %
%          = [ lon lat elev ]                                                       %
% noisum.rateRow  - linear rate                                                     %
%          = [ Tstart Tend nnb nnRate eeb eeRate uub uuRate                         %
%              nnbErr nnRateErr eebErr eeRateErr uubErr uuRateErr ] (2+6*2)         %
% noisum.fqMat    - frequency in 1/year                                             %
%          = [ fqSin fqCos ]             (fqNum*2)                                  %
% noisum.ampMat   - amplitudes for seasonal signals                                 %
%          = [ Tstart Tend nnS nnC eeS eeC uuS uuC                                  %
%              nnSErr nnCErr eeSErr eeCErr uuSErr uuCErr ]  fqNum*(2+6*2)           %
% noisum.noiMat   - indecies and amplitudes for noise components                    %
%          = [ nnInd nnAmp eeInd eeAmp uuInd uuAmp                                  %
%              nnIndErr nnAmpErr eeIndErr eeAmpErr uuIndErr uuAmpErr ] (noiNum*12)  %
%   white noise (index=0), power1 noise, power2 noise                               %
%   one row represents one index                                                    %
% --------------------------------------------------------------------------------- %
%                                                                                   %
% OUTPUT:                                                                           %
% CC  - covariance matrix for total noise                                           %
% Cw  - covariance matrix for white noise                                           %
% Crw - covariance matrix for random walk                                           %
% Cp  - covariance matrix for power law noise                                       %
%                                                                                   %
% References:                                                                       %
% (1) Langbein (2004), Noise in two-color electronic distance meter measurements    %        
% revisited, JGR, 109(B04406), doi:10.1029/2003JB002819.                            %
% (2) Williams (2003), The effect of coloured noise on the uncertainties of rates   %
% estimated from geodetic time series,JGeod,76,483–494,doi:10.1007/s00190-002-0283-4%
%                                                                                   %
% first created by Lujia Feng Fri Nov 29 10:31:07 SGT 2013                          %
% print out covariance info lfeng Tue Jan  7 19:20:37 SGT 2014                      %
% last modified by Lujia Feng Tue Jan  7 19:28:46 SGT 2014                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dayNum    = size(rneu,1);           % number of daily solution
noiNum    = size(noisum.noiMat,1);  % number of noise component
time      = rneu(:,2)-rneu(1,2);
dt        = time(2)-time(1);
days      = round(time./dt)+1;
alldayNum = days(end); % 1st day is 1

% initialize
CwN  = zeros(dayNum,dayNum);
CwE  = CwN;
CwU  = CwN;
CrwN = CwN;
CrwE = CwN;
CrwU = CwN;
CpN  = CwN;
CpE  = CwN;
CpU  = CwN;

Cw  = zeros(dayNum*3,dayNum*3); 
Crw = Cw;
Cp  = Cw;
CC  = Cw;

for ii=1:noiNum
   index = noisum.noiMat(ii,1);
   % white noise
   if index==0
      II  = eye(dayNum);
      CwN = II*noisum.noiMat(ii,2)^2;
      CwE = II*noisum.noiMat(ii,4)^2; 
      CwU = II*noisum.noiMat(ii,6)^2; 
      Cw  = blkdiag(CwN,CwE,CwU);
      CC  = CC + Cw;
   % random walk
   elseif index==2
      TT   = tril(ones(alldayNum,alldayNum),0); % matrix with lower triangle = 1
      JJ   = TT*TT'; % Hosking fractional differencing
      JJ   = dt*JJ(days,days); % scale by interval see Eq14 in ref(2)
      CrwN = JJ*noisum.noiMat(ii,2)^2; % scale by amplitude of random walk
      CrwE = JJ*noisum.noiMat(ii,4)^2; 
      CrwU = JJ*noisum.noiMat(ii,6)^2; 
      Crw  = blkdiag(CrwN,CrwE,CrwU); % concatenate 3 components together
      CC   = CC + Crw;
   % power law noise including flicker noise
   else
      % loop through to form phi_n see Eq8 in ref(2)
      phi = zeros(1,alldayNum);
      for jj=1:alldayNum
          nn = jj - 1; % phi index starts from 0 instead of 1
          phiTop  = 0.5*index + [0:nn-1];
          phiBot  = [1:nn];
          phiComp = bsxfun(@rdivide,phiTop,phiBot);
          phi(jj) = prod(phiComp);
          % cann't use gamma function, it goes to infinite
          %phi = gamma(ii-1+0.5*index)/gindex/gamma(ii);
      end
      phiMat = phi(ones(alldayNum,1),:); % duplicate rows
      ind = (1-alldayNum):1:0; % index for diagonal columns
      TT  = spdiags(phiMat,ind,alldayNum,alldayNum);
      JJ  = TT*TT'; % Hosking fractional differencing
      JJ  = dt^(0.5*index)*JJ(days,days); % scale by interval see Eq10 in ref(1) & Eq14 in ref(2)
      CpN = JJ*noisum.noiMat(ii,2)^2; % scale by amplitude of random walk
      CpE = JJ*noisum.noiMat(ii,4)^2; 
      CpU = JJ*noisum.noiMat(ii,6)^2; 
      Cp  = blkdiag(CpN,CpE,CpU); % concatenate 3 components together
      CC  = CC + Cp;
   end
end

% data covariance matrix - symmetric positive semi-definite matrix
% diagonal terms dominate
% off-diagonal terms increase with time
CN = CwN + CrwN + CpN; meanCN = mean(sqrt(diag(CN)));
CE = CwE + CrwE + CpE; meanCE = mean(sqrt(diag(CE)));
CU = CwU + CrwU + CpU; meanCU = mean(sqrt(diag(CU)));
fprintf(1,'Average standard deviation for North is %8.2f mm\n',meanCN*1e3);
fprintf(1,'Average standard deviation for East  is %8.2f mm\n',meanCE*1e3);
fprintf(1,'Average standard deviation for Up    is %8.2f mm\n',meanCU*1e3);
