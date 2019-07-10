function [ ] = GPS_fitrneu_1site_bootstrap(rneu,fitsum,noisum,boundsFlag,btnum,basename,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              GPS_fitrneu_1site_bootstrap.m                        %
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
% btnum      - number of bootstrap sampling                                         %
% basename   - basename for output files                                            %
% scaleOut   - scale to meter in output rneu, fitsum files                          %
%              scaleOut cannot be []                                                %
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
% modified based on GPS_fitrneu_1site.m Lujia Feng Thu Feb 19 15:07:08 SGT 2015     %
% reduced the number of output files lfeng Fri Feb 20 20:39:39 SGT 2015             %
% last modfied by Lujia Feng Sat Feb 21 00:14:16 SGT 2015                           %
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

tt0     = []; % time reference point
rneuOut = []; % outliers
eqMat   = fitsum.eqMat;
funcMat = fitsum.funcMat;
fqMat   = fitsum.fqMat;
modsum.uqMat   = unique(eqMat,'rows','stable'); % each EQ has 1 entry
modsum.rneuRaw = rneu;
dayNum   = size(rneu,1);
siteName = fitsum.site;

% non-linear inversion
% lsqnonlin can take care of NaN values in rneu
tic
if strcmpi(boundsFlag,'yes')
   [ xx,resnorm,residual,exitflag,output,lambda,jacob ] = ...
   lsqnonlin(@(xx) GPS_lsqnonlin_1site(rneu,eqMat,funcMat,fqMat,xx,tt0),x0,lb,ub,options);
elseif strcmpi(boundsFlag,'no')
   [ xx,resnorm,residual,exitflag,output,lambda,jacob ] = ...
   lsqnonlin(@(xx) GPS_lsqnonlin_1site(rneu,eqMat,funcMat,fqMat,xx,tt0),x0,[],[],options);
else
   error('GPS_fitrneu_1site_bootstrap ERROR: boundsFlag must be either yes or no!');
end
toc
   
% check exit condition
% if exitflag~=1, error('GPS_fitrneu_1site_bootstrap ERROR: do not converge!'); end
   
% calculate prediction using xx
[ rneuModel,~,~ ] = GPS_lsqnonlin_1site_calc(rneu,eqMat,funcMat,fqMat,xx,tt0);

% calculate residuals
rneuBTRes = rneu;
rneuBTRes(:,3:5)   = rneu(:,3:5)-rneuModel(:,3:5);
rneuBTRes(:,1:2)   = 0;
rneuBTRes(:,6:end) = 0;
rneuBTModel = rneuModel;

allNamesStruct = dir([siteName '/' siteName '*.fitsum']);
if ~isempty(allNamesStruct)
    % find the last file and redo the last one
    lastName   = allNamesStruct(end).name;
    btstartStr = lastName(isstrprop(lastName,'digit'));
    btstart    = str2num(btstartStr);
    fprintf(1,'\nBootstrap sampling continues from: %d\n',btstart);
else
    btstart = 1;
    fprintf(1,'\nBootstrap sampling starts from: %d\n',btstart);
end

for ii=btstart:btnum
    % bootstrap sampling
    bname  = [ basename '_' num2str(ii,'%08d') ];
    fprintf(1,'\nBootstrap Sampling %d: %s\n',ii,bname);
    bname  = [ siteName '/' bname  ];
    ddRand = round(rand(dayNum,1));
    rneu = rneuBTModel+bsxfun(@times,rneuBTRes,ddRand);

    tic
    if strcmpi(boundsFlag,'yes')
       [ xx,resnorm,residual,exitflag,output,lambda,jacob ] = ...
       lsqnonlin(@(xx) GPS_lsqnonlin_1site(rneu,eqMat,funcMat,fqMat,xx,tt0),x0,lb,ub,options);
    elseif strcmpi(boundsFlag,'no')
       [ xx,resnorm,residual,exitflag,output,lambda,jacob ] = ...
       lsqnonlin(@(xx) GPS_lsqnonlin_1site(rneu,eqMat,funcMat,fqMat,xx,tt0),x0,[],[],options);
    else
       error('GPS_fitrneu_1site_bootstrap ERROR: boundsFlag must be either yes or no!');
    end
    toc
    
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
    lsqsum.realresnorm = realresnormN + realresnormE + realresnormU;
    % calculate RMS misfit, need to take care of NaN values
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
    lsqsum.realrmsN1 = lsqsum.realrmsN;
    lsqsum.realrmsE1 = lsqsum.realrmsE;
    lsqsum.realrmsU1 = lsqsum.realrmsU;
    lsqsum.realrms1  = lsqsum.realrms;
    lsqsum.site       = siteName;           % site name
    lsqsum.daynum     = size(rneu,1);       % number of days used
    lsqsum.xx         = xx;                 % solution                                            
    lsqsum.resnorm    = resnorm;            % chi2; rchi2 = chi2/dof                                                
    lsqsum.residual   = residual;           % the value of the residual fun(x) at the solution xx
    lsqsum.exitflag   = exitflag;           % exit condition                                     
    lsqsum.output     = output;             % a structure that contains optimization information 
    lsqsum.lambda     = lambda;             % Lagrange multipliers at the solution xx            
    lsqsum.jacob      = jacob;              % the Jacobian of fun(x) at the solution xx          

    % calculate errors using nonlinear Jacobian
    [ lsqsum ] = GPS_lsqnonlin_1site_errors(rneuRes,lsqsum,noisum);

    % update fitsum
    [ fitsum ] = GPS_lsqnonlin_1site_update(rneu,fitsum,xx,lsqsum.xxStd);

    %--------------------- save fitsum ---------------------%
    foutName  = [ bname '.fitsum' ];
    GPS_savefitsum(foutName,fitsum,lsqsum,scaleOut);
    
    % only keep postseismic deformation of all EQs
    [ rneuPostEQs,~ ] = GPS_lsqnonlin_1site_postEQs(rneu,eqMat,funcMat,fqMat,xx,tt0);
    
    % postseismic deformation of individual EQs
    [ rneuCopoCell,rneuPostCell,rneuPostNdiffCell,rneuAfterCell ] = GPS_lsqnonlin_1site_post(rneu,eqMat,funcMat,fqMat,xx,tt0);
    
    %--------------------- output results ---------------------%
    foutName = [ bname '.rneu' ];                     % bootstrap sample data
    GPS_saverneu(foutName,'w',rneu,scaleOut);
    foutName = [ bname '_res1site.rneu' ];            % residuals
    GPS_saverneu(foutName,'w',rneuRes,scaleOut);
    foutName = [ bname '_mod1site.rneu' ];            % model prediction
    GPS_saverneu(foutName,'w',rneuModel,scaleOut);
    %foutName = [ bname '_postEQs1site.rneu' ];       % postseismic deformation only
    %GPS_saverneu(foutName,'w',rneuPostEQs,scaleOut);
    % data with only postseismic deformation
    eqNum = size(modsum.uqMat,1);
    for jj=1:eqNum
        rneuCopo = rneuCopoCell{jj};
        if ~isempty(rneuCopo)
            eqName = num2str(modsum.uqMat(jj,1),'%8.0f');
            foutName = [ bname '_EQ' eqName 'copo.rneu' ];       
            GPS_saverneu(foutName,'w',rneuCopo,scaleOut);
        end
        rneuPost = rneuPostCell{jj};
        if ~isempty(rneuPost)
            eqName = num2str(modsum.uqMat(jj,1),'%8.0f');
            foutName = [ bname '_EQ' eqName 'po.rneu' ];       
            GPS_saverneu(foutName,'w',rneuPost,scaleOut);
        end
        %rneuPostNdiff = rneuPostNdiffCell{jj};
        %rneuAfter = rneuAfterCell{jj};
        %if ~isempty(rneuAfter)
        %    eqName = num2str(modsum.uqMat(jj,1),'%8.0f');
        %    foutName = [ bname '_postEQ' eqName '.rneu' ];       
        %    GPS_saverneu(foutName,'w',rneuAfter,scaleOut);
        %end
    end
end
