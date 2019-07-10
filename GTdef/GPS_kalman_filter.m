function [ rneuNew ] = GPS_kalman_filter(filterType,frneuName,...
                       errScale,svecScale,timeScale,x0,P0,figFlag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              GPS_kalman_filter.m                              %
% filter GPS time series using kalman filter                                    %
%                                                                               %
% INPUT:                                                                        %
% filterType - type of filter                                                   %
%            = 'kalman_rate'                                                    %
%            = 'kalman_rateannual'                                              %
%            = 'kalman_fixedpnt_rate'                                           %
%            = 'kalman_fixedpnt_rateannual'                                     %
%            = 'kalman_RTS_rate'                                                %
%            = 'kalman_RTS_rateannual'                                          %
%            = 'kalman_RTS_rateseason'                                          %
% frneuName  - input *.rneu file                                                %
% errScale   - measurement error scale                                          %
% svecScale  - state vector error scale                                         %
% timeScale  - time scale                                                       %
% figFlag    - figure visibility                                                %
%            = 'on'                                                             %
%            = 'off'                                                            %
%                                                                               %
% OUTPUT:                                                                       %
% rneuNew   - new filtered rneu data                                            %
%                                                                               %
% first created by Lujia Feng Tue Apr 28 18:06:56 SGT 2015                      %
% added saving rates lfeng Mon May  4 16:27:21 SGT 2015                         %
% added errScale lfeng Tue May  5 17:44:00 SGT 2015                             %
% added filterType lfeng Wed May  6 11:35:30 SGT 2015                           %
% added x0, P0, timeScale lfeng Thu May  7 18:30:22 SGT 2015                    %
% added rateannual lfeng Tue May 26 17:19:45 SGT 2015                           %
% fixed unit problem with pred lfeng Fri May 29 08:55:26 SGT 2015               %
% output prediction without seasonal signals lfeng Fri May 29 09:19:01 SGT 2015 %
% last modified by Lujia Feng Fri May 29 17:27:19 SGT 2015                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'-------------------------------------------------------\n');
fprintf(1,'input file is %s\n',frneuName);

[ rneu ] = GPS_readrneu(frneuName,1,0.001); % change from m to mm
[ ~,basename,~ ] = fileparts(frneuName);

tt    = rneu(:,2)*timeScale;
%tt    = rneu(:,2) - rneu(1,2);
nn    = rneu(:,3);
ee    = rneu(:,4);
uu    = rneu(:,5);
nnErr = rneu(:,6);
eeErr = rneu(:,7);
uuErr = rneu(:,8);

nnnos = [];
eenos = [];
uunos = [];
if strcmp(filterType,'kalman_rate')
   [ nnnew,nnbb,nnvv ] = GPS_kalman_rate(tt,nn,nnErr,errScale,svecScale,x0,P0);
   [ eenew,eebb,eevv ] = GPS_kalman_rate(tt,ee,eeErr,errScale,svecScale,x0,P0);
   [ uunew,uubb,uuvv ] = GPS_kalman_rate(tt,uu,uuErr,errScale,svecScale,x0,P0);
elseif strcmp(filterType,'kalman_fixedpnt_rate')
   [ nnnew,nnbb,nnvv ] = GPS_kalman_fixedpnt_rate(tt,nn,nnErr,errScale,svecScale,x0,P0);
   [ eenew,eebb,eevv ] = GPS_kalman_fixedpnt_rate(tt,ee,eeErr,errScale,svecScale,x0,P0);
   [ uunew,uubb,uuvv ] = GPS_kalman_fixedpnt_rate(tt,uu,uuErr,errScale,svecScale,x0,P0);
elseif strcmp(filterType,'kalman_RTS_rate')
   [ nnnew,nnbb,nnvv ] = GPS_kalman_RTS_rate(tt,nn,nnErr,errScale,svecScale,x0,P0);
   [ eenew,eebb,eevv ] = GPS_kalman_RTS_rate(tt,ee,eeErr,errScale,svecScale,x0,P0);
   [ uunew,uubb,uuvv ] = GPS_kalman_RTS_rate(tt,uu,uuErr,errScale,svecScale,x0,P0);
