function [ diff,jacob ] = GPS_lsqnonlin_1site(rneu,eqMat,funcMat,fqMat,xx,tt0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          GPS_lsqnonlin_1site          		      %
% Simultaneously fit a list of EQ offsets or postseismic deformation          %
% for one station                                                             %
%                                                                             %
% Independent Parameters: t 						      %
% Dependent Parameters:   y                                                   %
% Coefficients: 							      %
%  Teq - earthquake time						      %
%    b - nominal value of intercept					      %
%   v0 - base rate before everything			                      %
%   dv - rate change after one earthquake				      %
%    O - coseismic offset						      %
%    a - amplitude of the exponential term				      %
%  tau - decay time constant						      %
%  tau is the only non-linear parameter					      %
%-------------------------- Linear Rate "linear" -----------------------------%
% for all t: y = b + v0*t 						      %
%-------------------------------- Seasonal -----------------------------------%
% for all t: y = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)                      %
%    1 year fqSin = 1; fqCos = 1                                              %
% half year fqSin = 2; fqCos = 2                                              %
%------------------------------   Offset    ----------------------------------%
% t >= Teq:  y = y + O 						              %
% optional rate change                                                        %
% t >= Teq:  y = y + dV*(t-Teq) 					      %
%------------------------------ Exponential ----------------------------------%
% t >= Teq: y = y + O + a*(1-exp(-(t-Teq)/tau))	                              %
%				    t-Teq		                      %
% t >= Teq: y = y + O + a*(1-exp(- -------))	                              % 
%				     tau		                      % 
% optional rate change                                                        %
% t >= Teq:  y = y + dV*(t-Teq) 					      %
%----------------------------- Logarithmical ---------------------------------%
%				                       t-Teq		      %
% t >= Teq: y = b + v1*Teq + v2*(t-Teq) + O + a*log(1+-------)		      %
%					                tau		      %
%----------------------------- Hyperbolic  -----------------------------------%
% for generalized rate-strengthening laws [Barbot etal 2009]                  %
%				                    2           k    t-Teq    %
% t >= Teq: y = b + v1*Teq + v2*(t-Teq) + O + a*(1- -acoth{coth(-)e^(-----)}  %
%					            k           2     tau     %
%-----------------------------------------------------------------------------%
% INPUT:								      %
% rneu - data marix (dayNum*8)                                                %
%      = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                          %
% eqMat   = [ Deq Teq ]                 (eqNum*2)                             %
%         = [] means no earthquake removed                                    %
% funcMat - a string matrix for function names                                %
%         = [ funcN funcE funcU ]       (eqNum*3*funcLen)                     %
% funcLen = 20                                                                %
% fqMat   - frequency in 1/year                                               %
%         = [ fqSin fqCos ]             (fqNum*2)                             %
%         = [] means no seasonal signals removed                              %
% xx      - unknown parameters that need to be estimated 		      %
% tt0     - time reference point                                              %
%         = [] means using the first point as reference                       %
%									      %
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
% diff  - weighted residual						      %
% jacob - jacobian of diff                                                    %
%         use MATLAB Symbolic Box 'syms' to verify derivatives                %
%                                                                             %
% first created by Lujia Feng Wed Jul 11 15:23:07 SGT 2012                    %
% different fittypes for NEU lfeng Mon Jul 16 17:57:18 SGT 2012               %
% added generalized rate-strengthening lfeng Tue Jul 17 15:07:26 SGT 2012     %
% corrected rate change mistake lfeng Mon Aug  6 04:35:21 SGT 2012            %
% added seasonal cycles lfeng Sat Oct 27 02:31:40 SGT 2012                    %
% added jacob lfeng Mon Nov 26 12:44:47 SGT 2012                              %
% moved excluding EQ days to GPS_fitall_1site.m Wed Apr  3 20:54:59 SGT 2013  %
% modified funcMat lfeng Thu Apr  4 12:22:32 SGT 2013                         %
% corrected diffrate error lfeng Tue Apr  9 05:45:17 SGT 2013                 %
% tested using weights lfeng Thu Nov 28 17:24:20 SGT 2013                     %
% added time reference tt0 lfeng Wed Jan  8 12:58:10 SGT 2014                 %
% added lg2 ep2 & corrected regexpi lfeng Wed Mar  5 11:21:08 SGT 2014        %
% added natural log lng lfeng Wed Jul  2 11:59:18 SGT 2014                    %
% added 2nd natural log ln2 lfeng Wed Jul  2 18:27:02 SGT 2014                %
% corrected tau when N is offset while E is log lfeng Sun Jul 13 SGT 2014     %
% allowed data to be nan lfeng Mon Aug 18 12:19:58 SGT 2014                   %
% corrected a type for exp lfeng Tue Jan 20 17:50:56 SGT 2015                 %
% last modified by Lujia Feng Tue Jan 20 17:51:05 SGT 2015                    %
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

nn = rneu(:,3); nnErr = rneu(:,6);
ee = rneu(:,4); eeErr = rneu(:,7);
uu = rneu(:,5); uuErr = rneu(:,8);

all1 = ones(size(tt));          
all0 = zeros(size(tt));

% base model = intercept + rate*time
nnJacob = []; eeJacob = []; uuJacob = [];
xx1st = 0; 
nnModel = xx(xx1st+1) + xx(xx1st+2)*tt;
nnJacob = [ nnJacob all1 tt ];   eeJacob = [ eeJacob all0 all0 ]; uuJacob = [ uuJacob all0 all0 ];
eeModel = xx(xx1st+3) + xx(xx1st+4)*tt;
nnJacob = [ nnJacob all0 all0 ]; eeJacob = [ eeJacob all1 tt ];   uuJacob = [ uuJacob all0 all0 ];
uuModel = xx(xx1st+5) + xx(xx1st+6)*tt;
nnJacob = [ nnJacob all0 all0 ]; eeJacob = [ eeJacob all0 all0 ]; uuJacob = [ uuJacob all1 tt ];

% seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
xx1st = 6; 
if any(fqMat)
    fqNum = size(fqMat,1);
    for ii=1:fqNum
        fSin = sin(2*pi*fqMat(ii,1).*tt); fCos = cos(2*pi*fqMat(ii,2).*tt);
        nnModel = nnModel + xx(xx1st+1)*fSin + xx(xx1st+2)*fCos;
        nnJacob = [ nnJacob fSin fCos ]; eeJacob = [ eeJacob all0 all0 ]; uuJacob = [ uuJacob all0 all0 ];
        eeModel = eeModel + xx(xx1st+3)*fSin + xx(xx1st+4)*fCos;
        nnJacob = [ nnJacob all0 all0 ]; eeJacob = [ eeJacob fSin fCos ]; uuJacob = [ uuJacob all0 all0 ];
        uuModel = uuModel + xx(xx1st+5)*fSin + xx(xx1st+6)*fCos;
        nnJacob = [ nnJacob all0 all0 ]; eeJacob = [ eeJacob all0 all0 ]; uuJacob = [ uuJacob fSin fCos ];
        xx1st = xx1st+6;
    end
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
        jcb   = all0; jcb(ind2) = tt(ind2)-Teq;
        nnJacob = [ nnJacob jcb ]; eeJacob = [ eeJacob all0 ]; uuJacob = [ uuJacob all0 ];
    end
    if strfind(funcE,'diffrate')
        xxend = xxend+1; eedV = xx(xxend);
        eeModel(ind2) = eeModel(ind2)+eedV*(tt(ind2)-Teq);
        jcb   = all0; jcb(ind2) = tt(ind2)-Teq;
        nnJacob = [ nnJacob all0 ]; eeJacob = [ eeJacob jcb ]; uuJacob = [ uuJacob all0 ];
    end
    if strfind(funcU,'diffrate')
        xxend = xxend+1; uudV = xx(xxend);
        uuModel(ind2) = uuModel(ind2)+uudV*(tt(ind2)-Teq);
        jcb   = all0; jcb(ind2) = tt(ind2)-Teq;
        nnJacob = [ nnJacob all0 ]; eeJacob = [ eeJacob all0 ]; uuJacob = [ uuJacob jcb ];
    end
    % add offsets    
    if ~isempty(regexpi(funcN,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
        xxend = xxend+1; nnO = xx(xxend);
        nnModel(ind2) = nnModel(ind2) + nnO;
        nnJacob = [ nnJacob all1 ]; eeJacob = [ eeJacob all0 ]; uuJacob = [ uuJacob all0 ];
    end
    if ~isempty(regexpi(funcE,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
        xxend = xxend+1; eeO = xx(xxend);
        eeModel(ind2) = eeModel(ind2) + eeO;
        nnJacob = [ nnJacob all0 ]; eeJacob = [ eeJacob all1 ]; uuJacob = [ uuJacob all0 ];
    end
    if ~isempty(regexpi(funcU,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
        xxend = xxend+1; uuO = xx(xxend);
        uuModel(ind2) = uuModel(ind2) + uuO;
        nnJacob = [ nnJacob all0 ]; eeJacob = [ eeJacob all0 ]; uuJacob = [ uuJacob all1 ];
    end
    % add log changes
    if ~isempty(regexpi(func,'(log|lng|lg2|ln2)'))
        jntau = all0; jetau = all0; jutau = all0;
        njcb  = [];   ejcb  = [];   ujcb  = [];
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
            if strfind(funcN,'ln'); % ln
               nnModel(ind2) = nnModel(ind2)+nnaa*log(1+(tt(ind2)-Teq)/nntau); 
               jntau(ind2)   = nnaa*(Teq-tt(ind2))./(nntau*(tt(ind2)-Teq+nntau));
               jnaa          = all0; 
               jnaa(ind2)    = log(1+(tt(ind2)-Teq)/nntau);
            else % log10
               nnModel(ind2) = nnModel(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/nntau); 
               jntau(ind2)   = nnaa*(Teq-tt(ind2))./(log(10)*nntau*(tt(ind2)-Teq+nntau));
               jnaa          = all0; 
               jnaa(ind2)    = log10(1+(tt(ind2)-Teq)/nntau);
            end
            njcb = [ njcb jnaa ]; ejcb = [ ejcb all0 ]; ujcb = [ ujcb all0 ];
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
               jetau(ind2)   = eeaa*(Teq-tt(ind2))./(eetau*(tt(ind2)-Teq+eetau));
               jeaa          = all0; 
               jeaa(ind2)    = log(1+(tt(ind2)-Teq)/eetau);
            else
               eeModel(ind2) = eeModel(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/eetau);
               jetau(ind2)   = eeaa*(Teq-tt(ind2))./(log(10)*eetau*(tt(ind2)-Teq+eetau));
               jeaa          = all0; 
               jeaa(ind2)    = log10(1+(tt(ind2)-Teq)/eetau);
            end
            njcb = [ njcb all0 ]; ejcb = [ ejcb jeaa ]; ujcb = [ ujcb all0 ];
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
               jutau(ind2)   = uuaa*(Teq-tt(ind2))./(uutau*(tt(ind2)-Teq+uutau));
               juaa          = all0;
               juaa(ind2)    = log(1+(tt(ind2)-Teq)/uutau);
            else
               uuModel(ind2) = uuModel(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/uutau); 
               jutau(ind2)   = uuaa*(Teq-tt(ind2))./(log(10)*uutau*(tt(ind2)-Teq+uutau));
               juaa          = all0;
               juaa(ind2)    = log10(1+(tt(ind2)-Teq)/uutau);
            end
            njcb = [ njcb all0 ]; ejcb = [ ejcb all0 ]; ujcb = [ ujcb juaa ];
        end
        nnJacob = [ nnJacob jntau njcb ]; eeJacob = [ eeJacob jetau ejcb ]; uuJacob = [ uuJacob jutau ujcb ];
    end
    % add exp changes
    if ~isempty(regexpi(func,'(exp|ep2)'))
        jntau = all0; jetau = all0; jutau = all0;
        njcb  = [];   ejcb  = [];   ujcb  = [];
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
            jntau(ind2)   = nnaa*exp((Teq-tt(ind2))/nntau).*(Teq-tt(ind2))/nntau^2;
            jnaa          = all0; 
            jnaa(ind2)    = 1-exp((Teq-tt(ind2))/nntau);
            njcb = [ njcb jnaa ]; ejcb = [ ejcb all0 ]; ujcb = [ ujcb all0 ];
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
            jetau(ind2)   = eeaa*exp((Teq-tt(ind2))/eetau).*(Teq-tt(ind2))/eetau^2;
            jeaa          = all0; 
            jeaa(ind2)    = 1-exp((Teq-tt(ind2))/eetau);
            njcb = [ njcb all0 ]; ejcb = [ ejcb jeaa ]; ujcb = [ ujcb all0 ];
        end
        if ~isempty(regexpi(funcU,'(exp|ep2)'));
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
            jutau(ind2)   = uuaa*exp((Teq-tt(ind2))/uutau).*(Teq-tt(ind2))/uutau^2;
            juaa          = all0; 
            juaa(ind2)    = 1-exp((Teq-tt(ind2))/uutau);
            njcb = [ njcb all0 ]; ejcb = [ ejcb all0 ]; ujcb = [ ujcb juaa ];
        end
        nnJacob = [ nnJacob jntau njcb ]; eeJacob = [ eeJacob jetau ejcb ]; uuJacob = [ uuJacob jutau ujcb ];
    end
    % add generalized rate-strengthening
    if regexpi(func,'k[0-9]{2}_\w+')
        kk = str2double(func(2:3));
        jntau = all0; jetau = all0; jutau = all0;
        njcb  = [];   ejcb  = [];   ujcb  = [];
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
            jntau(ind2)   = (2*nnaa*coth(kk/2).*(Teq - tt(ind2)))./...
                            (kk*nntau^2*exp((Teq - tt(ind2))/nntau).*(coth(kk/2)^2./exp(2*(Teq - tt(ind2))./nntau) - 1));
            jnaa          = all0; 
            jnaa(ind2)    = 1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/nntau));
            njcb = [ njcb jnaa ]; ejcb = [ ejcb all0 ]; ujcb = [ ujcb all0 ];
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
            jetau(ind2)   = (2*eeaa*coth(kk/2).*(Teq - tt(ind2)))./...
                            (kk*eetau^2*exp((Teq - tt(ind2))/eetau).*(coth(kk/2)^2./exp(2*(Teq - tt(ind2))./eetau) - 1));
            jeaa          = all0; 
            jeaa(ind2)    = 1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/eetau));
            njcb = [ njcb all0 ]; ejcb = [ ejcb jeaa ]; ujcb = [ ujcb all0 ];
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
            jutau(ind2)   = (2*uuaa*coth(kk/2).*(Teq - tt(ind2)))./...
                            (kk*uutau^2*exp((Teq - tt(ind2))/uutau).*(coth(kk/2)^2./exp(2*(Teq - tt(ind2))./uutau) - 1));
            juaa          = all0; 
            juaa(ind2)    = 1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/uutau));
            njcb = [ njcb all0 ]; ejcb = [ ejcb all0 ]; ujcb = [ ujcb juaa ];
        end
        nnJacob = [ nnJacob jntau njcb ]; eeJacob = [ eeJacob jetau ejcb ]; uuJacob = [ uuJacob jutau ujcb ];
    end
end

% (1) calculate residuals without weighting
%-----diffnn = nnModel-nn;
%-----diffee = eeModel-ee;
%-----diffuu = uuModel-uu;
% (2) calculate weighted residuals using gipsy formal errors
% gipsy errors probably underestimated
indnn  = ~isnan(nn);
diffnn = (nnModel(indnn)-nn(indnn))./nnErr(indnn);
indee  = ~isnan(ee);
diffee = (eeModel(indee)-ee(indee))./eeErr(indee);
induu  = ~isnan(uu);
diffuu = (uuModel(induu)-uu(induu))./uuErr(induu);
% Notes on residual functions
% a. methods (1) and (2) achieve similar results!!!!!
% b. method (2) is preferred, because it is much faster than method (1)!!!!!
% c. method (2) modifies Jacob according weights. So be careful when using Jacob to calculate errors.

%% weighted Jacobian
%nnJacob = bsxfun(@rdivide,nnJacob,nnErr);
%eeJacob = bsxfun(@rdivide,eeJacob,eeErr);
%uuJacob = bsxfun(@rdivide,uuJacob,uuErr);

% output needs to be residual vector
diff = [ diffnn; diffee; diffuu ];
if nargout > 1  % if two output arguments
   jacob = [ nnJacob(indnn,:); eeJacob(indee,:); uuJacob(induu,:) ];
end
