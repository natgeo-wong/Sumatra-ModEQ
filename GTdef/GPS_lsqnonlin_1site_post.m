function [ rneuCopoCell,rneuPostCell,rneuPostNdiffCell,rneuAfterCell ] ...
         = GPS_lsqnonlin_1site_post(rneu,eqMat,funcMat,fqMat,xx,tt0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        GPS_lsqnonlin_1site_post                             %
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
% Note: errors are kept the same                                              %
%                                                                             %
% first created by Lujia Feng Sun Oct 28 03:02:41 SGT 2012                    %
% modified funcMat lfeng Thu Apr  4 16:21:01 SGT 2013                         %
% considered all EQ have log shapes lfeng Thu May 16 14:46:58 SGT 2013        %
% added rneuAfterCell lfeng Mon Nov 18 02:33:08 SGT 2013                      %
% added time reference tt0 lfeng Wed Jan  8 12:58:10 SGT 2014                 %
% added lg2 & ep2 & corrected regexpi lfeng Thu Mar  6 10:58:55 SGT 2014      %
% added rneuPostNdiffCell lfeng Wed Mar 26 13:02:40 SGT 2014                  %
% added rneuCopoCell lfeng Sun Jun  1 19:51:54 SGT 2014                       %
% added natural log lng lfeng Wed Jul  2 11:59:18 SGT 2014                    %
% added 2nd natural log ln2 lfeng Wed Jul  2 18:27:02 SGT 2014                %
% corrected tau when N is offset while E is log lfeng Sun Jul 13 SGT 2014     %
% last modified by Lujia Feng Sun Jul 13 11:56:27 SGT 2014                    %
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

nn = rneu(:,3); 
ee = rneu(:,4); 
uu = rneu(:,5);
uqMat = unique(eqMat,'rows','stable'); % each EQ has 1 entry
uqNum = size(uqMat,1);
eqNum = size(eqMat,1);
rneuCopoCell      = cell(uqNum,1);
rneuPostCell      = cell(uqNum,1);
rneuPostNdiffCell = cell(uqNum,1);
rneuAfterCell     = cell(uqNum,1);

% base model = intercept + rate*time
xx1st = 0; 
nnBase = xx(xx1st+1) + xx(xx1st+2)*tt;
eeBase = xx(xx1st+3) + xx(xx1st+4)*tt;
uuBase = xx(xx1st+5) + xx(xx1st+6)*tt;

% seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
xx1st = 6; 
if any(fqMat)
   fqNum = size(fqMat,1);
   for ii=1:fqNum
      fSin = sin(2*pi*fqMat(ii,1).*tt); fCos = cos(2*pi*fqMat(ii,2).*tt);
      nnBase = nnBase + xx(xx1st+1)*fSin + xx(xx1st+2)*fCos;
      eeBase = eeBase + xx(xx1st+3)*fSin + xx(xx1st+4)*fCos;
      uuBase = uuBase + xx(xx1st+5)*fSin + xx(xx1st+6)*fCos;
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
      % loop through all functions
      for jj=1:eqNum
         Teq   = TeqMat(jj);
         ind2  = tt>=Teq;
         func  = funcMat(jj,:);
         ff    = reshape(func,[],3)';
         funcN = ff(1,:); funcE = ff(2,:); funcU = ff(3,:);
         % add rate changes
         if strfind(funcN,'diffrate')
            xxend = xxend+1; nndV = xx(xxend);
            nnNdiff(ind2) = nnNdiff(ind2)+nndV*(tt(ind2)-Teq);
            if eqMat(jj,1) ~= uqMat(ii,1)
               nnCopo(ind2) = nnCopo(ind2)+nndV*(tt(ind2)-Teq);
               nnPost(ind2) = nnPost(ind2)+nndV*(tt(ind2)-Teq);
            end
            if eqMat(jj,1) < uqMat(ii,1)
               nnAfter(ind2) = nnAfter(ind2)+nndV*(tt(ind2)-Teq);
            end
         end
         if strfind(funcE,'diffrate')
            xxend = xxend+1; eedV = xx(xxend);
            eeNdiff(ind2) = eeNdiff(ind2)+eedV*(tt(ind2)-Teq);
            if eqMat(jj,1) ~= uqMat(ii,1) 
               eeCopo(ind2) = eeCopo(ind2)+eedV*(tt(ind2)-Teq);
               eePost(ind2) = eePost(ind2)+eedV*(tt(ind2)-Teq);
            end
            if eqMat(jj,1) < uqMat(ii,1) 
               eeAfter(ind2) = eeAfter(ind2)+eedV*(tt(ind2)-Teq);
            end
         end
         if strfind(funcU,'diffrate')
            xxend = xxend+1; uudV = xx(xxend);
            uuNdiff(ind2) = uuNdiff(ind2)+uudV*(tt(ind2)-Teq);
            if eqMat(jj,1) ~= uqMat(ii,1) 
               uuCopo(ind2) = uuCopo(ind2)+uudV*(tt(ind2)-Teq);
               uuPost(ind2) = uuPost(ind2)+uudV*(tt(ind2)-Teq);
            end
            if eqMat(jj,1) < uqMat(ii,1) 
               uuAfter(ind2) = uuAfter(ind2)+uudV*(tt(ind2)-Teq);
            end
         end
         % add offsets    
         if ~isempty(regexpi(funcN,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcN,'k[0-9]{2}_\w+'))
            xxend = xxend+1; nnO = xx(xxend);
            nnPost(ind2)  = nnPost(ind2)  + nnO;
            nnNdiff(ind2) = nnNdiff(ind2) + nnO;
            nnAfter(ind2) = nnAfter(ind2) + nnO;
            if eqMat(jj,1) ~= uqMat(ii,1)
               nnCopo(ind2) = nnCopo(ind2) + nnO;
            end
         end
         if ~isempty(regexpi(funcE,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcE,'k[0-9]{2}_\w+'))
            xxend = xxend+1; eeO = xx(xxend);
            eePost(ind2)  = eePost(ind2)  + eeO;
            eeNdiff(ind2) = eeNdiff(ind2) + eeO;
            eeAfter(ind2) = eeAfter(ind2) + eeO;
            if eqMat(jj,1) ~= uqMat(ii,1)
               eeCopo(ind2) = eeCopo(ind2) + eeO;
            end
         end
         if ~isempty(regexpi(funcU,'(log|lng|off|exp)_\w+')) || ~isempty(regexpi(funcU,'k[0-9]{2}_\w+'))
            xxend = xxend+1; uuO = xx(xxend);
            uuPost(ind2)  = uuPost(ind2)  + uuO;
            uuNdiff(ind2) = uuNdiff(ind2) + uuO;
            uuAfter(ind2) = uuAfter(ind2) + uuO;
            if eqMat(jj,1) ~= uqMat(ii,1)
               uuCopo(ind2) = uuCopo(ind2) + uuO;
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
               xxend = xxend+1; nntau = xx(xxend);
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  nnaa = xx(xxend);
                  if strfind(funcN,'ln');
                     nnCopo(ind2)  = nnCopo(ind2)+nnaa*log(1+(tt(ind2)-Teq)/nntau); 
                     nnPost(ind2)  = nnPost(ind2)+nnaa*log(1+(tt(ind2)-Teq)/nntau); 
                     nnNdiff(ind2) = nnNdiff(ind2)+nnaa*log(1+(tt(ind2)-Teq)/nntau); 
                  else
                     nnCopo(ind2)  = nnCopo(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/nntau); 
                     nnPost(ind2)  = nnPost(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/nntau); 
                     nnNdiff(ind2) = nnNdiff(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/nntau); 
                  end
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  nnaa = xx(xxend);
                  if strfind(funcN,'ln');
                     nnAfter(ind2) = nnAfter(ind2)+nnaa*log(1+(tt(ind2)-Teq)/nntau); 
                  else
                     nnAfter(ind2) = nnAfter(ind2)+nnaa*log10(1+(tt(ind2)-Teq)/nntau); 
                  end
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
                  eetau = nntau;
               else
                  xxend = xxend+1; eetau  = xx(xxend);
               end
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  eeaa = xx(xxend);
                  if strfind(funcE,'ln');
                     eeCopo(ind2)  = eeCopo(ind2)+eeaa*log(1+(tt(ind2)-Teq)/eetau);
                     eePost(ind2)  = eePost(ind2)+eeaa*log(1+(tt(ind2)-Teq)/eetau);
                     eeNdiff(ind2) = eeNdiff(ind2)+eeaa*log(1+(tt(ind2)-Teq)/eetau);
                  else
                     eeCopo(ind2)  = eeCopo(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/eetau);
                     eePost(ind2)  = eePost(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/eetau);
                     eeNdiff(ind2) = eeNdiff(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/eetau);
                  end
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  eeaa = xx(xxend);
                  if strfind(funcE,'ln');
                     eeAfter(ind2) = eeAfter(ind2)+eeaa*log(1+(tt(ind2)-Teq)/eetau);
                  else
                     eeAfter(ind2) = eeAfter(ind2)+eeaa*log10(1+(tt(ind2)-Teq)/eetau);
                  end
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
                  uutau = nntau;
               elseif strcmp(utauName,etauName)
                  uutau = eetau;
               else
                  xxend = xxend+1; uutau  = xx(xxend);
               end
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  uuaa = xx(xxend);
                  if strfind(funcU,'ln');
                     uuCopo(ind2)  = uuCopo(ind2)+uuaa*log(1+(tt(ind2)-Teq)/uutau); 
                     uuPost(ind2)  = uuPost(ind2)+uuaa*log(1+(tt(ind2)-Teq)/uutau); 
                     uuNdiff(ind2) = uuNdiff(ind2)+uuaa*log(1+(tt(ind2)-Teq)/uutau); 
                  else
                     uuCopo(ind2)  = uuCopo(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/uutau); 
                     uuPost(ind2)  = uuPost(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/uutau); 
                     uuNdiff(ind2) = uuNdiff(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/uutau); 
                  end
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  uuaa = xx(xxend);
                  if strfind(funcU,'ln');
                     uuAfter(ind2) = uuAfter(ind2)+uuaa*log(1+(tt(ind2)-Teq)/uutau); 
                  else
                     uuAfter(ind2) = uuAfter(ind2)+uuaa*log10(1+(tt(ind2)-Teq)/uutau); 
                  end
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
               xxend = xxend+1; nntau = xx(xxend);
               xxend = xxend+1;
               if eqMat(jj,1) ~= uqMat(ii,1)
                  nnaa = xx(xxend);
                  nnCopo(ind2)  = nnCopo(ind2)+nnaa*(1-exp((Teq-tt(ind2))/nntau));
                  nnPost(ind2)  = nnPost(ind2)+nnaa*(1-exp((Teq-tt(ind2))/nntau));
                  nnNdiff(ind2) = nnNdiff(ind2)+nnaa*(1-exp((Teq-tt(ind2))/nntau));
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  nnaa = xx(xxend);
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
                  eetau = nntau;
               else
                  xxend = xxend+1; eetau  = xx(xxend);
               end
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  eeaa = xx(xxend);
                  eeCopo(ind2)  = eeCopo(ind2)+eeaa*(1-exp((Teq-tt(ind2))/eetau));
                  eePost(ind2)  = eePost(ind2)+eeaa*(1-exp((Teq-tt(ind2))/eetau));
                  eeNdiff(ind2) = eeNdiff(ind2)+eeaa*(1-exp((Teq-tt(ind2))/eetau));
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  eeaa = xx(xxend);
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
                  uutau = nntau;
               elseif strcmp(utauName,etauName)
                  uutau = eetau;
               else
                  xxend = xxend+1; uutau  = xx(xxend);
               end
               xxend = xxend+1; 
               if eqMat(jj,1) ~= uqMat(ii,1)
                  uuaa = xx(xxend);
                  uuCopo(ind2)  = uuCopo(ind2)+uuaa*(1-exp((Teq-tt(ind2))/uutau));
                  uuPost(ind2)  = uuPost(ind2)+uuaa*(1-exp((Teq-tt(ind2))/uutau));
                  uuNdiff(ind2) = uuNdiff(ind2)+uuaa*(1-exp((Teq-tt(ind2))/uutau));
               end
               if eqMat(jj,1) < uqMat(ii,1)
                  uuaa = xx(xxend);
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
      rneuCopo(:,3:5)   = [ nn-nnCopo ee-eeCopo uu-uuCopo ];
      rneuCopoCell{ii}  = rneuCopo;
      % rneuPost
      rneuPost          = rneu;
      rneuPost(:,3:5)   = [ nn-nnPost ee-eePost uu-uuPost ];
      rneuPostCell{ii}  = rneuPost;
      % rneuPostNdiff
      rneuPostNdiff          = rneu;
      rneuPostNdiff(:,3:5)   = [ nn-nnNdiff ee-eeNdiff uu-uuNdiff ];
      rneuPostNdiffCell{ii}  = rneuPostNdiff;
      % rneuAfter
      rneuAfter         = rneu;
      rneuAfter(:,3:5)  = [ nn-nnAfter ee-eeAfter uu-uuAfter ];
      rneuAfterCell{ii} = rneuAfter;
   end
end
