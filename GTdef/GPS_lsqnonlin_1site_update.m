function [ fitsum ] = GPS_lsqnonlin_1site_update(rneu,fitsum,xx,xxStd)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_lsqnonlin_1site_update                              %
% update fitsum struct with solution xx                                             %
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
% xx       - solutions  (1*xxNum)                                                   %
% xxStd    - standard deviation of solutions                                        %
% --------------------------------------------------------------------------------- %
%                                                                                   %
% OUTPUT:                                                                           %
% an updated fitsum struct                                                          %
%                                                                                   %
% first created by Lujia Feng Mon Dec  2 12:46:49 SGT 2013                          %
% added lg2 ep2 & corrected regexpi lfeng Wed Mar  5 11:21:08 SGT 2014              %
% added natural log lng lfeng Wed Jul  2 11:59:18 SGT 2014                          %
% added 2nd natural log ln2 lfeng Wed Jul  2 18:27:02 SGT 2014                      %
% corrected tau when N is offset while E is log lfeng Sun Jul 13 12:06:19 SGT 2014  %
% last modified by Lujia Feng Sun Jul 13 12:07:21 SGT 2014                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% period for all data
Tstart   = rneu(1,2);
Tend     = rneu(end,2);

%----------------------- basic linear info -----------------------
% base model = intercept + rate
nnb    = xx(1); nnbErr    = xxStd(1); 
nnRate = xx(2); nnRateErr = xxStd(2);
eeb    = xx(3); eebErr    = xxStd(3); 
eeRate = xx(4); eeRateErr = xxStd(4);
uub    = xx(5); uubErr    = xxStd(5); 
uuRate = xx(6); uuRateErr = xxStd(6);
fitsum.rateRow = [ Tstart Tend nnb nnRate eeb eeRate uub uuRate nnbErr nnRateErr eebErr eeRateErr uubErr uuRateErr ];

%----------------------- seasonal info -----------------------
xx1st = 6;
if any(fitsum.fqMat)
    % seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
    fqNum = size(fitsum.fqMat,1);
    for ii=1:fqNum
        fqS = fitsum.fqMat(ii,1); 
	fqC = fitsum.fqMat(ii,2);
        nnS = xx(xx1st+1); nnSErr = xxStd(xx1st+1); 
        nnC = xx(xx1st+2); nnCErr = xxStd(xx1st+2);
        eeS = xx(xx1st+3); eeSErr = xxStd(xx1st+3); 
        eeC = xx(xx1st+4); eeCErr = xxStd(xx1st+4);
        uuS = xx(xx1st+5); uuSErr = xxStd(xx1st+5); 
        uuC = xx(xx1st+6); uuCErr = xxStd(xx1st+6);
        fitsum.ampMat(ii,:) = [ Tstart Tend nnS nnC eeS eeC uuS uuC nnSErr nnCErr eeSErr eeCErr uuSErr uuCErr ];
        xx1st = xx1st+6;
    end
end
xxend = xx1st;

%----------------------- each earthquake -----------------------
nnv1 = nnRate; eev1 = eeRate; uuv1 = uuRate;
eqNum = size(fitsum.eqMat,1);
for jj=1:eqNum
    func = fitsum.funcMat(jj,:);
    ff   = reshape(func,[],3)';
    funcN = ff(1,:); funcE = ff(2,:); funcU = ff(3,:);
    % initialization
    nndV  = 0.0; eedV  = 0.0; uudV  = 0.0;
    nnO   = 0.0; eeO   = 0.0; uuO   = 0.0;
    nnaa  = 0.0; eeaa  = 0.0; uuaa  = 0.0; 
    nntau = 0.0; eetau = 0.0; uutau = 0.0;
    nndVErr  = 0.0; eedVErr  = 0.0; uudVErr  = 0.0;
    nnOErr   = 0.0; eeOErr   = 0.0; uuOErr   = 0.0;
    nnaaErr  = 0.0; eeaaErr  = 0.0; uuaaErr  = 0.0;
    nntauErr = 0.0; eetauErr = 0.0; uutauErr = 0.0;
    % add rate changes
    if strfind(funcN,'diffrate')
        xxend = xxend+1; nndV = xx(xxend); nndVErr = xxStd(xxend);
    end
    if strfind(funcE,'diffrate')
        xxend = xxend+1; eedV = xx(xxend); eedVErr = xxStd(xxend);
    end
    if strfind(funcU,'diffrate')
        xxend = xxend+1; uudV = xx(xxend); uudVErr = xxStd(xxend);
    end
    % add offsets
    if ~isempty(regexpi(funcN,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
        xxend = xxend+1; nnO = xx(xxend); nnOErr = xxStd(xxend);
    end
    if ~isempty(regexpi(funcE,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
        xxend = xxend+1; eeO = xx(xxend); eeOErr = xxStd(xxend);
    end
    if ~isempty(regexpi(funcU,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
        xxend = xxend+1; uuO = xx(xxend); uuOErr = xxStd(xxend);
    end
    % add log or exp or hyperbolic changes
    if ~isempty(regexpi(func,'(log|lg2|lng|ln2|exp|ep2)')) || ~isempty(regexpi(func,'k[0-9]{2}_\w+'))
        ntauName = ''; etauName = ''; utauName = '';
        if ~isempty(regexpi(funcN,'(log|lg2|lng|ln2|exp|ep2)')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
            ntauName = 'tau'; 
            % check tau
            ntauInd = strfind(funcN,'tau');
            if ntauInd
                ntauName = funcN(ntauInd:ntauInd+3);
            end
            xxend = xxend+1; nntau = xx(xxend); nntauErr = xxStd(xxend);
            xxend = xxend+1; nnaa  = xx(xxend);  nnaaErr = xxStd(xxend);
        end
        if ~isempty(regexpi(funcE,'(log|lg2|lng|ln2|exp|ep2)')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
            etauName = 'tau'; 
            % check tau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName = funcE(etauInd:etauInd+3);
            end
            if strcmp(etauName,ntauName)
               eetau = nntau; eetauErr = nntauErr;
            else
               xxend = xxend+1; eetau = xx(xxend); eetauErr = xxStd(xxend);
            end
            xxend = xxend+1; eeaa = xx(xxend); eeaaErr = xxStd(xxend);
        end
        if ~isempty(regexpi(funcU,'(log|lg2|lng|ln2|exp|ep2)')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
            utauName = 'tau';
            % check tau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName   = funcU(utauInd:utauInd+3);
            end
            if strcmp(utauName,ntauName)
               uutau = nntau; uutauErr = nntauErr;
            elseif strcmp(utauName,etauName)
               uutau = eetau; uutauErr = eetauErr;
            else
               xxend = xxend+1; uutau = xx(xxend); uutauErr = xxStd(xxend);
            end
            xxend = xxend+1; uuaa = xx(xxend); uuaaErr = xxStd(xxend);
        end
    end
    nnv2 = nnv1+nndV; eev2 = eev1+eedV; uuv2 = uuv1+uudV;
    fitsum.paramMat(jj,:) = [ 0.0 nnv1 nnv2 nndV nnO nnaa nntau ...
                              0.0 eev1 eev2 eedV eeO eeaa eetau ...
                              0.0 uuv1 uuv2 uudV uuO uuaa uutau ...
                              0.0 0.0  0.0  nndVErr nnOErr nnaaErr nntauErr ...
                              0.0 0.0  0.0  eedVErr eeOErr eeaaErr eetauErr ...
                              0.0 0.0  0.0  uudVErr uuOErr uuaaErr uutauErr ];
    nnv1 = nnv2; eev1 = eev2; uuv1 = uuv2;
end