elseif strcmp(filterType,'kalman_rateannual')
   [ nnnew,nnnos,nnbb,nnvv,nnAA,nnBB ] = GPS_kalman_rateannual(tt,nn,nnErr,errScale,svecScale,x0,P0);
   [ eenew,eenos,eebb,eevv,eeAA,eeBB ] = GPS_kalman_rateannual(tt,ee,eeErr,errScale,svecScale,x0,P0);
   [ uunew,uunos,uubb,uuvv,uuAA,uuBB ] = GPS_kalman_rateannual(tt,uu,uuErr,errScale,svecScale,x0,P0);
elseif strcmp(filterType,'kalman_fixedpnt_rateannual')
   [ nnnew,nnnos,nnbb,nnvv,nnAA,nnBB ] = GPS_kalman_fixedpnt_rateannual(tt,nn,nnErr,errScale,svecScale,x0,P0);
   [ eenew,eenos,eebb,eevv,eeAA,eeBB ] = GPS_kalman_fixedpnt_rateannual(tt,ee,eeErr,errScale,svecScale,x0,P0);
   [ uunew,uunos,uubb,uuvv,uuAA,uuBB ] = GPS_kalman_fixedpnt_rateannual(tt,uu,uuErr,errScale,svecScale,x0,P0);
elseif strcmp(filterType,'kalman_RTS_rateannual')
   [ nnnew,nnnos,nnbb,nnvv,nnAA,nnBB ] = GPS_kalman_RTS_rateannual(tt,nn,nnErr,errScale,svecScale,x0,P0);
   [ eenew,eenos,eebb,eevv,eeAA,eeBB ] = GPS_kalman_RTS_rateannual(tt,ee,eeErr,errScale,svecScale,x0,P0);
   [ uunew,uunos,uubb,uuvv,uuAA,uuBB ] = GPS_kalman_RTS_rateannual(tt,uu,uuErr,errScale,svecScale,x0,P0);
elseif strcmp(filterType,'kalman_RTS_rateseason')
   [ nnnew,nnnos,nnbb,nnvv,nnAA,nnBB,nnCC,nnDD ] = GPS_kalman_RTS_rateseason(tt,nn,nnErr,errScale,svecScale,x0,P0);
   [ eenew,eenos,eebb,eevv,eeAA,eeBB,nnCC,nnDD ] = GPS_kalman_RTS_rateseason(tt,ee,eeErr,errScale,svecScale,x0,P0);
   [ uunew,uunos,uubb,uuvv,uuAA,uuBB,nnCC,nnDD ] = GPS_kalman_RTS_rateseason(tt,uu,uuErr,errScale,svecScale,x0,P0);
else
   error('GPS_kalman_filter ERROR: %s is not right!',filterType);
end

tt   = tt/timeScale;
%tt   = tt + rneu(1,2);
nnvv = nnvv*timeScale;
eevv = eevv*timeScale;
uuvv = uuvv*timeScale;

% save the predictions
scaleStr = [ '_merr' num2str(errScale,'%06.1f') '_svec' num2str(svecScale,'%05.2f') '_time' num2str(timeScale,'%05.1f') ];
foutName = [ basename '_' filterType scaleStr '_pred.rneu' ]; 
rneuNew      = rneu;
rneuNew(:,3) = nnnew;
rneuNew(:,4) = eenew;
rneuNew(:,5) = uunew;
GPS_saverneu(foutName,'w',rneuNew,0.001); % save to mm

% save the prediction without seasonal signals
if ~isempty(regexpi(filterType,'(season|annual)'))
   foutName = [ basename '_' filterType scaleStr '_noss.rneu' ]; 
   rneuNew      = rneu;
   rneuNew(:,3) = nnnos;
   rneuNew(:,4) = eenos;
   rneuNew(:,5) = uunos;
   GPS_saverneu(foutName,'w',rneuNew,0.001); % save to mm
end

% save the rates
foutName = [ basename '_' filterType scaleStr '_svec.rneu' ]; 
rneuRate        = rneu;
rneuRate(:,3)   = nnvv;
rneuRate(:,4)   = eevv;
rneuRate(:,5)   = uuvv;
rneuRate(:,6)   = nnbb;
rneuRate(:,7)   = eebb;
rneuRate(:,8)   = uubb;
GPS_saverneu(foutName,'w',rneuRate,0.001); % save to mm

