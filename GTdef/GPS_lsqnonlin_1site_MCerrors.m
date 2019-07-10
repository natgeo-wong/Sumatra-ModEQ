function [ lsqsum ] = GPS_lsqnonlin_1site_MCerrors(rneuModel,fitsum,lsqsum,noisum,boundsFlag,cases)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         GPS_lsqnonlin_1site_MCerrors                              %
% using Monte Carlo error propagation to estimate errors of xx                      %
%                                                                                   %
% INPUT:                                                                            %
% rneuModel - model prediction (dayNum*8)                                           %
%           = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                           %
% note: outliers have been removed in rneuModel                                     %
%       errors have been kept the same                                              %
% --------------------------------------------------------------------------------- %
% fitsum struct including                                                           %
% fitsum.site      - site name                                                      %
% fitsum.loc       - site location                                                  %
%          = [ lon lat elev ]                                                       %
% fitsum.rateRow   - linear rates                                                   %
%          = [ Tstart Tend nnb nnRate eeb eeRate uub uuRate                         %
%              nnbErr nnRateErr eebErr eeRateErr uubErr uuRateErr ] (2+6*2)         %
% fitsum.minmaxRow - lower & upper bounds for linear rates                          %
%          = [ Tstart Tend nnb nnRate eeb eeRate uub uuRate   <-min                 %
%                          nnb nnRate eeb eeRate uub uuRate ] <-max (2+6*2)         %
% fitsum.eqMat     - earthquake dates that has been ordered chronologically         %
%          = [ Deq Teq ]                 (eqNum*2)                                  %
%          = [] means no earthquake removed                                         %
% fitsum.funcMat   - a string matrix for function names                             %
%          = [ funcN funcE funcU ]       (eqNum*3*funcLen)                          %
% fitsum.paramMat  - each row for one earthquake (eqNum*3*7*2)                      %
%          = [ nb nv1 nv2 ndV nO na ntau                                            %
%              eb ev1 ev2 edV eO ea etau                                            %
%              ub uv1 uv2 udV uO ua utau                                            %
%              nbErr nv1Err nv2Err ndVErr nOErr naErr ntauErr                       %
%              ebErr ev1Err ev2Err edVErr eOErr eaErr etauErr                       %
%              ubErr uv1Err uv2Err udVErr uOErr uaErr utauErr ]                     %
% fitsum.minmaxMat - lower & upper bounds for paramMat (eqNum*3*7*2)                %
%          = [ nb nv1 nv2 ndV nO na ntau \                                          %
%              eb ev1 ev2 edV eO ea etau  min                                       %
%              ub uv1 uv2 udV uO ua utau /                                          %
%            / nb nv1 nv2 ndV nO na ntau                                            %
%        max   eb ev1 ev2 edV eO ea etau                                            %
%            \ ub uv1 uv2 udV uO ua utau ]                                          %
% fitsum.fqMat     - frequency in 1/year                                            %
%          = [ fqSin fqCos ]             (fqNum*2)                                  %
% fitsum.ampMat    - amplitudes for seasonal signals                                %
%          = [ Tstart Tend nnS nnC eeS eeC uuS uuC                                  %
%              nnSErr nnCErr eeSErr eeCErr uuSErr uuCErr ]  fqNum*(2+6*2)           %
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
% boundsFlag = 'yes' using bounds                                                   %
%            = 'no' not using bounds even if specified in fitsum files              %
% --------------------------------------------------------------------------------- %
% cases - number of Monte Carlo cases to simulate errors                            %
%                                                                                   %
% OUTPUT:                                                                           %
% lsqsum: add new components                                                        %
% lsqsum.xxCov; lsqsum.xxStd                                                        %       
%                                                                                   %
% References:                                                                       %
% (1) Aster, Borchers, Thurber (2005), Parameter Estimation and Inverse Problems    %
%     1st ed., Elsevier Academic Press P35.                                         %
%                                                                                   %
% first created by Lujia Feng Tue Jan  7 10:32:56 SGT 2014                          %
% last modified by Lujia Feng Mon Jun  2 00:07:39 SGT 2014                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'\nMonte Carlo error propagation is used to estimate parameter errors!\n');

% pntNum = dayNum*3 (3 means NEU components)
% ddMu   - [1*pntNum] (row vector)
ddMu = reshape(rneuModel(:,3:5),1,[]); % concatenate 3 components together
% ddCov  - [pntNum*pntNum] 
fprintf(1,'\nnoisum is used to calculate colored noise!\n');
[ ddCov,~,~,~ ] = GPS_noisum2cov(rneuModel,noisum); % ddCov - symmetric positive semi-definite matrix

% generate random vectors from multivariate normal distribution with correlation among variables
% ddRand - [cases*pntNum]
ddRand = mvnrnd(ddMu,ddCov,cases);
fprintf(1,'\ngenerated %6d random vectors!\n\n',cases);

% set up options
parNum  = 100;
tol     = 1e-15;
options = optimset('MaxFunEvals',250*parNum,'MaxIter',5000,'TolFun',tol,'TolX',tol,...
                   'Jacobian','off','DerivativeCheck','off','FunValCheck','on',...
		   'Diagnostics','off','Display','none');

% initial values & bounds
[ x0,lb,ub ] = GPS_lsqnonlin_1site_prep(rneuModel,fitsum);
tt0      = []; % time reference point
rneuRand = rneuModel;
eqMat    = fitsum.eqMat;
funcMat  = fitsum.funcMat;
fqMat    = fitsum.fqMat;

% Monte Carlo simulations (ref1)
xxRand = zeros(cases,length(x0));
for ii=1:cases
   tic
   rneuRand(:,3:5) = reshape(ddRand(ii,:),[],3);
   if strcmpi(boundsFlag,'yes')
      [ xx,resnorm,residual,exitflag,output,lambda,jacob ] = ...
      lsqnonlin(@(xx) GPS_lsqnonlin_1site(rneuRand,eqMat,funcMat,fqMat,xx,tt0),x0,lb,ub,options);
   elseif strcmpi(boundsFlag,'no')
      [ xx,resnorm,residual,exitflag,output,lambda,jacob ] = ...
      lsqnonlin(@(xx) GPS_lsqnonlin_1site(rneuRand,eqMat,funcMat,fqMat,xx,tt0),x0,[],[],options);
   else
      error('GPS_lsqnonlin_1site_MCerrors ERROR: boundsFlag must be either yes or no!');
   end
   % check exit condition
   fprintf(1,'..... Monte Carlo simulation: %8d exitflag = %4d ..... \t',ii,exitflag);
   % if exitflag~=1, error('GPS_lsqnonlin_1site_MCerrors ERROR: do not converge!'); end
   xxRand(ii,:) = xx;
   toc
end

AA    = bsxfun(@minus,xxRand,mean(xxRand)); % the difference between the ith model and the average model
xxCov = AA'*AA/cases;
xxStd = sqrt(diag(xxCov));

lsqsum.xxCov = xxCov;
lsqsum.xxStd = xxStd;
