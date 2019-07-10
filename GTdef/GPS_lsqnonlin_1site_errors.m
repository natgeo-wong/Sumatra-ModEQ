function [ lsqsum ] = GPS_lsqnonlin_1site_errors(rneuRes,lsqsum,noisum)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       GPS_lsqnonlin_1site_errors                                  %
% add colored noise to improve error estimates of xx                                %
%                                                                                   %
% INPUT:                                                                            %
% rneuRes - fit residual                                                            %
%         = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                             %
% --------------------------------------------------------------------------------- %
% lsqsum struct including                                                           %
% lsqsum.site          - site name                                                  %
% lsqsum.daynum        - number of days used                                        %
% lsqsum.xx            - solutions  (1*xxNum)                                       %
% lsqsum.xxStd         - standard deviation of solutions                            %
% lsqsum.xxCor         - correlation matrix for model parameters                    %
% lsqsum.resnorm       - chi2, MATLAB output weighted by errors                     %
% lsqsum.realresnorm   - squared 2-norm of the residual                             %
% lsqsum.realrms       - root-mean-square (RMS) misfit                              %
% lsqsum.realrmsN      - root-mean-square (RMS) misfit for North                    %
% lsqsum.realrmsE      - root-mean-square (RMS) misfit for East                     %
% lsqsum.realrmsU      - root-mean-square (RMS) misfit for Up                       %
% lsqsum.realrms1      - root-mean-square (RMS) misfit for 1st iteration            %
% lsqsum.realrmsN1     - root-mean-square (RMS) misfit for 1st iteration North      %
% lsqsum.realrmsE1     - root-mean-square (RMS) misfit for 1st iteration East       %
% lsqsum.realrmsU1     - root-mean-square (RMS) misfit for 1st iteration Up         %
% lsqsum.residual      - value of the residual fun(x) at the solution xx (pntNum*1) %
% lsqsum.exitflag      - exit condition                                             %
% lsqsum.output        - a structure that contains optimization information         %
% lsqsum.lambda        - Lagrange multipliers at the solution xx                    %
% lsqsum.jacob         - Jacobian of fun(x) at the solution xx (pntNum*xxNum)       %
% lsqsum.realjacob     - real Jacobian after reversing back weights                 %
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
% lsqsum: add new components                                                        %
% lsqsum.xxCov                                                                      %
% lsqsum.xxStd                                                                      %        
%                                                                                   %
% first created by Lujia Feng Tue Nov 26 20:37:28 SGT 2013                          %
% removed realresnorm lfeng Tue Jan  7 18:18:35 SGT 2014                            %
% added scatter output lfeng Wed Mar 19 11:09:46 SGT 2014                           %
% added lsqsum.site lfeng Wed Mar 19 12:48:10 SGT 2014                              %
% considered nan values in rneu data lfeng Mon Aug 18 12:42:31 SGT 2014             %
% last modified by Lujia Feng Mon Aug 18 13:29:53 SGT 2014                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% weighted non-linear inversion is used
% so jacobian has to be converted back to the status before weighting
% intercept should have 1 in jacobian, so ues intercepts to reverse back
% -----------------------------------------------------------------------------------
dayNum  = size(rneuRes,1);
nanNumN = sum(isnan(rneuRes(:,3)));
nanNumE = sum(isnan(rneuRes(:,4)));
nanNumU = sum(isnan(rneuRes(:,5)));
jacobN  = bsxfun(@rdivide,lsqsum.jacob(1:dayNum-nanNumN,:),lsqsum.jacob(1:dayNum-nanNumN,1)); % N
jacobE  = bsxfun(@rdivide,lsqsum.jacob(dayNum-nanNumN+1:dayNum*2-nanNumN-nanNumE,:),...
                          lsqsum.jacob(dayNum-nanNumN+1:dayNum*2-nanNumN-nanNumE,3)); % E
jacobU  = bsxfun(@rdivide,lsqsum.jacob(dayNum*2-nanNumN-nanNumE+1:end,:),...
                          lsqsum.jacob(dayNum*2-nanNumN-nanNumE+1:end,5)); % U
jacob   = [ jacobN; jacobE; jacobU ];
lsqsum.realjacob = jacob;