figh = figure('Visible',figFlag);

subplot(6,1,1);
plot(tt,nn,'go'); hold on
if ~isempty(nnnos)
   plot(tt,nnnos,'ro');
end
plot(tt,nnnew,'k','LineWidth',2);
titleName = [ basename '_' filterType scaleStr ];
titleName = strrep(titleName,'_','\_');
title(titleName);
%plot(get(gca,'Xlim'),[0 0]);

subplot(6,1,2);
plot(tt(2:end),nnvv(2:end),'b'); hold on;
%plot(get(gca,'Xlim'),[ 2  2],'k','LineWidth',2);
%plot(get(gca,'Xlim'),[-2 -2],'k','LineWidth',2);

subplot(6,1,3);
plot(tt,ee,'go'); hold on
if ~isempty(eenos)
   plot(tt,eenos,'ro');
end
plot(tt,eenew,'k','LineWidth',2); 

subplot(6,1,4);
plot(tt(2:end),eevv(2:end),'b'); hold on;

subplot(6,1,5);
plot(tt,uu,'go'); hold on
if ~isempty(uunos)
   plot(tt,uunos,'ro');
end
plot(tt,uunew,'k','LineWidth',2); 

subplot(6,1,6);
plot(tt(2:end),uuvv(2:end),'b'); hold on;

MfigName  = [ basename '_' filterType scaleStr '_pred.fig'  ];
if verLessThan('matlab','8.4.0')
    saveFigure(figh,MfigName);
else
    savefig(figh,MfigName);
end
figName  = [ basename '_' filterType scaleStr '_pred.png'  ];
print(figh,'-dpng',figName);
figName  = [ basename '_' filterType scaleStr '_pred.ps'  ];
print(figh,'-depsc',figName);

if strfind(filterType,'annual')
  figh = figure('Visible',figFlag);

  subplot(3,1,1);
  plot(tt(2:end),nnAA(2:end),'b'); hold on;
  plot(tt(2:end),nnBB(2:end),'r');

  subplot(3,1,2);
  plot(tt(2:end),eeAA(2:end),'b'); hold on;
  plot(tt(2:end),eeBB(2:end),'r');

  subplot(3,1,3);
  plot(tt(2:end),uuAA(2:end),'b'); hold on;
  plot(tt(2:end),uuBB(2:end),'r');

  MfigName  = [ basename '_' filterType scaleStr '_seas.fig'  ];
  if verLessThan('matlab','8.4.0')
      saveFigure(figh,MfigName);
  else
      savefig(figh,MfigName);
  end
  figName  = [ basename '_' filterType scaleStr '_seas.png'  ];
  print(figh,'-dpng',figName);
  figName  = [ basename '_' filterType scaleStr '_seas.ps'  ];
  print(figh,'-depsc',figName);
end

if strfind(filterType,'season')
  figh = figure('Visible',figFlag);

  subplot(3,1,1);
  plot(tt(2:end),nnAA(2:end),'b'); hold on;
  plot(tt(2:end),nnBB(2:end),'r');
  plot(tt(2:end),nnCC(2:end),'g');
  plot(tt(2:end),nnDD(2:end),'y');

  subplot(3,1,2);
  plot(tt(2:end),eeAA(2:end),'b'); hold on;
  plot(tt(2:end),eeBB(2:end),'r');
  plot(tt(2:end),nnCC(2:end),'g');
  plot(tt(2:end),nnDD(2:end),'y');

  subplot(3,1,3);
  plot(tt(2:end),uuAA(2:end),'b'); hold on;
  plot(tt(2:end),uuBB(2:end),'r');
  plot(tt(2:end),nnCC(2:end),'g');
  plot(tt(2:end),nnDD(2:end),'y');

  MfigName  = [ basename '_' filterType scaleStr '_seas.fig'  ];
  if verLessThan('matlab','8.4.0')
      saveFigure(figh,MfigName);
  else
      savefig(figh,MfigName);
  end
  figName  = [ basename '_' filterType scaleStr '_seas.png'  ];
  print(figh,'-dpng',figName);
  figName  = [ basename '_' filterType scaleStr '_seas.ps'  ];
  print(figh,'-depsc',figName);
end

fprintf(1,'-------------------------------------------------------\n');
