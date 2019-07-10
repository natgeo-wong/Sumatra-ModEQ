function [ rneuCopoCell,rneuPostCell,rneuPostNdiffCell,rneuAfterCell ] ...
         = GPS_lsqnonlin_1site_post_properrors(rneu,eqMat,funcMat,fqMat,xx,xxStd,tt0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   GPS_lsqnonlin_1site_post_properrors                       %
% (1) keep postseismic deformation (and/or rate changes if any) of each EQ    %
%     remove background rates, seasonal signals, all offsets & postseismic of %
%     all previsous and following EQs from the time series according to xx    %
% (2) remove everything before one EQ and the coseismic offset of this EQ     %
%     remove background rates, seasonal signals, all other offsets            %
%     but keep postseismic deformation of following EQs                       %
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
% xxStd   - standard deviations of parameters                                 %
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
% OUTPUT:								      %
% rneuCopoCell      - each cell stores coseismic & postseismic deformation    %
%                     for one EQ, data with rates, seasonal signals &         %
%                     offsets & postseimic of other EQs removed               %
% rneuPostCell      - each cell stores postseismic deformation for one EQ     %
%                     data with rates, seasonal signals & all offsets removed %
% rneuPostNdiffCell - each cell stores postseismic deformation for one EQ     %
%                     data with rates, seasonal signals & all offsets removed %
%                     diffrate also removed!!!                                %
% rneuAfterCell     - each cell stores deformation after coseismic of one EQ  %
%                     rates, seasonal signals, all offsets & deformation      %
%                     before this EQ removed                                  %
% Note: errors are calculated except for generalized rate-strengthening!      %
%                                                                             %
% first created based on GPS_lsqnonlin_1site_post.m &                         %
% GPS_lsqnonlin_1site_properrors.m by Lujia Feng                              %
% last modified by Lujia Feng Wed Apr  6 17:52:01 SGT 2016                    %
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

nn    = rneu(:,3); 
ee    = rneu(:,4); 
uu    = rneu(:,5);
nnErr = rneu(:,6);
eeErr = rneu(:,7); 
uuErr = rneu(:,8);

uqMat = unique(eqMat,'rows','stable'); % each EQ has 1 entry
uqNum = size(uqMat,1);
eqNum = size(eqMat,1);
rneuCopoCell      = cell(uqNum,1);
rneuPostCell      = cell(uqNum,1);
rneuPostNdiffCell = cell(uqNum,1);
rneuAfterCell     = cell(uqNum,1);

xxCov = xxStd.^2;

% base model = intercept + rate*time
xx1st = 0; 
nnBase = xx(xx1st+1) + xx(xx1st+2)*tt;
eeBase = xx(xx1st+3) + xx(xx1st+4)*tt;
uuBase = xx(xx1st+5) + xx(xx1st+6)*tt;

nnCovBase = xxCov(xx1st+1) + xxCov(xx1st+2)*tt.^2;
eeCovBase = xxCov(xx1st+3) + xxCov(xx1st+4)*tt.^2;
uuCovBase = xxCov(xx1st+5) + xxCov(xx1st+6)*tt.^2;

% seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
xx1st = 6; 
if any(fqMat)
   fqNum = size(fqMat,1);
   for ii=1:fqNum
      fSin = sin(2*pi*fqMat(ii,1).*tt); fCos = cos(2*pi*fqMat(ii,2).*tt);
      nnBase = nnBase + xx(xx1st+1)*fSin + xx(xx1st+2)*fCos;
      eeBase = eeBase + xx(xx1st+3)*fSin + xx(xx1st+4)*fCos;
      uuBase = uuBase + xx(xx1st+5)*fSin + xx(xx1st+6)*fCos;

      fSin2 = sin(2*pi*fqMat(ii,1).*tt).^2; 
      fCos2 = cos(2*pi*fqMat(ii,2).*tt).^2;
      nnCovBase = nnCovBase + xxCov(xx1st+1)*fSin2 + xxCov(xx1st+2)*fCos2;
      eeCovBase = eeCovBase + xxCov(xx1st+3)*fSin2 + xxCov(xx1st+4)*fCos2;
      uuCovBase = uuCovBase + xxCov(xx1st+5)*fSin2 + xxCov(xx1st+6)*fCos2;

      xx1st = xx1st+6;
   end
end

% consider each earthquake
% EQs have been ordered according to time
for ii=1:uqNum
   ind = find(eqMat(:,1)==uqMat(ii,1));
   iifunc = funcMat(ind(1),:);
   % only output EQ that has postseismic deformation
   if ~isempty(regexpi(iifunc,'(log|lng|exp|k)'))
      xxend = xx1st;
      nnCopo  = nnBase; eeCopo  = eeBase; uuCopo  = uuBase;
      nnPost  = nnBase; eePost  = eeBase; uuPost  = uuBase;
      nnNdiff = nnBase; eeNdiff = eeBase; uuNdiff = uuBase;
      nnAfter = nnBase; eeAfter = eeBase; uuAfter = uuBase;

      % calculate errors 
      nnCopoCov  = nnCovBase; eeCopoCov  = eeCovBase; uuCopoCov  = uuCovBase;
      nnPostCov  = nnCovBase; eePostCov  = eeCovBase; uuPostCov  = uuCovBase;
      nnNdiffCov = nnCovBase; eeNdiffCov = eeCovBase; uuNdiffCov = uuCovBase;
      nnAfterCov = nnCovBase; eeAfterCov = eeCovBase; uuAfterCov = uuCovBase;

      % loop through all functions
      for jj=1:eqNum
         Teq   = TeqMat(jj);
         ind2  = tt>=Teq;
         func  = funcMat(jj,:);
         ff    = reshape(func,[],3)';
         funcN = ff(1,:); funcE = ff(2,:); funcU = ff(3,:);
         % add rate changes
         if strfind(funcN,'diffrate')
            xxend   = xxend+1; 
	    nndV    = xx(xxend);
	    nndVCov = xxCov(xxend);

	    nnNdiff(ind2)    = nnNdiff(ind2)    + nndV*(tt(ind2)-Teq);
            nnNdiffCov(ind2) = nnNdiffCov(ind2) + nndVCov*(tt(ind2)-Teq).^2;
            if eqMat(jj,1) ~= uqMat(ii,1)
               nnCopo(ind2)    = nnCopo(ind2)    + nndV*(tt(ind2)-Teq);
               nnPost(ind2)    = nnPost(ind2)    + nndV*(tt(ind2)-Teq);
               nnCopoCov(ind2) = nnCopoCov(ind2) + nndVCov*(tt(ind2)-Teq).^2;
               nnPostCov(ind2) = nnPostCov(ind2) + nndVCov*(tt(ind2)-Teq).^2;
            end
            if eqMat(jj,1) < uqMat(ii,1)
               nnAfter(ind2)    = nnAfter(ind2)    + nndV*(tt(ind2)-Teq);
               nnAfterCov(ind2) = nnAfterCov(ind2) + nndVCov*(tt(ind2)-Teq).^2;
            end
         end
         if strfind(funcE,'diffrate')
            xxend   = xxend+1; 
	    eedV    = xx(xxend);
	    eedVCov = xxCov(xxend);

            eeNdiff(ind2)    = eeNdiff(ind2)    + eedV*(tt(ind2)-Teq);
            eeNdiffCov(ind2) = eeNdiffCov(ind2) + eedVCov*(tt(ind2)-Teq).^2;
            if eqMat(jj,1) ~= uqMat(ii,1) 
               eeCopo(ind2)    = eeCopo(ind2)    + eedV*(tt(ind2)-Teq);
               eePost(ind2)    = eePost(ind2)    + eedV*(tt(ind2)-Teq);
               eeCopoCov(ind2) = eeCopoCov(ind2) + eedVCov*(tt(ind2)-Teq).^2;
               eePostCov(ind2) = eePostCov(ind2) + eedVCov*(tt(ind2)-Teq).^2;
            end
            if eqMat(jj,1) < uqMat(ii,1) 
               eeAfter(ind2)    = eeAfter(ind2)    + eedV*(tt(ind2)-Teq);
               eeAfterCov(ind2) = eeAfterCov(ind2) + eedVCov*(tt(ind2)-Teq).^2;
            end
         end
         if strfind(funcU,'diffrate')
            xxend   = xxend+1; 
	    uudV    = xx(xxend);
	    uudVCov = xxCov(xxend);

            uuNdiff(ind2)    = uuNdiff(ind2)    + uudV*(tt(ind2)-Teq);
            uuNdiffCov(ind2) = uuNdiffCov(ind2) + uudVCov*(tt(ind2)-Teq).^2;
            if eqMat(jj,1) ~= uqMat(ii,1) 
               uuCopo(ind2)    = uuCopo(ind2)    + uudV*(tt(ind2)-Teq);
               uuPost(ind2)    = uuPost(ind2)    + uudV*(tt(ind2)-Teq);
               uuCopoCov(ind2) = uuCopoCov(ind2) + uudVCov*(tt(ind2)-Teq).^2;
               uuPostCov(ind2) = uuPostCov(ind2) + uudVCov*(tt(ind2)-Teq).^2;
            end
            if eqMat(jj,1) < uqMat(ii,1) 
               uuAfter(ind2)    = uuAfter(ind2)    + uudV*(tt(ind2)-Teq);
               uuAfterCov(ind2) = uuAfterCov(ind2) + uudVCov*(tt(ind2)-Teq).^2;
            end
         end
         % add offsets    
         if ~isempty(regexpi(funcN,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
            xxend  = xxend+1; 
	    nnO    = xx(xxend);
	    nnOCov = xxCov(xxend);

            nnPost(ind2)  = nnPost(ind2)  + nnO;
            nnNdiff(ind2) = nnNdiff(ind2) + nnO;
            nnAfter(ind2) = nnAfter(ind2) + nnO;

            nnPostCov(ind2)  = nnPostCov(ind2)  + nnOCov;
            nnNdiffCov(ind2) = nnNdiffCov(ind2) + nnOCov;
            nnAfterCov(ind2) = nnAfterCov(ind2) + nnOCov;
            if eqMat(jj,1) ~= uqMat(ii,1)
               nnCopo(ind2)    = nnCopo(ind2)    + nnO;
               nnCopoCov(ind2) = nnCopoCov(ind2) + nnOCov;
            end
         end
         if ~isempty(regexpi(funcE,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
            xxend  = xxend+1; 
	    eeO    = xx(xxend);
	    eeOCov = xxCov(xxend);

            eePost(ind2)  = eePost(ind2)  + eeO;
            eeNdiff(ind2) = eeNdiff(ind2) + eeO;
            eeAfter(ind2) = eeAfter(ind2) + eeO;

            eePostCov(ind2)  = eePostCov(ind2)  + eeOCov;
            eeNdiffCov(ind2) = eeNdiffCov(ind2) + eeOCov;
            eeAfterCov(ind2) = eeAfterCov(ind2) + eeOCov;
            if eqMat(jj,1) ~= uqMat(ii,1)
               eeCopo(ind2)    = eeCopo(ind2)    + eeO;
               eeCopoCov(ind2) = eeCopoCov(ind2) + eeOCov;
            end
         end
         if ~isempty(regexpi(funcU,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
            xxend  = xxend+1; 
	    uuO    = xx(xxend);
	    uuOCov = xxCov(xxend);

            uuPost(ind2)  = uuPost(ind2)  + uuO;
            uuNdiff(ind2) = uuNdiff(ind2) + uuO;
            uuAfter(ind2) = uuAfter(ind2) + uuO;

            uuPostCov(ind2)  = uuPostCov(ind2)  + uuOCov;
            uuNdiffCov(ind2) = uuNdiffCov(ind2) + uuOCov;
            uuAfterCov(ind2) = uuAfterCov(ind2) + uuOCov;
            if eqMat(jj,1) ~= uqMat(ii,1)
               uuCopo(ind2)    = uuCopo(ind2)    + uuO;
               uuCopoCov(ind2) = uuCopoCov(ind2) + uuOCov;
            end
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
               xxend = xxend+1; nntau = xx(xxend); nntauCov = xxCov(xxend);
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  nnaa = xx(xxend); nnaaCov  = xxCov(xxend);
                  % aa*log(1+(tt-Teq)/tau)
                  nnlogin     = 1+(tt(ind2)-Teq)/nntau;
                  nnloginCov  = nntauCov*(tt(ind2)-Teq).^2/nntau.^4;
                  if strfind(funcN,'ln');
                     nnCopo(ind2)  = nnCopo(ind2)+nnaa*log(1+(tt(ind2)-Teq)/nntau); 
                     nnPost(ind2)  = nnPost(ind2)+nnaa*log(1+(tt(ind2)-Teq)/nntau); 
                     nnNdiff(ind2) = nnNdiff(ind2)+nnaa*log(1+(tt(ind2)-Teq)/nntau); 

                     nnlog    = log(nnlogin);
                     nnlogCov = nnloginCov./nnlogin.^2; 
                  else
                     nnCopo(ind2)  = nnCopo(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/nntau); 
                     nnPost(ind2)  = nnPost(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/nntau); 
                     nnNdiff(ind2) = nnNdiff(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/nntau); 

                     nnlog    = log10(nnlogin);
                     nnlogCov = 0.4343*nnloginCov./nnlogin.^2;
                  end
	          % assuming aa and tau are not correlated. They are actually correlated.
                  nnCopoCov(ind2)  = nnCopoCov(ind2) + nnlog.^2*nnaaCov + nnaa^2.*nnlogCov;
                  nnPostCov(ind2)  = nnPostCov(ind2) + nnlog.^2*nnaaCov + nnaa^2.*nnlogCov;
                  nnNdiffCov(ind2) = nnNdiffCov(ind2) + nnlog.^2*nnaaCov + nnaa^2.*nnlogCov;
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  nnaa = xx(xxend); nnaaCov  = xxCov(xxend);
                  nnlogin     = 1+(tt(ind2)-Teq)/nntau;
                  nnloginCov  = nntauCov*(tt(ind2)-Teq).^2/nntau.^4;
                  if strfind(funcN,'ln');
                     nnAfter(ind2) = nnAfter(ind2)+nnaa*log(1+(tt(ind2)-Teq)/nntau); 

                     nnlog    = log(nnlogin);
                     nnlogCov = nnloginCov./nnlogin.^2; 
                  else
                     nnAfter(ind2) = nnAfter(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/nntau); 

                     nnlog    = log10(nnlogin);
                     nnlogCov = 0.4343*nnloginCov./nnlogin.^2;
                  end
                  nnAfterCov(ind2) = nnAfterCov(ind2) + nnlog.^2*nnaaCov + nnaa^2.*nnlogCov;
               end
            end
            if ~isempty(regexpi(funcE,'(log|lng|lg2|ln2)'))
               etauName = 'tau'; 
               % check tau
               etauInd = strfind(funcE,'tau');
               if etauInd
                  etauName = funcE(etauInd:etauInd+3);
               end
               if strcmp(etauName,ntauName)
                  eetau = nntau; eetauCov = nntauCov;
               else
                  xxend = xxend+1; eetau  = xx(xxend); eetauCov = xxCov(xxend);
               end
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  eeaa = xx(xxend); eeaaCov  = xxCov(xxend);
                  % aa*log(1+(tt-Teq)/tau)
                  eelogin     = 1+(tt(ind2)-Teq)/eetau;
                  eeloginCov  = eetauCov*(tt(ind2)-Teq).^2/eetau.^4;
                  if strfind(funcE,'ln');
                     eeCopo(ind2)  = eeCopo(ind2)+eeaa*log(1+(tt(ind2)-Teq)/eetau);
                     eePost(ind2)  = eePost(ind2)+eeaa*log(1+(tt(ind2)-Teq)/eetau);
                     eeNdiff(ind2) = eeNdiff(ind2)+eeaa*log(1+(tt(ind2)-Teq)/eetau);

                     eelog    = log(eelogin);
                     eelogCov = eeloginCov./eelogin.^2;
                  else
                     eeCopo(ind2)  = eeCopo(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/eetau);
                     eePost(ind2)  = eePost(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/eetau);
                     eeNdiff(ind2) = eeNdiff(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/eetau);

                     eelog    = log10(eelogin);
                     eelogCov = 0.4343*eeloginCov./eelogin.^2;
                  end
                  eeCopoCov(ind2)  = eeCopoCov(ind2)  + eelog.^2*eeaaCov + eeaa^2.*eelogCov;
                  eePostCov(ind2)  = eePostCov(ind2)  + eelog.^2*eeaaCov + eeaa^2.*eelogCov;
                  eeNdiffCov(ind2) = eeNdiffCov(ind2) + eelog.^2*eeaaCov + eeaa^2.*eelogCov;
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  eeaa = xx(xxend); eeaaCov  = xxCov(xxend);
                  % aa*log(1+(tt-Teq)/tau)
                  eelogin     = 1+(tt(ind2)-Teq)/eetau;
                  eeloginCov  = eetauCov*(tt(ind2)-Teq).^2/eetau.^4;
                  if strfind(funcE,'ln');
                     eeAfter(ind2) = eeAfter(ind2)+eeaa*log(1+(tt(ind2)-Teq)/eetau);

                     eelog    = log(eelogin);
                     eelogCov = eeloginCov./eelogin.^2;
                  else
                     eeAfter(ind2) = eeAfter(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/eetau);

                     eelog    = log10(eelogin);
                     eelogCov = 0.4343*eeloginCov./eelogin.^2;
                  end
                  eeAfterCov(ind2) = eeAfterCov(ind2)  + eelog.^2*eeaaCov + eeaa^2.*eelogCov;
               end
            end
            if ~isempty(regexpi(funcU,'(log|lng|lg2|ln2)'))
               utauName = 'tau';
               % check tau
               utauInd = strfind(funcU,'tau');
               if utauInd
                  utauName = funcU(utauInd:utauInd+3);
               end
               if strcmp(utauName,ntauName)
                  uutau = nntau; uutauCov = nntauCov;
               elseif strcmp(utauName,etauName)
                  uutau = eetau; uutauCov = eetauCov;
               else
                  xxend = xxend+1; uutau  = xx(xxend); uutauCov = xxCov(xxend);
               end
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  uuaa = xx(xxend); uuaaCov = xxCov(xxend);
                  % aa*log(1+(tt-Teq)/tau)
                  uulogin    = 1+(tt(ind2)-Teq)/uutau;
                  uuloginCov = uutauCov*(tt(ind2)-Teq).^2/uutau.^4;
                  if strfind(funcU,'ln');
                     uuCopo(ind2)  = uuCopo(ind2)+uuaa*log(1+(tt(ind2)-Teq)/uutau); 
                     uuPost(ind2)  = uuPost(ind2)+uuaa*log(1+(tt(ind2)-Teq)/uutau); 
                     uuNdiff(ind2) = uuNdiff(ind2)+uuaa*log(1+(tt(ind2)-Teq)/uutau); 

                     uulog    = log(uulogin);
                     uulogCov = uuloginCov./uulogin.^2;
                  else
                     uuCopo(ind2)  = uuCopo(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/uutau); 
                     uuPost(ind2)  = uuPost(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/uutau); 
                     uuNdiff(ind2) = uuNdiff(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/uutau); 

                     uulog    = log10(uulogin);
                     uulogCov = 0.4343*uuloginCov./uulogin.^2;
                  end
                  uuCopoCov(ind2)  = uuCopoCov(ind2) + uulog.^2*uuaaCov + uuaa^2.*uulogCov;
                  uuPostCov(ind2)  = uuPostCov(ind2) + uulog.^2*uuaaCov + uuaa^2.*uulogCov;
                  uuNdiffCov(ind2) = uuNdiffCov(ind2) + uulog.^2*uuaaCov + uuaa^2.*uulogCov;
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  uuaa = xx(xxend); uuaaCov = xxCov(xxend);
                  % aa*log(1+(tt-Teq)/tau)
                  uulogin    = 1+(tt(ind2)-Teq)/uutau;
                  uuloginCov = uutauCov*(tt(ind2)-Teq).^2/uutau.^4;
                  if strfind(funcU,'ln');
                     uuAfter(ind2) = uuAfter(ind2)+uuaa*log(1+(tt(ind2)-Teq)/uutau); 

                     uulog    = log(uulogin);
                     uulogCov = uuloginCov./uulogin.^2;
                  else
                     uuAfter(ind2) = uuAfter(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/uutau); 

                     uulog    = log10(uulogin);
                     uulogCov = 0.4343*uuloginCov./uulogin.^2;
                  end
                  uuAfterCov(ind2)  = uuAfterCov(ind2) + uulog.^2*uuaaCov + uuaa^2.*uulogCov;
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
                  ntauName = funcN(ntauInd:ntauInd+3);
               end
               xxend = xxend+1; nntau = xx(xxend); nntauCov = xxCov(xxend);
               xxend = xxend+1;
               if eqMat(jj,1) ~= uqMat(ii,1)
                  nnaa = xx(xxend); nnaaCov = xxCov(xxend);
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
                  nnCopoCov(ind2)  = nnCopoCov(ind2)  + 1*nnaaCov + 1*nnaaexpCov;
                  nnPostCov(ind2)  = nnPostCov(ind2)  + 1*nnaaCov + 1*nnaaexpCov;
                  nnNdiffCov(ind2) = nnNdiffCov(ind2) + 1*nnaaCov + 1*nnaaexpCov;

                  nnCopo(ind2)  = nnCopo(ind2)+nnaa*(1-exp((Teq-tt(ind2))/nntau));
                  nnPost(ind2)  = nnPost(ind2)+nnaa*(1-exp((Teq-tt(ind2))/nntau));
                  nnNdiff(ind2) = nnNdiff(ind2)+nnaa*(1-exp((Teq-tt(ind2))/nntau));

               end
               if eqMat(jj,1) < uqMat(ii,1)
                  nnaa = xx(xxend); nnaaCov = xxCov(xxend);
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
                  nnAfterCov(ind2) = nnAfterCov(ind2)  + 1*nnaaCov + 1*nnaaexpCov;

                  nnAfter(ind2) = nnAfter(ind2)+nnaa*(1-exp((Teq-tt(ind2))/nntau));
               end
            end
            if ~isempty(regexpi(funcE,'(exp|ep2)'))
               etauName = 'tau'; 
               % check tau
               etauInd = strfind(funcE,'tau');
               if etauInd
                  etauName = funcE(etauInd:etauInd+3);
               end
               if strcmp(etauName,ntauName)
                  eetau = nntau; eetauCov = nntauCov;
               else
                  xxend = xxend+1; eetau  = xx(xxend); eetauCov = xxCov(xxend);
               end
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  eeaa = xx(xxend);
                  eeaaCov = xxCov(xxend);
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
                  eeCopoCov(ind2)  = eeCopoCov(ind2)  + 1*eeaaCov + 1*eeaaexpCov;
                  eePostCov(ind2)  = eePostCov(ind2)  + 1*eeaaCov + 1*eeaaexpCov;
                  eeNdiffCov(ind2) = eeNdiffCov(ind2) + 1*eeaaCov + 1*eeaaexpCov;

                  eeCopo(ind2)  = eeCopo(ind2)+eeaa*(1-exp((Teq-tt(ind2))/eetau));
                  eePost(ind2)  = eePost(ind2)+eeaa*(1-exp((Teq-tt(ind2))/eetau));
                  eeNdiff(ind2) = eeNdiff(ind2)+eeaa*(1-exp((Teq-tt(ind2))/eetau));
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  eeaa = xx(xxend);
                  eeaaCov = xxCov(xxend);
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
                  eeAfterCov(ind2)  = eeAfterCov(ind2)  + 1*eeaaCov + 1*eeaaexpCov;

                  eeAfter(ind2) = eeAfter(ind2)+eeaa*(1-exp((Teq-tt(ind2))/eetau));
               end
            end
            if ~isempty(regexpi(funcU,'(exp|ep2)'))
               utauName = 'tau';
               % check tau
               utauInd = strfind(funcU,'tau');
               if utauInd
                  utauName = funcU(utauInd:utauInd+3);
               end
               if strcmp(utauName,ntauName)
                  uutau = nntau; uutauCov = nntauCov;
               elseif strcmp(utauName,etauName)
                  uutau = eetau; uutauCov = eetauCov;
               else
                  xxend = xxend+1; uutau  = xx(xxend); uutauCov = xxCov(xxend);
               end
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  uuaa = xx(xxend);
                  uuaaCov = xxCov(xxend);
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
                  uuCopoCov(ind2)  = uuCopoCov(ind2) + 1*uuaaCov + 1*uuaaexpCov;
                  uuPostCov(ind2)  = uuPostCov(ind2) + 1*uuaaCov + 1*uuaaexpCov;
                  uuNdiffCov(ind2) = uuNdiffCov(ind2) + 1*uuaaCov + 1*uuaaexpCov;

                  uuCopo(ind2)  = uuCopo(ind2)+uuaa*(1-exp((Teq-tt(ind2))/uutau));
                  uuPost(ind2)  = uuPost(ind2)+uuaa*(1-exp((Teq-tt(ind2))/uutau));
                  uuNdiff(ind2) = uuNdiff(ind2)+uuaa*(1-exp((Teq-tt(ind2))/uutau));
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  uuaa = xx(xxend);
                  uuaaCov = xxCov(xxend);
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
                  uuAfterCov(ind2) = uuAfterCov(ind2) + 1*uuaaCov + 1*uuaaexpCov;

                  uuAfter(ind2) = uuAfter(ind2)+uuaa*(1-exp((Teq-tt(ind2))/uutau));
               end
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
                  ntauName = funcN(ntauInd:ntauInd+3);
               end
               xxend = xxend+1; nntau = xx(xxend);
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  nnaa = xx(xxend);
                  nnCopo(ind2)  = nnCopo(ind2)+nnaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/nntau)));
                  nnPost(ind2)  = nnPost(ind2)+nnaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/nntau)));
                  nnNdiff(ind2) = nnNdiff(ind2)+nnaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/nntau)));
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  nnaa = xx(xxend);
                  nnAfter(ind2) = nnAfter(ind2)+nnaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/nntau)));
               end
            end
            if regexpi(funcE,'k[0-9]{2}_\w+')
               etauName = 'tau'; 
               % check tau
               etauInd = strfind(funcE,'tau');
               if etauInd
                  etauName = funcE(etauInd:etauInd+3);
               end
               if strcmp(etauName,ntauName)
                  eetau = nntau;
               else
                  xxend = xxend+1; eetau  = xx(xxend);
               end
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  eeaa = xx(xxend);
                  eeCopo(ind2)  = eeCopo(ind2)+eeaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/eetau)));
                  eePost(ind2)  = eePost(ind2)+eeaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/eetau)));
                  eeNdiff(ind2) = eeNdiff(ind2)+eeaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/eetau)));
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  eeaa = xx(xxend);
                  eeAfter(ind2) = eeAfter(ind2)+eeaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/eetau)));
               end
            end
            if regexpi(funcU,'k[0-9]{2}_\w+')
               utauName = 'tau';
               % check tau
               utauInd = strfind(funcU,'tau');
               if utauInd
                  utauName = funcU(utauInd:utauInd+3);
               end
               if strcmp(utauName,ntauName)
                  uutau = nntau;
               elseif strcmp(utauName,etauName)
                  uutau = eetau;
               else
                  xxend = xxend+1; uutau  = xx(xxend);
               end
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  uuaa = xx(xxend);
                  uuCopo(ind2)  = uuCopo(ind2)+uuaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/uutau)));
                  uuPost(ind2)  = uuPost(ind2)+uuaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/uutau)));
                  uuNdiff(ind2) = uuNdiff(ind2)+uuaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/uutau)));
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  uuaa = xx(xxend);
                  uuAfter(ind2) = uuAfter(ind2)+uuaa*(1-2/kk*acoth(coth(0.5*kk)*exp((tt(ind2)-Teq)/uutau)));
               end
            end
         end
      end
      % rneuCopo
      rneuCopo          = rneu;
      rneuCopo(:,3:8)   = [ nn-nnCopo ee-eeCopo uu-uuCopo nnErr-sqrt(nnCopoCov) eeErr-sqrt(eeCopoCov) uuErr-sqrt(uuCopoCov) ];
      rneuCopoCell{ii}  = rneuCopo;
      % rneuPost
      rneuPost          = rneu;
      rneuPost(:,3:8)   = [ nn-nnPost ee-eePost uu-uuPost nnErr-sqrt(nnPostCov) eeErr-sqrt(eePostCov) uuErr-sqrt(uuPostCov) ];
      rneuPostCell{ii}  = rneuPost;
      % rneuPostNdiff
      rneuPostNdiff          = rneu;
      rneuPostNdiff(:,3:8)   = [ nn-nnNdiff ee-eeNdiff uu-uuNdiff nnErr-sqrt(nnNdiffCov) eeErr-sqrt(eeNdiffCov) uuErr-sqrt(uuNdiffCov) ];
      rneuPostNdiffCell{ii}  = rneuPostNdiff;
      % rneuAfter
      rneuAfter         = rneu;
      rneuAfter(:,3:8)  = [ nn-nnAfter ee-eeAfter uu-uuAfter nnErr-sqrt(nnAfterCov) eeErr-sqrt(eeAfterCov) uuErr-sqrt(uuAfterCov) ];
      rneuAfterCell{ii} = rneuAfter;
   end
end
