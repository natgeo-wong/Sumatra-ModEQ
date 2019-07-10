function [ fitsum,lsqsum,modsum ] = GPS_fitrneu_1site(rneu,fitsum,noisum,boundsFlag,cases)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              GPS_fitrneu_1site.m                                  %
% Fit the 3 components of 1 station according to the prescribed info                %
% lsqnonlin - non-linear least squares                                              %
% resnorm   - the squared 2-norm of the residual = chi2                             %
% residual  - the value of the residual fun(x) at the solution x rr = abs(residual) %
%                                                                                   %
% INPUT:                                                                            % 
% rneu - data marix (dayNum*8)                                                      %
%      = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                                %
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
% --------------------------------------------------------------------------------- %
% a new fitsum struct                                                               %
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
% modsum struct including                                                           % 
% modsum.uqMat             - unique EQ dates that has been ordered chronologically  %
%                          = [ Deq Teq ]                 (uqNum*2)                  %
%                          = [] means no earthquake removed                         %
% modsum.rneuRaw           - raw data                                               %
% modsum.rneuUsed          - data used                                              %
% modsum.rneuOut           - data outliers                                          %
% modsum.rneuModel         - model prediction                                       %
% modsum.rneuRate          - rates only                                             %
% modsum.rneuSeason        - seasonal signals                                       %
% modsum.rneuRes           - (data-model) residuals                                 %
% modsum.rneuNrate         - remove background rates                                %
% modsum.rneuNoff          - remove offsets                                         %
% modsum.rneuOoff          - keep only offsets                                      %
% modsum.rneuSoff          - keep only small offsets                                %
% modsum.rneuPostSC        - postseismic deformation & seasonal signals             %
% modsum.rneuPostEQs       - only keep postseismic deformation of all EQs           %
% modsum.rneuCopoCell      - coseismic & postseismic for individual EQ with diffrate%
% modsum.rneuPostCell      - postseismic for individual EQ with diffrate            %
% modsum.rneuPostNdiffCell - postseismic for individual EQ without diffrate         %
% modsum.rneuAfterCell     - deformation after coseismic of one EQ                  %
% --------------------------------------------------------------------------------- %
% Note:                                                                             %
% fitsum.eqMat     - may include 2 entries for 1 EQ if lg2, ln2 or ep2 is used      %
% modsum.eqMat     - 1 entry for 1 EQ                                               %
%										    %
% first created by Lujia Feng Wed Jul 11 17:46:00 SGT 2012                          %
% added Jacobian lfeng Mon Nov 26 11:45:17 SGT 2012                                 %
% added minmaxMat lfeng Tue Apr  9 01:07:14 SGT 2013                                %
% added outlier detection lfeng Mon May 13 14:48:19 SGT 2013                        %
% output all EQs that have postseismic lfeng Thu May 16 16:06:43 SGT 2013           %
% added rneuAfterCell lfeng Mon Nov 18 03:06:59 SGT 2013                            %
% added noisum lfeng Tue Nov 26 14:18:06 SGT 2013                                   %
% added MCerrors lfeng Tue Jan  7 12:35:24 SGT 2014                                 %
% added time reference tt0 lfeng Wed Jan  8 14:23:43 SGT 2014                       %
% added modsum.uqMat lfeng Thu Mar  6 10:22:35 SGT 2014                             %
% corrected not output rneuOut lfeng Thu Mar  6 12:57:23 SGT 2014                   %
% added rneuOoff & rneuSoff lfeng Thu Mar  6 17:11:19 SGT 2014                      %
% modified outlier_ratio lfeng Fri Mar  7 03:12:01 SGT 2014                         %
% added lsqsum.site lfeng Wed Mar 19 12:48:10 SGT 2014                              %
% added rneuPostNdiffCell lfeng Wed Mar 26 13:17:04 SGT 2014                        %
% added rneuCopoCell lfeng Sun Jun  1 19:51:54 SGT 2014                             %
% added realresnorm for 1st iteration lfeng Wed Jan 21 10:46:40 SGT 2015            %
% added rms misfit lfeng Wed Jan 21 10:47:24 SGT 2015                               %
% added rneuMegaPost for postseismic only on megathrust lfeng Thu Apr  9 SGT 2015   %
% last modfied by Lujia Feng Thu Apr  9 11:55:07 SGT 2015                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set options
parNum  = 100;
tol     = 1e-15;
% user-defined Jacobian behaves worse then finite-difference Jacobian
% so use default MATLAB calculated Jacobian
options = optimset('MaxFunEvals',250*parNum,'MaxIter',5000,'TolFun',tol,'TolX',tol,...
                   'Jacobian','off','DerivativeCheck','off','FunValCheck','on',...
                   'Diagnostics','off','Display','final-detailed');

% initial values & bounds
[ x0,lb,ub ] = GPS_lsqnonlin_1site_prep(rneu,fitsum);

