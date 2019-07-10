function [ rneuNoff ] = GPS_lsqnonlin_1site_remoffsets(rneu,eqMat,funcMat,fqMat,xx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      GPS_lsqnonlin_1site_remoffsets                         %
% remove all offsets from the time series according to the values of xx       %
%                                                                             %
% INPUT:                                                                      %
% rneu    - data marix (dayNum*8)                                             %
%         = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                       %
% eqMat   = [ Deq Teq ]                 (eqNum*2)                             %
%         = [] means no earthquake removed                                    %
% funcMat - a string matrix for function names                                %
%         = [ funcN funcE funcU ]       (eqNum*3*funcLen)                     %
% funcLen = 20                                                                %
% fqMat   - frequency in 1/year                                               %
%         = [ fqSin fqCos ]             (fqNum*2)                             %
%         = [] means no seasonal signals removed                              %
% xx      - unknown parameters that need to be estimated                      %
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
% rneuNoff - data with all offsets removed                                    %
%            errors are kept the same                                         %
%                                                                             %
% first created by Lujia Feng Fri Jul 27 10:10:18 SGT 2012                    %
% added seasonal cycles lfeng Sat Oct 27 05:42:46 SGT 2012                    %
% modified funcMat lfeng Thu Apr  4 16:05:29 SGT 2013                         %
% added lg2 ep2 & corrected regexpi lfeng Wed Mar  5 11:21:08 SGT 2014        %
% added natural log lng lfeng Wed Jul  2 11:59:18 SGT 2014                    %
% added 2nd natural log ln2 lfeng Wed Jul  2 18:27:02 SGT 2014                %
% corrected tau when N is offset while E is log lfeng Sun Jul 13 SGT 2014     %
% last modified by Lujia Feng Sun Jul 13 12:03:32 SGT 2014                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tt = rneu(:,2);
nn = rneu(:,3);
ee = rneu(:,4);
uu = rneu(:,5);

% base model = intercept + rate*time
xx1st = 0; 
%nnModel = xx(xx1st+1) + xx(xx1st+2)*tt;
%eeModel = xx(xx1st+3) + xx(xx1st+4)*tt;
%uuModel = xx(xx1st+5) + xx(xx1st+6)*tt;

% seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
xx1st = 6; 
if any(fqMat)
    fqNum = size(fqMat,1);
    for ii=1:fqNum
        %fSin = sin(2*pi*fqMat(ii,1).*tt); fCos = cos(2*pi*fqMat(ii,2).*tt);
        %nnModel = nnModel + xx(xx1st+1)*fSin + xx(xx1st+2)*fCos;
        %eeModel = eeModel + xx(xx1st+3)*fSin + xx(xx1st+4)*fCos;
        %uuModel = uuModel + xx(xx1st+5)*fSin + xx(xx1st+6)*fCos;
        xx1st = xx1st+6;
    end
end
xxend = xx1st;

% loop through earthquakes
eqNum = size(eqMat,1);
for jj=1:eqNum
    Teq  = eqMat(jj,2);
    ind2 = tt>=Teq;
    func = funcMat(jj,:);
    ff   = reshape(func,[],3)';
    funcN = ff(1,:); funcE = ff(2,:); funcU = ff(3,:);
    % add rate changes
    if strfind(funcN,'diffrate')
        xxend = xxend+1; %nndV = xx(xxend);
    end
    if strfind(funcE,'diffrate')
        xxend = xxend+1; %eedV = xx(xxend);
    end
    if strfind(funcU,'diffrate')
        xxend = xxend+1; %uudV = xx(xxend);
    end
    % add offsets
    if ~isempty(regexpi(funcN,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
        xxend = xxend+1; nnO = xx(xxend);
        nn(ind2) = nn(ind2) - nnO;
    end
    if ~isempty(regexpi(funcE,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
        xxend = xxend+1; eeO = xx(xxend);
        ee(ind2) = ee(ind2) - eeO;
    end
    if ~isempty(regexpi(funcU,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
        xxend = xxend+1; uuO = xx(xxend);
        uu(ind2) = uu(ind2) - uuO;
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
            xxend = xxend+1; %nntau = xx(xxend);
            xxend = xxend+1; %nnaa  = xx(xxend);
        end
        if ~isempty(regexpi(funcE,'(log|lng|lg2|ln2)'))
            etauName = 'tau'; 
            % check tau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName = funcE(etauInd:etauInd+3);
            end
            if ~strcmp(etauName,ntauName)
               xxend = xxend+1; %eetau = xx(xxend);
            end
            xxend = xxend+1; %eeaa = xx(xxend);
        end
        if ~isempty(regexpi(funcU,'(log|lng|lg2|ln2)'))
            utauName = 'tau';
            % check tau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName = funcU(utauInd:utauInd+3);
            end
            if ~strcmp(utauName,ntauName) && ~strcmp(utauName,etauName)
               xxend = xxend+1; %uutau = xx(xxend);
            end
            xxend = xxend+1; %uuaa = xx(xxend);
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
            xxend = xxend+1; %nntau = xx(xxend);
            xxend = xxend+1; %nnaa = xx(xxend);
        end
        if ~isempty(regexpi(funcE,'(exp|ep2)'))
            etauName = 'tau'; 
            % check tau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName = funcE(etauInd:etauInd+3);
            end
            if ~strcmp(etauName,ntauName)
               xxend = xxend+1; %eetau = xx(xxend);
            end
            xxend = xxend+1; %eeaa = xx(xxend);
        end
        if ~isempty(regexpi(funcU,'(exp|ep2)'))
            utauName = 'tau';
            % check tau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName = funcU(utauInd:utauInd+3);
            end
            if ~strcmp(utauName,ntauName) && ~strcmp(utauName,etauName)
               xxend = xxend+1; %uutau = xx(xxend);
            end
            xxend = xxend+1; %uuaa = xx(xxend);
        end
    end
    % add generalized rate-strengthening
    if regexpi(func,'k[0-9]{2}_\w+')
        ntauName = ''; etauName = ''; utauName = '';
        kk = str2double(func(2:3));
        if regexpi(funcN,'k[0-9]{2}_\w+')
            ntauName = 'tau'; 
            % check tau
            ntauInd = strfind(funcN,'tau');
            if ntauInd
               ntauName = funcN(ntauInd:ntauInd+3);
            end
            xxend = xxend+1; %nntau = xx(xxend);
            xxend = xxend+1; %nnaa = xx(xxend);
        end
        if regexpi(funcE,'k[0-9]{2}_\w+')
            etauName = 'tau'; 
            % check tau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName = funcE(etauInd:etauInd+3);
            end
            if ~strcmp(etauName,ntauName)
               xxend = xxend+1; %eetau = xx(xxend);
            end
            xxend = xxend+1; %eeaa = xx(xxend);
        end
        if regexpi(funcU,'k[0-9]{2}_\w+')
            utauName = 'tau';
            % check tau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName = funcU(utauInd:utauInd+3);
            end
            if ~strcmp(utauName,ntauName) && ~strcmp(utauName,etauName)
               xxend = xxend+1; %uutau = xx(xxend);
            end
            xxend = xxend+1; %uuaa = xx(xxend);
        end
    end
end

rneuNoff = rneu;
rneuNoff(:,3:5) = [ nn ee uu ];
