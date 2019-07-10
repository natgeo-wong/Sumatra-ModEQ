function [ x0,lb,ub ] = GPS_lsqnonlin_1site_prep(rneu,fitsum)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          GPS_lsqnonlin_1site_prep                                 %
% prepare x0 lb ub for GPS_lsqnonlin_1site.m                                        %
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
%                                                                                   %
% OUTPUT:                                                                           %
% xx - unknown parameters that need to be estimated                                 %
% x0 - initial values for xx                                                        %
% lb - lower bounds for xx                                                          %
% ub - upper bounds for xx                                                          %
%                                                                                   %
% first created by Lujia Feng Wed Jul 11 17:05:28 SGT 2012                          %
% different fittypes for NEU lfeng Mon Jul 16 17:57:18 SGT 2012                     %
% added generalized rate-strengthening lfeng Tue Jul 17 SGT 2012                    %
% added seasonal cycles lfeng Sat Oct 27 04:58:21 SGT 2012                          %
% added ERR lfeng Wed Nov 28 02:26:14 SGT 2012                                      %
% modified funcMat lfeng Thu Apr  4 15:52:52 SGT 2013                               %
% added minmaxMat lfeng Tue Apr  9 01:09:50 SGT 2013                                %
% changed to fitsum struct lfeng Thu Nov 21 17:01:24 SGT 2013                       %
% added lg2 ep2 & corrected regexpi lfeng Wed Mar  5 11:21:08 SGT 2014              %
% added minmaxRow lfeng Mon Mar 17 16:35:31 SGT 2014                                %
% added natural log lng lfeng Wed Jul  2 11:59:18 SGT 2014                          %
% added 2nd natural log ln2 lfeng Wed Jul  2 18:27:02 SGT 2014                      %
% corrected tau when N is offset while E is log Sun Jul 13 11:24:41 SGT 2014        %
% last modified by Lujia Feng Sun Jul 13 11:24:49 SGT 2014                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rateRow   = fitsum.rateRow;
minmaxRow = fitsum.minmaxRow;
eqMat     = fitsum.eqMat;
funcMat   = fitsum.funcMat;
paramMat  = fitsum.paramMat;
minmaxMat = fitsum.minmaxMat;
fqMat     = fitsum.fqMat;
ampMat    = fitsum.ampMat;

% bounds for parameters
x0 = []; lb = []; ub = [];
ratMin = -1;   ratMax = 1;
aaMin  = -100; aaMax  = 100;
tauMin = 0;    tauMax = 1000;
tauMin = 0;    tauMax = 100000;
% data
nn = rneu(:,3); 
ee = rneu(:,4); 
uu = rneu(:,5);
% range for displacements
nnMin = min(nn); nnMax = max(nn); nnRange = nnMax - nnMin;
eeMin = min(ee); eeMax = max(ee); eeRange = eeMax - eeMin;
uuMin = min(uu); uuMax = max(uu); uuRange = uuMax - uuMin;

% base model = intercept + rate*time (N E & U)
if ~isempty(rateRow)
    bbN  = rateRow(1,3); bbE  = rateRow(1,5); bbU  = rateRow(1,7); 
    ratN = rateRow(1,4); ratE = rateRow(1,6); ratU = rateRow(1,8);
elseif ~isempty(eqMat)
    ratN = paramMat(1,2); ratE = paramMat(1,9); ratU = paramMat(1,16);
    bbN  = nn(1); bbE = ee(1); bbU = uu(1);
else
    ratN = 0.1;  ratE = 0.1;  ratU = 0.1;
    bbN  = nn(1); bbE = ee(1); bbU = uu(1);
end
if ~isempty(minmaxRow)
    bbNMin  = minmaxRow(1,3);  bbEMin  = minmaxRow(1,5);  bbUMin  = minmaxRow(1,7); 
    ratNMin = minmaxRow(1,4);  ratEMin = minmaxRow(1,6);  ratUMin = minmaxRow(1,8);
    bbNMax  = minmaxRow(1,9);  bbEMax  = minmaxRow(1,11); bbUMax  = minmaxRow(1,13); 
    ratNMax = minmaxRow(1,10); ratEMax = minmaxRow(1,12); ratUMax = minmaxRow(1,14);
else
    bbNMin  = nnMin;   bbEMin  = eeMin;   bbUMin  = uuMin; 
    bbNMax  = nnMax;   bbEMax  = eeMax;   bbUMax  = uuMax; 
    ratNMin = ratMin;  ratEMin = ratMin;  ratUMin = ratMin;
    ratNMax = ratMax;  ratEMax = ratMax;  ratUMax = ratMax;