itnum   = 0;
tt0     = []; % time reference point
rneuOut = []; % outliers
eqMat   = fitsum.eqMat;
funcMat = fitsum.funcMat;
fqMat   = fitsum.fqMat;
modsum.uqMat   = unique(eqMat,'rows','stable'); % each EQ has 1 entry
modsum.rneuRaw = rneu;
% iterative non-linear inversion
tic
while(1)
   itnum = itnum + 1;
   fprintf(1,'nonlinear inversion iteration: %d\n',itnum);
   % lsqnonlin can take care of NaN values in rneu
   if strcmpi(boundsFlag,'yes')
      [ xx,resnorm,residual,exitflag,output,lambda,jacob ] = ...
      lsqnonlin(@(xx) GPS_lsqnonlin_1site(rneu,eqMat,funcMat,fqMat,xx,tt0),x0,lb,ub,options);
   elseif strcmpi(boundsFlag,'no')
      [ xx,resnorm,residual,exitflag,output,lambda,jacob ] = ...
      lsqnonlin(@(xx) GPS_lsqnonlin_1site(rneu,eqMat,funcMat,fqMat,xx,tt0),x0,[],[],options);
   else
      error('GPS_fitrneu_1site ERROR: boundsFlag must be either yes or no!');
   end
   
   % check exit condition
   % if exitflag~=1, error('GPS_fitrneu_1site ERROR: do not converge!'); end
   
   % calculate prediction using xx
   [ rneuModel,rneuRate,rneuSeason ] = GPS_lsqnonlin_1site_calc(rneu,eqMat,funcMat,fqMat,xx,tt0);

   % calculate residuals
   rneuRes = rneu;
   rneuRes(:,3:5) = rneu(:,3:5)-rneuModel(:,3:5);

   % calculate squared 2-norm of the residual, not weighted by errors, need to take care of NaN values
   indnn   = ~isnan(rneuRes(:,3));
   indee   = ~isnan(rneuRes(:,4));
   induu   = ~isnan(rneuRes(:,5));
   realresnormN = sum((rneu(indnn,3)-rneuModel(indnn,3)).^2);
   realresnormE = sum((rneu(indee,4)-rneuModel(indee,4)).^2);
   realresnormU = sum((rneu(induu,5)-rneuModel(induu,5)).^2);
   realresnorm1 = realresnormN + realresnormE + realresnormU;
   % calculate RMS misfit, need to take care of NaN values
   dayNum  = size(rneuRes,1);
   nanNumN = sum(isnan(rneuRes(:,3)));
   nanNumE = sum(isnan(rneuRes(:,4)));
   nanNumU = sum(isnan(rneuRes(:,5)));
   pntNumN = dayNum-nanNumN;
   pntNumE = dayNum-nanNumE;
   pntNumU = dayNum-nanNumU;
   pntNum1 = pntNumN + pntNumE + pntNumU;
   lsqsum.realrmsN1 = sqrt(realresnormN/pntNumN); 
   lsqsum.realrmsE1 = sqrt(realresnormE/pntNumE); 
   lsqsum.realrmsU1 = sqrt(realresnormU/pntNumU); 
   lsqsum.realrms1  = sqrt(realresnorm1/pntNum1);

   % (1) detect outliers using constant ratio
   %----[ ~,rneuKeep,rneuOut ] = GPS_lsqnonlin_1site_outlier_ratio(rneu,rneuModel,rneuOut,xx);
   %----if ~isempty(rneuKeep) % has outliers
   %----    modsum.rneuUsed = rneuKeep; 
   %----    modsum.rneuOut  = rneuOut;
   %----    rneu            = rneuKeep;
   %----else
   %----    break;
   %----end

   % (2) do not remove outliers
   if itnum==1 % cannot use Chauvenet Criterion twice
      modsum.rneuUsed = rneu; 
      modsum.rneuOut  = []; 
      break; 
   end

   % (2) detect outliers using Chauvenet Criterion
   %-----if itnum>=2, break; end
   %-----if itnum==1 % cannot use Chauvenet Criterion twice
   %-----   [ indKeep,indRem ] = GPS_lsqnonlin_1site_outlier_Chauvenet(rneuRes);
   %-----   if any(indRem) % has outliers
   %-----      modsum.rneuUsed = rneu(indKeep,:); 
   %-----      modsum.rneuOut  = rneu(indRem,:);
   %-----      rneu            = rneu(indKeep,:);
   %-----   else % no outliers
   %-----      modsum.rneuUsed = rneu; 
   %-----      modsum.rneuOut  = []; 
   %-----      break; 
   %-----   end
   %-----end
end
toc


% lsqsum
lsqsum.site       = fitsum.site;        % site name
lsqsum.daynum     = size(rneu,1);       % number of days used
lsqsum.xx         = xx;                 % solution                                            
lsqsum.resnorm    = resnorm;            % chi2; rchi2 = chi2/dof                                                
lsqsum.residual   = residual;           % the value of the residual fun(x) at the solution xx
lsqsum.exitflag   = exitflag;           % exit condition                                     
lsqsum.output     = output;             % a structure that contains optimization information 
lsqsum.lambda     = lambda;             % Lagrange multipliers at the solution xx            
lsqsum.jacob      = jacob;              % the Jacobian of fun(x) at the solution xx          
% ----------------------------------------------------------------------------------------
% chi2 p-value test Ref: Aster et al. Parameter Estimation and Inverse Problems P19-20
% only valid for normal distribution with known standard deviations
% small p may suggest incorrect models, acceptable low values e.g., 10e-2
% large p may suggest overestimated errors
% 0.7 is not better than 0.2
% ----------------------------------------------------------------------------------------
%dof = lsqsum.daynum*3-length(lsqsum.xx);
%pvalue = 1-chi2cdf(resnorm,dof);
%fprintf(1,'p-value is %12.6e\n\n',pvalue);