% if realistic noise model not provided
% noise is calculated based on residual scatters
if isempty(noisum)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % calcualte lower-bound standard deviation of individual model parameters xx
   % xxCovinv close to singular when using user-defined Jacobian
   % ---------------------------------------------------------------------------------
   % estimate N E U standard deviations from residual scatters
   parNum = length(lsqsum.xx);
   modulo = mod(parNum,3);
   switch modulo
      case 0
         dofNum = lsqsum.daynum-parNum/3;
      case 1
         dofNum = lsqsum.daynum-(parNum+2)/3;
      case 2
         dofNum = lsqsum.daynum-(parNum+1)/3;
   end
   indnn   = ~isnan(rneuRes(:,3));
   nnSigma = sqrt(sum(rneuRes(indnn,3).^2)/dofNum);
   indee   = ~isnan(rneuRes(:,4));
   eeSigma = sqrt(sum(rneuRes(indee,4).^2)/dofNum);
   induu   = ~isnan(rneuRes(:,5));
   uuSigma = sqrt(sum(rneuRes(induu,5).^2)/dofNum);
   fprintf(1,'\nThe scatters of N E U are %10.4e [m] %10.4e [m] %10.4e [m]\n',nnSigma,eeSigma,uuSigma);
   %------- output to a file -------%
   fout = fopen('GPS_lsqnonlin_1site_errors.out','a');
   fprintf(fout,'%s Nscatter_Escatter_Uscatter %10.4e %10.4e %10.4e [m]\n',lsqsum.site,nnSigma,eeSigma,uuSigma);
   fclose(fout);
   %--------------------------------%
   % add estimated standard deviations to Jacobian
   jacobN  = jacobN/nnSigma; % N	
   jacobE  = jacobE/eeSigma; % E
   jacobU  = jacobU/uuSigma; % U
   jacob   = [ jacobN; jacobE; jacobU ];
   % form model parameter covariance matrix
   xxCovinv = full(jacob'*jacob);
   % if xxCovinv nearly singular, the problem is ill-conditioned
   rankCov  = rank(xxCovinv);
   % Moore-Penrose pseudoinverse to get model parameter covariance matrix
   xxCov    = pinv(xxCovinv);
   % standard deviation for model parameters
   xxStd    = sqrt(diag(xxCov));
   xxStdinv = diag(1./xxStd);
   % correlation matrix for model parameters
   xxCor    = xxStdinv*xxCov*xxStdinv;
else
   jacobinv = pinv(full(jacob));
   %II       = eye(dayNum);
   %ddNCov   = nnSigma^2*II;
   %ddECov   = eeSigma^2*II;
   %ddUCov   = uuSigma^2*II;
   %ddCov    = blkdiag(ddNCov,ddECov,ddUCov);
   fprintf(1,'\nnoisum is used to calculate data covariance with colored noise!\n');
   [ ddCov,~,~,~ ] = GPS_noisum2cov(rneuRes,noisum); % ddCov - symmetric positive semi-definite matrix
   fprintf(1,'\nJacobian is combined with data covariance!\n');
% method (1)
   xxCov    = jacobinv*ddCov*jacobinv';
% method (2) order of magnitude = (1)
%-------   xxCov    = pinv(jacob'*pinv(ddCov)*jacob);
   xxStd    = sqrt(diag(xxCov));
end

lsqsum.xxCov = xxCov;
lsqsum.xxStd = xxStd;

% calculate 95% confidence invervals
%---- nlparci
% calculate correlation of parameters
%---- fprintf(1,'\n correlation of model parameters\n',pvalue);
%---- xxR   = full(corrcov(xxCov));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% project n-dimensional error ellipsoid onto axes to get conservative confidence intervals
% ----------------------------------------------------------------------------------------
%---- [ eigAxis,eigValue ] = eig(xxCovinv);
%---- delta2    = chi2inv(0.683,dofNum);                  % chi2 inverse cdf
%---- ellipAxis = sqrt(delta2./diag(eigValue));           % semilength of 3 axes of error ellipsoids
%---- ellipMat  = spdiags(ellipAxis,0,xxNum,xxNum);
%---- ellipProj = abs(eigAxis*ellipMat);                  % project ellipsoid to all parameter axes
%---- ellipStd  = max(ellipProj,[],2);                    % get the maximum projected axis length
%---- xxStd     = ellipStd;
