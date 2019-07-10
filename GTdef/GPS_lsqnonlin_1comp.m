function [ diff ] = GPS_lsqnonlin_1comp(rneu,eqMat,funcMat,fqMat,xx)

% need to check
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_lsqnonlin_1comp          		      %
% Simultaneously fit a list of EQ offsets or postseismic deformation          %
% for one station                                                             %
%									      %
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
% rneu    - a datNum*8 matrix to store data                                   %
%           1        2         3     4    5    6     7     8                  %
%           YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err              %
% eqMat   - an eqNum*2 matrix                                                 %
%           1    2                                                            %
%           Deq  Teq                                                          %
% funcMat - a eqNum*12*3 string matrix for function names                     %
%            'off_samerate' 'off_diffrate'                                    %
%            'log_samerate' 'log_diffrate'                                    %
%            'exp_samerate' 'exp_diffrate'                                    %
%            'k05_samerate' 'k07_diffrate'                                    %
% fqMat   - frequency in 1/year                                               %
%           an fqNum*2 matrix                                                 %
%           1      2                                                          %
%           fqSin  fqCos                                                      %
%   if fqMat = [ 0 0 ], seasonal not considered                               %
% comp    - 'N' 'E' 'U' (string) or 1 2 3 (numbers)                           %
% xx      - unknown parameters that need to be estimated 		      %
%   The 1st datNum variables are common mode noise                            %
%									      %
% OUTPUT:								      %
% diff - weighted residual						      %
%									      %
% first created by lfeng Wed Jul 11 15:23:07 SGT 2012                         %
% different fittypes for NEU lfeng Mon Jul 16 17:57:18 SGT 2012               %
% added generalized rate-strengthening lfeng Tue Jul 17 15:07:26 SGT 2012     %
% corrected rate change mistake lfeng Mon Aug  6 04:35:21 SGT 2012            %
% added seasonal cycles lfeng Sat Oct 27 02:31:40 SGT 2012                    %
% last modified by lfeng Sat Oct 27 02:32:25 SGT 2012                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% time reference to the 1st observation point
tt     = rneu(:,2) - rneu(1,2);
TeqMat = eqMat(:,2)- rneu(1,2);
nn = rneu(:,3); nnErr = rneu(:,6);
ee = rneu(:,4); eeErr = rneu(:,7);
uu = rneu(:,5); uuErr = rneu(:,8);

% base model = intercept + rate*time
xx1st = 0; 
nnModel = xx(xx1st+1) + xx(xx1st+2)*tt;
eeModel = xx(xx1st+3) + xx(xx1st+4)*tt;
uuModel = xx(xx1st+5) + xx(xx1st+6)*tt;
% seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
xx1st = 6; 
if any(fqMat)
    fqNum = size(fqMat,1);
    for ii=1:fqNum
        fSin = sin(2*pi*fqMat(ii,1).*tt); fCos = cos(2*pi*fqMat(ii,2).*tt);
        nnModel = nnModel + xx(xx1st+1)*fSin + xx(xx1st+2)*fCos;
        eeModel = eeModel + xx(xx1st+3)*fSin + xx(xx1st+4)*fCos;
        uuModel = uuModel + xx(xx1st+5)*fSin + xx(xx1st+6)*fCos;
	xx1st = xx1st+6;
    end
end
xxend = xx1st;

% loop through earthquakes
eqNum = size(funcMat,1);
% if no earthquakes removed
if eqNum==1 && ~isempty(strfind(funcMat,'none'))
    eqNum = 0;
end

for jj=1:eqNum
    Teq  = TeqMat(jj);
    ind2 = tt>=Teq;
    func = funcMat(jj,:);
    ff   = reshape(func,[],3)';
    funcN = ff(1,:); funcE = ff(2,:); funcU = ff(3,:);
    % add rate changes
    if strfind(funcN,'diffrate')
        xxend = xxend+1; nndV = xx(xxend+1);
        nnModel(ind2) = nnModel(ind2)+nndV*(tt(ind2)-Teq);
    end
    if strfind(funcE,'diffrate')
        xxend = xxend+1; eedV = xx(xxend+1);
        eeModel(ind2) = eeModel(ind2)+eedV*(tt(ind2)-Teq);
    end
    if strfind(funcU,'diffrate')
        xxend = xxend+1; uudV = xx(xxend+1);
        uuModel(ind2) = uuModel(ind2)+uudV*(tt(ind2)-Teq);
    end
    % add offsets    
    if ~isempty(regexpi(funcN,'[log|off|exp]_\w+')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
        xxend = xxend+1; nnO = xx(xxend);
        nnModel(ind2) = nnModel(ind2) + nnO;
    end
    if ~isempty(regexpi(funcE,'[log|off|exp]_\w+')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
        xxend = xxend+1; eeO = xx(xxend);
        eeModel(ind2) = eeModel(ind2) + eeO;
    end
    if ~isempty(regexpi(funcU,'[log|off|exp]_\w+')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
        xxend = xxend+1; uuO = xx(xxend);
        uuModel(ind2) = uuModel(ind2) + uuO;
    end
    % add log changes
    if strfind(func,'log')
        xxend = xxend+1; tau  = xx(xxend);
        if strfind(funcN,'log')
            xxend = xxend+1; nnaa = xx(xxend);
            nnModel(ind2) = nnModel(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/tau); 
        end
        if strfind(funcE,'log')
            xxend = xxend+1; eeaa = xx(xxend);
            eeModel(ind2) = eeModel(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/tau);
        end
        if strfind(funcU,'log')
            xxend = xxend+1; uuaa = xx(xxend);
            uuModel(ind2) = uuModel(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/tau); 
        end
    end
    % add exp changes
    if strfind(func,'exp')
        xxend = xxend+1; tau  = xx(xxend);
        if strfind(funcN,'exp')
            xxend = xxend+1; nnaa = xx(xxend);
            nnModel(ind2) = nnModel(ind2)+nnaa*(1-exp((Teq-tt(ind2))/tau));
        end
        if strfind(funcE,'exp')
            xxend = xxend+1; eeaa = xx(xxend);
            eeModel(ind2) = eeModel(ind2)+eeaa*(1-exp((Teq-tt(ind2))/tau));
        end
        if strfind(funcU,'exp')
            xxend = xxend+1; uuaa = xx(xxend);
            uuModel(ind2) = uuModel(ind2)+uuaa*(1-exp((Teq-tt(ind2))/tau));
        end
    end
    % add generalized rate-strengthening
    if regexpi(func,'k[0-9]{2}_\w+')
        kk = str2double(func(2:3));
        xxend = xxend+1; tau  = xx(xxend);
        if regexpi(funcN,'k[0-9]{2}_\w+')
            xxend = xxend+1; nnaa = xx(xxend);
            nnModel(ind2) = nnModel(ind2)+nnaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/tau)));
        end
        if regexpi(funcE,'k[0-9]{2}_\w+')
            xxend = xxend+1; eeaa = xx(xxend);
            eeModel(ind2) = eeModel(ind2)+eeaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/tau)));
        end
        if regexpi(funcU,'k[0-9]{2}_\w+')
            xxend = xxend+1; uuaa = xx(xxend);
            uuModel(ind2) = uuModel(ind2)+uuaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/tau)));
        end
    end
end

% calculate residuals
diffnn = (nnModel-nn)./nnErr;
diffee = (eeModel-ee)./eeErr;
diffuu = (uuModel-uu)./uuErr;

% output needs to be residual vector
diff = [ diffnn; diffee; diffuu ];
