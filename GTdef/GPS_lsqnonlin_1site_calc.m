function [ rneuModel,rneuRate,rneuSeason ] = GPS_lsqnonlin_1site_calc(rneu,eqMat,funcMat,fqMat,xx,tt0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        GPS_lsqnonlin_1site_calc                             %
% calculate the predicted time series according to the values of xx           %
%                                                                             %
% INPUT:                                                                      %
% rneu    - a datNum*8 matrix to store data                                   %
%         = [ YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err ]          %
% eqMat   = [ Deq Teq ]                 (eqNum*2)                             %
%         = [] means no earthquake removed                                    %
% funcMat - a string matrix for function names                                %
%         = [ funcN funcE funcU ]       (eqNum*3*funcLen)                     %
% funcLen = 20                                                                %
% fqMat   - frequency in 1/year                                               %
%         = [ fqSin fqCos ]             (fqNum*2)                             %
%         = [] means no seasonal signals removed                              %
% xx      - unknown parameters that need to be estimated                      %
% tt0     - time reference point                                              %
%         = [] means using the first point as reference                       %
%                                                                             %
% Examples for function names:                                                %
% off = off_samerate; off_diffrate                                            %
% log_samerate, log_diffrate, exp_samerate, exp_diffrate                      %
% k05_samerate, k05_diffrate use the same tau for N, E, and U                 %
% log_samerate_tau1 = log_tau1_samerate, log_tau2                             %
% lg2 = lg2_samerate without offset (must be after log)                       %
% ln2 = ln2_samerate without offset (must be after lng)                       %
% ep2 = ep2_samerate without offset (must be after exp)                       %
%                                                                             %
% OUTPUT:                                                                     %
% rneuModel  - model prediction (errors are kept the same)                    %
% rneuRate   - modelled linear rates                                          %
% rneuSeason - modelled seasonal signals                                      %
%                                                                             %
% first created by Lujia Feng Thu Jul 12 11:20:48 SGT 2012                    %
% different fittypes for NEU lfeng Mon Jul 16 17:57:18 SGT 2012               %
% added generalized rate-strengthening lfeng Tue Jul 17 SGT 2012              %
% corrected rate change mistake lfeng Mon Aug  6 04:35:21 SGT 2012            %
% added seasonal cycles lfeng Sat Oct 27 05:35:57 SGT 2012                    %
% modified funcMat lfeng Thu Apr  4 14:43:00 SGT 2013                         %
% added rneuRate & rneuModel lfeng Mon May 13 17:31:01 SGT 2013               %
% added time reference tt0 lfeng Wed Jan  8 12:58:10 SGT 2014                 %
% added lg2 ep2 & corrected regexpi lfeng Wed Mar  5 11:21:08 SGT 2014        %
% added natural log lng lfeng Wed Jul  2 11:59:18 SGT 2014                    %
% added 2nd natural log ln2 lfeng Wed Jul  2 18:27:02 SGT 2014                %
% corrected tau when N is offset while E is log lfeng Sun Jul 13 SGT 2014     %
% last modified by Lujia Feng Sun Jul 13 11:30:34 SGT 2014                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(tt0)
    % time reference to the 1st observation point
    tt = rneu(:,2) - rneu(1,2);
    if ~isempty(eqMat)
        TeqMat = eqMat(:,2) - rneu(1,2);
    end
else
    % time reference to a given point
    tt = rneu(:,2) - tt0;
    if ~isempty(eqMat)
        TeqMat = eqMat(:,2) - tt0;
    end
end

%nn = rneu(:,3); nnErr = rneu(:,6);
%ee = rneu(:,4); eeErr = rneu(:,7);
%uu = rneu(:,5); uuErr = rneu(:,8);

% base model = intercept + rate*time
xx1st = 0; 
nnRate  = xx(xx1st+2)*tt;
eeRate  = xx(xx1st+4)*tt; 
uuRate  = xx(xx1st+6)*tt; 
nnModel = xx(xx1st+1) + nnRate;
eeModel = xx(xx1st+3) + eeRate;
uuModel = xx(xx1st+5) + uuRate;

% seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
xx1st = 6; 
if any(fqMat)
    nnSeason = 0; eeSeason = 0; uuSeason = 0;
    fqNum = size(fqMat,1);
    for ii=1:fqNum
        fSin = sin(2*pi*fqMat(ii,1).*tt); fCos = cos(2*pi*fqMat(ii,2).*tt);
        nnSeason = nnSeason + xx(xx1st+1)*fSin + xx(xx1st+2)*fCos;
        eeSeason = eeSeason + xx(xx1st+3)*fSin + xx(xx1st+4)*fCos;
        uuSeason = uuSeason + xx(xx1st+5)*fSin + xx(xx1st+6)*fCos;
        xx1st = xx1st+6;
    end
    nnModel = nnModel + nnSeason;
    eeModel = eeModel + eeSeason;
    uuModel = uuModel + uuSeason;
end
xxend = xx1st;

% loop through earthquakes
eqNum = size(eqMat,1);
for jj=1:eqNum
    Teq  = TeqMat(jj);
    ind2 = tt>=Teq;
    func = funcMat(jj,:);
    ff   = reshape(func,[],3)';
    funcN = ff(1,:); funcE = ff(2,:); funcU = ff(3,:);
    % add rate changes
    if strfind(funcN,'diffrate')
        xxend = xxend+1; nndV = xx(xxend);
        nnModel(ind2) = nnModel(ind2)+nndV*(tt(ind2)-Teq);
    end
    if strfind(funcE,'diffrate')
        xxend = xxend+1; eedV = xx(xxend);
        eeModel(ind2) = eeModel(ind2)+eedV*(tt(ind2)-Teq);
    end
    if strfind(funcU,'diffrate')
        xxend = xxend+1; uudV = xx(xxend);
        uuModel(ind2) = uuModel(ind2)+uudV*(tt(ind2)-Teq);
    end
    % add offsets
    if ~isempty(regexpi(funcN,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
        xxend = xxend+1; nnO = xx(xxend);
        nnModel(ind2) = nnModel(ind2) + nnO;
    end
    if ~isempty(regexpi(funcE,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
        xxend = xxend+1; eeO = xx(xxend);
        eeModel(ind2) = eeModel(ind2) + eeO;
    end
    if ~isempty(regexpi(funcU,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
        xxend = xxend+1; uuO = xx(xxend);
        uuModel(ind2) = uuModel(ind2) + uuO;
    end
    % add log changes
    if ~isempty(regexpi(func,'(log|lng|lg2|ln2)'))
	ntauName = ''; etauName = ''; utauName = '';
        if ~isempty(regexpi(funcN,'(log|lng|lg2|ln2)'))
	    ntauName = 'tau'; 
            % check tau
            ntauInd = strfind(funcN,'tau');
            if ntauInd
               ntauName   = funcN(ntauInd:ntauInd+3);
            end
            xxend = xxend+1; nntau = xx(xxend);
            xxend = xxend+1; nnaa  = xx(xxend);
            if strfind(funcN,'ln');
               nnModel(ind2) = nnModel(ind2)+nnaa*log(1+(tt(ind2)-Teq)/nntau); 
            else
               nnModel(ind2) = nnModel(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/nntau); 
            end
        end
        if ~isempty(regexpi(funcE,'(log|lng|lg2|ln2)'))
            etauName = 'tau'; 
            % check tau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName   = funcE(etauInd:etauInd+3);
            end
            if strcmp(etauName,ntauName)
               eetau  = nntau;
            else
               xxend  = xxend+1; eetau  = xx(xxend);
            end
            xxend = xxend+1; eeaa = xx(xxend);
            if strfind(funcE,'ln');
               eeModel(ind2) = eeModel(ind2)+eeaa*log(1+(tt(ind2)-Teq)/eetau);
            else
               eeModel(ind2) = eeModel(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/eetau);
            end
        end
        if ~isempty(regexpi(funcU,'(log|lng|lg2|ln2)'))
            utauName = 'tau';
            % check tau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName   = funcU(utauInd:utauInd+3);
            end
            if strcmp(utauName,ntauName)
               uutau  = nntau;
            elseif strcmp(utauName,etauName)
               uutau  = eetau;
            else
               xxend  = xxend+1; uutau  = xx(xxend);
            end
            xxend = xxend+1; uuaa = xx(xxend);
            if strfind(funcU,'ln');
               uuModel(ind2) = uuModel(ind2)+uuaa*log(1+(tt(ind2)-Teq)/uutau); 
            else
               uuModel(ind2) = uuModel(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/uutau); 
            end
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
               ntauName   = funcN(ntauInd:ntauInd+3);
            end
            xxend = xxend+1; nntau = xx(xxend);
            xxend = xxend+1; nnaa  = xx(xxend);
            nnModel(ind2) = nnModel(ind2)+nnaa*(1-exp((Teq-tt(ind2))/nntau));
        end
        if ~isempty(regexpi(funcE,'(exp|ep2)'))
            etauName = 'tau'; 
            % check tau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName   = funcE(etauInd:etauInd+3);
            end
            if strcmp(etauName,ntauName)
               eetau  = nntau;
            else
               xxend  = xxend+1; eetau  = xx(xxend);
            end
            xxend = xxend+1; eeaa = xx(xxend);
            eeModel(ind2) = eeModel(ind2)+eeaa*(1-exp((Teq-tt(ind2))/eetau));
        end
        if ~isempty(regexpi(funcU,'(exp|ep2)'))
            utauName = 'tau';
            % check tau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName   = funcU(utauInd:utauInd+3);
            end
            if strcmp(utauName,ntauName)
               uutau  = nntau;
            elseif strcmp(utauName,etauName)
               uutau  = eetau;
            else
               xxend  = xxend+1; uutau  = xx(xxend);
            end
            xxend = xxend+1; uuaa = xx(xxend);
            uuModel(ind2) = uuModel(ind2)+uuaa*(1-exp((Teq-tt(ind2))/uutau));
        end
    end
    % add generalized rate-strengthening
    if regexpi(func,'k[0-9]{2}_\w+')
        kk = str2double(func(2:3));
	ntauName = ''; etauName = ''; utauName = '';
        if regexpi(funcN,'k[0-9]{2}_\w+')
	    ntauName = 'tau'; 
            % check tau
            ntauInd = strfind(funcN,'tau');
            if ntauInd
               ntauName   = funcN(ntauInd:ntauInd+3);
            end
            xxend = xxend+1; nntau = xx(xxend);
            xxend = xxend+1; nnaa  = xx(xxend);
            nnModel(ind2) = nnModel(ind2)+nnaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/nntau)));
        end
        if regexpi(funcE,'k[0-9]{2}_\w+')
            etauName = 'tau'; 
            % check tau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName   = funcE(etauInd:etauInd+3);
            end
            if strcmp(etauName,ntauName)
               eetau  = nntau;
            else
               xxend  = xxend+1; eetau  = xx(xxend);
            end
            xxend = xxend+1; eeaa = xx(xxend);
            eeModel(ind2) = eeModel(ind2)+eeaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/eetau)));
        end
        if regexpi(funcU,'k[0-9]{2}_\w+')
            utauName = 'tau';
            % check tau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName   = funcU(utauInd:utauInd+3);
            end
            if strcmp(utauName,ntauName)
               uutau  = nntau;
            elseif strcmp(utauName,etauName)
               uutau  = eetau;
            else
               xxend  = xxend+1; uutau  = xx(xxend);
            end
            xxend = xxend+1; uuaa = xx(xxend);
            uuModel(ind2) = uuModel(ind2)+uuaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/uutau)));
        end
    end
end

rneuModel  = rneu;
rneuRate   = rneu;
rneuSeason = [];
rneuModel(:,3:5)  = [ nnModel  eeModel  uuModel  ];
rneuRate(:,3:5)   = [ nnRate   eeRate   uuRate   ];

if any(fqMat)
   rneuSeason = rneu;
   rneuSeason(:,3:5) = [ nnSeason eeSeason uuSeason ];
end
