function [ rneu ] = GPS_lsqnonlin_1site_properrors(rneu,eqMat,funcMat,fqMat,xx,xxStd,tt0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        GPS_lsqnonlin_1site_properrors                       %
% Determine error for prediction at each epoch                                %
% accumulate Cov from the squared error of each term                          %
% assuming no correlation between different terms                             %
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
% xxStd   - standard deviations of parameters                                 %
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
% rneu - prediction + standard deviation of model prediction                  %
%                                                                             %
% first created by Lujia Feng Sun Apr 13 10:14:06 SGT 2014                    %
% added natural log lng lfeng Wed Jul  2 11:59:18 SGT 2014                    %
% added 2nd natural log ln2 lfeng Wed Jul  2 18:27:02 SGT 2014                %
% corrected tau when N is offset while E is log lfeng Sun Jul 13 SGT 2014     %
% coded up for exp lfeng Tue Jan 20 18:18:13 SGT 2015                         %
% last modified by Lujia Feng Tue Jan 20 19:29:11 SGT 2015                    %
% --------------------------------------------------------------------------- %
% Note: haven't coded up for generalized rate-strengthening                   %
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

xxCov = xxStd.^2;

% base model = intercept + rate*time
xx1st = 0; 
nnCov = xxCov(xx1st+1) + xxCov(xx1st+2)*tt.^2;
eeCov = xxCov(xx1st+3) + xxCov(xx1st+4)*tt.^2;
uuCov = xxCov(xx1st+5) + xxCov(xx1st+6)*tt.^2;

% seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
xx1st = 6; 
if any(fqMat)
    fqNum = size(fqMat,1);
    for ii=1:fqNum
        fSin2 = sin(2*pi*fqMat(ii,1).*tt).^2; 
	fCos2 = cos(2*pi*fqMat(ii,2).*tt).^2;
        nnCov = nnCov + xxCov(xx1st+1)*fSin2 + xxCov(xx1st+2)*fCos2;
        eeCov = eeCov + xxCov(xx1st+3)*fSin2 + xxCov(xx1st+4)*fCos2;
        uuCov = uuCov + xxCov(xx1st+5)*fSin2 + xxCov(xx1st+6)*fCos2;
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
        xxend       = xxend+1; 
	nndVCov     = xxCov(xxend);
        nnCov(ind2) = nnCov(ind2) + nndVCov*(tt(ind2)-Teq).^2;
    end
    if strfind(funcE,'diffrate')
        xxend       = xxend+1; 
	eedVCov     = xxCov(xxend);
        eeCov(ind2) = eeCov(ind2) + eedVCov*(tt(ind2)-Teq).^2;
    end
    if strfind(funcU,'diffrate')
        xxend       = xxend+1; 
	uudVCov     = xxCov(xxend);
        uuCov(ind2) = uuCov(ind2) + uudVCov*(tt(ind2)-Teq).^2;
    end
    % add offsets    
    if ~isempty(regexpi(funcN,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
        xxend       = xxend+1; 
	nnOCov      = xxCov(xxend);
        nnCov(ind2) = nnCov(ind2) + nnOCov;
    end
    if ~isempty(regexpi(funcE,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
        xxend       = xxend+1; 
	eeOCov      = xxCov(xxend);
        eeCov(ind2) = eeCov(ind2) + eeOCov;
    end
    if ~isempty(regexpi(funcU,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
        xxend       = xxend+1; 
	uuOCov      = xxCov(xxend);
        uuCov(ind2) = uuCov(ind2) + uuOCov;
    end
    % add log changes
    if ~isempty(regexpi(func,'(log|lng|lg2|ln2)'))
        ntauName = ''; etauName = ''; utauName = '';
        if ~isempty(regexpi(funcN,'(log|lng|lg2|ln2)'))
            ntauName = 'tau'; 
            % check nntau
            ntauInd = strfind(funcN,'tau');
            if ntauInd
               ntauName = funcN(ntauInd:ntauInd+3);
            end
            xxend    = xxend+1; 
            nntau    = xx(xxend);
            nntauCov = xxCov(xxend);
            % nnaa
            xxend    = xxend+1; 
            nnaa     = xx(xxend);
            nnaaCov  = xxCov(xxend);
            % aa*log(1+(tt-Teq)/tau)
            nnlogin     = 1+(tt(ind2)-Teq)/nntau;
            nnloginCov  = nntauCov*(tt(ind2)-Teq).^2/nntau.^4;
            if strfind(funcN,'ln');
               nnlog    = log(nnlogin);
	       % obtained from wikipedia http://en.wikipedia.org/wiki/Propagation_of_uncertainty
               nnlogCov = nnloginCov./nnlogin.^2; 
            else
               nnlog    = log10(nnlogin);
               nnlogCov = 0.4343*nnloginCov./nnlogin.^2;
            end
	    % assuming aa and tau are not correlated. They are actually correlated.
            nnCov(ind2) = nnCov(ind2) + nnlog.^2*nnaaCov + nnaa^2.*nnlogCov;
        end
        if ~isempty(regexpi(funcE,'(log|lng|lg2|ln2)'))
            etauName = 'tau'; 
            % check eetau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName = funcE(etauInd:etauInd+3);
            end
            if strcmp(etauName,ntauName)
               eetau    = nntau;
               eetauCov = nntauCov;
            else
               xxend    = xxend+1; 
               eetau    = xx(xxend);
               eetauCov = xxCov(xxend);
            end
            % eeaa
            xxend    = xxend+1; 
            eeaa     = xx(xxend);
            eeaaCov  = xxCov(xxend);
            % aa*log(1+(tt-Teq)/tau)
            eelogin     = 1+(tt(ind2)-Teq)/eetau;
            eeloginCov  = eetauCov*(tt(ind2)-Teq).^2/eetau.^4;
            if strfind(funcE,'ln');
               eelog    = log(eelogin);
               eelogCov = eeloginCov./eelogin.^2;
            else
               eelog    = log10(eelogin);
               eelogCov = 0.4343*eeloginCov./eelogin.^2;
            end
            eeCov(ind2) = eeCov(ind2) + eelog.^2*eeaaCov + eeaa^2.*eelogCov;
        end
        if ~isempty(regexpi(funcU,'(log|lng|lg2|ln2)'))
            utauName = 'tau';
            % check uutau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName = funcU(utauInd:utauInd+3);
            end
            if strcmp(utauName,ntauName)
               uutau    = nntau;
               uutauCov = nntauCov;
            elseif strcmp(utauName,etauName)
               uutau    = eetau;
               uutauCov = eetauCov;
            else
               xxend    = xxend+1; 
               uutau    = xx(xxend);
               uutauCov = xxCov(xxend);
            end
            % uuaa
            xxend       = xxend+1; 
            uuaa        = xx(xxend);
            uuaaCov     = xxCov(xxend);
            % aa*log(1+(tt-Teq)/tau)
            uulogin     = 1+(tt(ind2)-Teq)/uutau;
            uuloginCov  = uutauCov*(tt(ind2)-Teq).^2/uutau.^4;
            if strfind(funcU,'ln');
               uulog    = log(uulogin);
               uulogCov = uuloginCov./uulogin.^2;
            else
               uulog    = log10(uulogin);
               uulogCov = 0.4343*uuloginCov./uulogin.^2;
            end
            uuCov(ind2) = uuCov(ind2) + uulog.^2*uuaaCov + uuaa^2.*uulogCov;
        end
    end
    % add exp changes
    if ~isempty(regexpi(func,'(exp|ep2)'))
        ntauName = ''; etauName = ''; utauName = '';
        if ~isempty(regexpi(funcN,'(exp|ep2)'))
            ntauName = 'tau'; 
            % check nntau
            ntauInd = strfind(funcN,'tau');
            if ntauInd
               ntauName = funcN(ntauInd:ntauInd+3);
            end
            xxend    = xxend+1; 
            nntau    = xx(xxend);
            nntauCov = xxCov(xxend);
            % nnaa
            xxend    = xxend+1; 
            nnaa     = xx(xxend);
            nnaaCov  = xxCov(xxend);
            %   aa*(1-exp((Teq-tt)/tau))
	    % = aa - aa*exp((Teq-tt)/tau) -> A - A*B
	    % obtained from wikipedia http://en.wikipedia.org/wiki/Propagation_of_uncertainty
            nnexpin     = (Teq-tt(ind2))/nntau;
            nnexp       = exp(nnexpin);

            nnexpinCov  = nntauCov*(tt(ind2)-Teq).^2/nntau.^4; % = nnloginCov
	    nnexpCov    = nnexp.^2.*nnexpinCov;
            % nnaaexpCov is covariance for aa*exp((Teq-tt)/tau)
	    %                    A         *        B
	    nnaaexpCov  = nnexp.^2*nnaaCov + nnaa^2.*nnexpCov;
            %                               A     + (A*B)
            nnCov(ind2) = nnCov(ind2) + 1*nnaaCov + 1*nnaaexpCov;
        end
        if ~isempty(regexpi(funcE,'(exp|ep2)'))
            etauName = 'tau'; 
            % check eetau
            etauInd = strfind(funcE,'tau');
            if etauInd
               etauName = funcE(etauInd:etauInd+3);
            end
            if strcmp(etauName,ntauName)
               eetau    = nntau;
               eetauCov = nntauCov;
            else
               xxend    = xxend+1; 
               eetau    = xx(xxend);
               eetauCov = xxCov(xxend);
            end
            % eeaa
            xxend    = xxend+1; 
            eeaa     = xx(xxend);
            eeaaCov  = xxCov(xxend);
            %   aa*(1-exp((Teq-tt)/tau))
	    % = aa - aa*exp((Teq-tt)/tau) -> A - A*B
            eeexpin     = (Teq-tt(ind2))/eetau;
            eeexp       = exp(eeexpin);

            eeexpinCov  = eetauCov*(tt(ind2)-Teq).^2/eetau.^4; % = eeloginCov
	    eeexpCov    = eeexp.^2.*eeexpinCov;
            % nnaaexpCov is covariance for aa*exp((Teq-tt)/tau)
	    %                    A         *        B
	    eeaaexpCov  = eeexp.^2*eeaaCov + eeaa^2.*eeexpCov;
            %                               A     + (A*B)
            eeCov(ind2) = eeCov(ind2) + 1*eeaaCov + 1*eeaaexpCov;
        end
        if ~isempty(regexpi(funcU,'(exp|ep2)'));
            utauName = 'tau';
            % check uutau
            utauInd = strfind(funcU,'tau');
            if utauInd
               utauName = funcU(utauInd:utauInd+3);
            end
            if strcmp(utauName,ntauName)
               uutau    = nntau;
               uutauCov = nntauCov;
            elseif strcmp(utauName,etauName)
               uutau    = eetau;
               uutauCov = eetauCov;
            else
               xxend    = xxend+1; 
               uutau    = xx(xxend);
               uutauCov = xxCov(xxend);
            end
            % uuaa
            xxend       = xxend+1; 
            uuaa        = xx(xxend);
            uuaaCov     = xxCov(xxend);
            %   aa*(1-exp((Teq-tt)/tau))
	    % = aa - aa*exp((Teq-tt)/tau) -> A - A*B
            uuexpin     = (Teq-tt(ind2))/uutau;
            uuexp       = exp(uuexpin);

            uuexpinCov  = uutauCov*(tt(ind2)-Teq).^2/uutau.^4; % = uuloginCov
	    uuexpCov    = uuexp.^2.*uuexpinCov;
            % uuaaexpCov is covariance for aa*exp((Teq-tt)/tau)
	    %                    A         *        B
	    uuaaexpCov  = uuexp.^2*uuaaCov + uuaa^2.*uuexpCov;
            %                               A     + (A*B)
            uuCov(ind2) = uuCov(ind2) + 1*uuaaCov + 1*uuaaexpCov;
        end
    end
    % add generalized rate-strengthening
    if regexpi(func,'k[0-9]{2}_\w+')
        error('GPS_lsqnonlin_1site_properrors ERROR: have not coded up for rate-strengthening!');
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
            nnCov(ind2) = nnCov(ind2)+nnaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/nntau)));    
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
            eeCov(ind2) = eeCov(ind2)+eeaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/eetau)));
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
            uuCov(ind2) = uuCov(ind2)+uuaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/uutau)));
        end
    end
end

% get stardand deviation for model prediction
nnStd = sqrt(nnCov);
eeStd = sqrt(eeCov);
uuStd = sqrt(uuCov);

rneu(:,6) = nnStd;
rneu(:,7) = eeStd;
rneu(:,8) = uuStd;