% remove background rates from raw time series
[ rneuNrate ] = GPS_lsqnonlin_1site_detrend(rneu,xx,tt0);

% remove all offsets from raw time series
[ rneuNoff ] = GPS_lsqnonlin_1site_remoffsets(rneu,eqMat,funcMat,fqMat,xx);

% keep only offsets in raw time series
[ rneuOoff ] = GPS_lsqnonlin_1site_offset(rneu,eqMat,funcMat,fqMat,xx,tt0);

% keep only small offsets in raw time series
[ rneuSoff ] = GPS_lsqnonlin_1site_offlim(rneu,eqMat,funcMat,fqMat,xx,tt0,0.02);

% keep postseismic & seasonal signals
[ rneuPostSC ] = GPS_lsqnonlin_1site_postSinCos(rneu,eqMat,funcMat,fqMat,xx,tt0);

% only keep postseismic deformation of all EQs
[ rneuPostEQs,rneuMegaPostEQs ] = GPS_lsqnonlin_1site_postEQs(rneu,eqMat,funcMat,fqMat,xx,tt0);

% postseismic deformation of individual EQs
[ rneuCopoCell,rneuPostCell,rneuPostNdiffCell,rneuAfterCell ] = GPS_lsqnonlin_1site_post(rneu,eqMat,funcMat,fqMat,xx,tt0);

% modsum
modsum.rneuModel         = rneuModel;         % model prediction
modsum.rneuRate          = rneuRate;          % keep only rates
modsum.rneuSeason        = rneuSeason;        % seasonal signals
modsum.rneuRes           = rneuRes;           % residuals
modsum.rneuNrate         = rneuNrate;         % remove rates
modsum.rneuNoff          = rneuNoff;          % remove offsets
modsum.rneuOoff          = rneuOoff;          % keep only offsets
modsum.rneuSoff          = rneuSoff;          % keep only small offsets
modsum.rneuPostSC        = rneuPostSC;        % postseismic & seasonal signals
modsum.rneuPostEQs       = rneuPostEQs;       % all postseismic only
modsum.rneuMegaPostEQs   = rneuMegaPostEQs;   % all megathrust postseismic only
modsum.rneuCopoCell      = rneuCopoCell;      % coseismic & postseismic for individual EQ with diffrate
modsum.rneuPostCell      = rneuPostCell;      % postseismic for individual EQ with diffrate
modsum.rneuPostNdiffCell = rneuPostNdiffCell; % postseismic for individual EQ without diffrate
modsum.rneuAfterCell     = rneuAfterCell;     % deformation after coseismic of one EQ

tic
% calculate squared 2-norm of the residual, not weighted by errors, need to take care of NaN values
indnn   = ~isnan(rneuRes(:,3));
indee   = ~isnan(rneuRes(:,4));
induu   = ~isnan(rneuRes(:,5));
realresnormN = sum((rneu(indnn,3)-rneuModel(indnn,3)).^2);
realresnormE = sum((rneu(indee,4)-rneuModel(indee,4)).^2);
realresnormU = sum((rneu(induu,5)-rneuModel(induu,5)).^2);
lsqsum.realresnorm = realresnormN + realresnormE + realresnormU;
% calculate RMS misfit, need to take care of NaN values
dayNum  = size(rneuRes,1);
nanNumN = sum(isnan(rneuRes(:,3)));
nanNumE = sum(isnan(rneuRes(:,4)));
nanNumU = sum(isnan(rneuRes(:,5)));
pntNumN = dayNum-nanNumN;
pntNumE = dayNum-nanNumE;
pntNumU = dayNum-nanNumU;
pntNum  = pntNumN + pntNumE + pntNumU;
lsqsum.realrmsN = sqrt(realresnormN/pntNumN); 
lsqsum.realrmsE = sqrt(realresnormE/pntNumE); 
lsqsum.realrmsU = sqrt(realresnormU/pntNumU); 
lsqsum.realrms  = sqrt(lsqsum.realresnorm/pntNum);


if cases == 0
   % calculate errors using nonlinear Jacobian
   [ lsqsum ] = GPS_lsqnonlin_1site_errors(rneuRes,lsqsum,noisum);
else
   % calculate errors using Monte Carlo error propagation
   [ lsqsum ] = GPS_lsqnonlin_1site_MCerrors(rneuModel,fitsum,lsqsum,noisum,boundsFlag,cases);
end
toc

% update fitsum
[ fitsum ] = GPS_lsqnonlin_1site_update(rneu,fitsum,xx,lsqsum.xxStd);