end
x0 = [ x0 bbN    ratN    bbE    ratE    bbU    ratU ];
lb = [ lb bbNMin ratNMin bbEMin ratEMin bbUMin ratUMin ];
ub = [ ub bbNMax ratNMax bbEMax ratEMax bbUMax ratUMax ];

% seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
seasonAmp = 0.01;   % should be < 1 cm
if any(fqMat)
    fqNum = size(fqMat,1);
    for ii=1:fqNum
        amp = ampMat(ii,3:8);
        x0  = [ x0 amp ];
        lb  = [ lb -seasonAmp -seasonAmp -seasonAmp -seasonAmp -seasonAmp -seasonAmp ];
        ub  = [ ub  seasonAmp  seasonAmp  seasonAmp  seasonAmp  seasonAmp  seasonAmp ];
    end
end

% loop through earthquakes
eqNum = size(eqMat,1);
for jj=1:eqNum
    func = funcMat(jj,:);
    ff   = reshape(func,[],3)';
    funcN   = ff(1,:); funcE = ff(2,:); funcU = ff(3,:);
    param   = paramMat(jj,:);
    pminmax = minmaxMat(jj,:);
    nndv = param(4);  nnO = param(5);  nnaa = param(6);  nntau = param(7);
    eedv = param(11); eeO = param(12); eeaa = param(13); eetau = param(14);
    uudv = param(18); uuO = param(19); uuaa = param(20); uutau = param(21);
    fstind = 0;
    nndv0 = pminmax(fstind+4);  nnO0 = pminmax(fstind+5);  nnaa0 = pminmax(fstind+6);  nntau0 = pminmax(fstind+7);
    eedv0 = pminmax(fstind+11); eeO0 = pminmax(fstind+12); eeaa0 = pminmax(fstind+13); eetau0 = pminmax(fstind+14);
    uudv0 = pminmax(fstind+18); uuO0 = pminmax(fstind+19); uuaa0 = pminmax(fstind+20); uutau0 = pminmax(fstind+21);
    fstind = 21;
    nndv9 = pminmax(fstind+4);  nnO9 = pminmax(fstind+5);  nnaa9 = pminmax(fstind+6);  nntau9 = pminmax(fstind+7);
    eedv9 = pminmax(fstind+11); eeO9 = pminmax(fstind+12); eeaa9 = pminmax(fstind+13); eetau9 = pminmax(fstind+14);
    uudv9 = pminmax(fstind+18); uuO9 = pminmax(fstind+19); uuaa9 = pminmax(fstind+20); uutau9 = pminmax(fstind+21);
    % add rate change dV
    if strfind(funcN,'diffrate')
        x0 = [ x0 nndv ]; lb = [ lb max(ratMin,nndv0) ]; ub = [ ub min(ratMax,nndv9) ];
    end
    if strfind(funcE,'diffrate')
        x0 = [ x0 eedv ]; lb = [ lb max(ratMin,eedv0) ]; ub = [ ub min(ratMax,eedv9) ];
    end
    if strfind(funcU,'diffrate')
        x0 = [ x0 uudv ]; lb = [ lb max(ratMin,uudv0) ]; ub = [ ub min(ratMax,uudv9) ];
    end
    % add offset O
    if ~isempty(regexpi(funcN,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
        x0 = [ x0  nnO ]; lb = [ lb max(-nnRange,nnO0) ]; ub = [ ub min(nnRange,nnO9) ];
    end
    if ~isempty(regexpi(funcE,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
        x0 = [ x0  eeO ]; lb = [ lb max(-eeRange,eeO0) ]; ub = [ ub min(eeRange,eeO9) ];
    end
    if ~isempty(regexpi(funcU,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
        x0 = [ x0  uuO ]; lb = [ lb max(-uuRange,uuO0) ]; ub = [ ub min(uuRange,uuO9) ];
    end
    % add log changes
    if ~isempty(regexpi(func,'(log|lng|lg2|ln2)'))
        ntauName = ''; etauName = ''; utauName = '';
        if ~isempty(regexpi(funcN,'(log|lng|lg2|ln2)'))
            ntauName = 'tau'; 
            % check tau
            ntauInd = strfind(funcN,'tau');
            if ntauInd
               ntauName = funcN(ntauInd:ntauInd+3);
            end
            x0 = [ x0 nntau ]; lb = [ lb max(tauMin,nntau0) ]; ub = [ ub min(tauMax,nntau9) ];
            x0 = [ x0 nnaa ];  lb = [ lb max(aaMin,nnaa0) ];   ub = [ ub min(aaMax,nnaa9) ];
        end
        if ~isempty(regexpi(funcE,'(log|lng|lg2|ln2)'))
            etauName = 'tau'; 
            % check tau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName = funcE(etauInd:etauInd+3);
            end
            if ~strcmp(etauName,ntauName)
               x0 = [ x0 eetau ]; lb = [ lb max(tauMin,eetau0) ]; ub = [ ub min(tauMax,eetau9) ];
            end
            x0 = [ x0 eeaa ];  lb = [ lb max(aaMin,eeaa0) ];   ub = [ ub min(aaMax,eeaa9) ];
        end
        if ~isempty(regexpi(funcU,'(log|lng|lg2|ln2)'))
            utauName = 'tau';
            % check tau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName = funcU(utauInd:utauInd+3);
            end
            if ~strcmp(utauName,ntauName) && ~strcmp(utauName,etauName)
               x0 = [ x0 uutau ]; lb = [ lb max(tauMin,uutau0) ]; ub = [ ub min(tauMax,uutau9) ];
            end
            x0 = [ x0 uuaa ];  lb = [ lb max(aaMin,uuaa0) ];   ub = [ ub min(aaMax,uuaa9) ];
        end
    end
    % add exp changes
    if ~isempty(regexpi(func,'(exp|ep2)'))
        ntauName = ''; etauName = ''; utauName = '';
        if ~isempty(regexpi(funcN,'(exp|ep2)'))
            ntauName = 'tau'; 
            % check tau
            ntauInd = strfind(funcN,'tau');
            if ntauInd
               ntauName = funcN(ntauInd:ntauInd+3);
            end
            x0 = [ x0 nntau ]; lb = [ lb max(tauMin,nntau0) ]; ub = [ ub min(tauMax,nntau9) ];
            x0 = [ x0 nnaa ];  lb = [ lb max(aaMin,nnaa0) ];   ub = [ ub min(aaMax,nnaa9) ];
        end
        if ~isempty(regexpi(funcE,'(exp|ep2)'))
            etauName = 'tau'; 
            % check tau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName = funcE(etauInd:etauInd+3);
            end
            if ~strcmp(etauName,ntauName)
               x0 = [ x0 eetau ]; lb = [ lb max(tauMin,eetau0) ]; ub = [ ub min(tauMax,eetau9) ];
            end
            x0 = [ x0 eeaa ];  lb = [ lb max(aaMin,eeaa0) ];   ub = [ ub min(aaMax,eeaa9) ];
        end
        if ~isempty(regexpi(funcU,'(exp|ep2)'))
            utauName = 'tau';
            % check tau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName = funcU(utauInd:utauInd+3);
            end
            if ~strcmp(utauName,ntauName) && ~strcmp(utauName,etauName)
               x0 = [ x0 uutau ]; lb = [ lb max(tauMin,uutau0) ]; ub = [ ub min(tauMax,uutau9) ];
            end
            x0 = [ x0 uuaa ];  lb = [ lb max(aaMin,uuaa0) ];   ub = [ ub min(aaMax,uuaa9) ];
        end
    end
    % add hyperbolic changes
    if regexpi(func,'k[0-9]{2}_\w+')
	ntauName = ''; etauName = ''; utauName = '';
        if regexpi(funcN,'k[0-9]{2}_\w+')
	    ntauName = 'tau'; 
	    % check tau
	    ntauInd = strfind(funcN,'tau');
	    if ntauInd
	       ntauName = funcN(ntauInd:ntauInd+3);
	    end
            x0 = [ x0 nntau ]; lb = [ lb max(tauMin,nntau0) ]; ub = [ ub min(tauMax,nntau9) ];
            x0 = [ x0 nnaa ];  lb = [ lb max(aaMin,nnaa0) ];   ub = [ ub min(aaMax,nnaa9) ];
        end
        if regexpi(funcE,'k[0-9]{2}_\w+')
            etauName = 'tau'; 
            % check tau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName = funcE(etauInd:etauInd+3);
            end
            if ~strcmp(etauName,ntauName)
               x0 = [ x0 eetau ]; lb = [ lb max(tauMin,eetau0) ]; ub = [ ub min(tauMax,eetau9) ];
            end
            x0 = [ x0 eeaa ];  lb = [ lb max(aaMin,eeaa0) ];   ub = [ ub min(aaMax,eeaa9) ];
        end
        if regexpi(funcU,'k[0-9]{2}_\w+')
            utauName = 'tau';
            % check tau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName = funcU(utauInd:utauInd+3);
            end
            if ~strcmp(utauName,ntauName) && ~strcmp(utauName,etauName)
               x0 = [ x0 uutau ]; lb = [ lb max(tauMin,uutau0) ]; ub = [ ub min(tauMax,uutau9) ];
            end
            x0 = [ x0 uuaa ];  lb = [ lb max(aaMin,uuaa0) ];   ub = [ ub min(aaMax,uuaa9) ];
        end
    end
end
