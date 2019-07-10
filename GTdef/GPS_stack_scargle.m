function [ ppU,probU,levelU,fcU ] = GPS_stack_scargle(fsiteName,fexpName,figFlag,winFlag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_stack_scargle.m                                %
% Compute, stack, plot the normalized Lomb-Scargle power spectrum/periodogram   %
% and corresponding probabilities for unevenly-spaced GPS data                  %
%                                                                               %
% INPUT:                                                                        %
% fsiteName - a *.sites GPS location file                                       %
% 1      2              3              4                                        %
% Site	 Lon		Lat	       Height                                   %
% ABGS   99.387520914   0.220824642    236.2533                                 %
% *.rneu file format                                                            %               
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
% fexpName - example file name with 'SITE'                                      %
%          = 'SITE_clean_sunda.rneu'                                            %
% figFlag  = 'on' turn on figure visibility                                     %
%          = 'off' turn off figure visibility                                   %
% winFlag  - windowing flag                                                     %
%          = 'hanning', 'hamming', or 'blackman'                                %
%         if empty, no windowing is applied                                     %
%                                                                               %
% OUTPUT:                                                                       %
% a *.ps figure                                                                 %
%                                                                               %
% first created by Lujia Feng Tue Nov 12 17:03:15 SGT 2013                      %
% changed suffixName to fexpName lfeng Tue May 26 12:49:39 SGT 2015             %
% added NaN value check lfeng Tue May 26 13:19:41 SGT 2015                      %
% last modified by Lujia Feng Tue May 26 13:19:51 SGT 2015                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in *.site
[ siteList,loc ] = GPS_readsites(fsiteName);
siteNum = length(siteList);
if isempty(winFlag)
    figName = [ 'GPS_stack_scargle.ps' ];
else
    figName = [ 'GPS_stack_scargle_' winFlag '.ps' ];
end

% parameters
year2day = 365.25;
ofac  = 1;
hifac = 1;
prob0 = 0.001;
signif = [ 0.5 0.9 0.99 0.999 ]';
sigNum = length(signif);
colorList = [ 0 1 0; 1 0 0; 0.8 0 0.8; 0.5 0.5 0 ];

% sampling frequency 
T  = 5;
fb = 1/T;
df = fb/ofac;
dT = 1/year2day;
fc = 0.5/dT; % 1 cpy
fh = fc*hifac;
ff = [ df:df:fh ]';

% loop through stations to read *.rneu
psumN = 0; psumE = 0; psumU = 0;
for ii=1:siteNum
    fprintf(1,'-------------------------------------------------------\n');
    % read in rneu data
    siteName  = siteList{ii};
    frneuName = strrep(fexpName,'SITE',siteName);
    fprintf(1,'input file is %s\n',frneuName);
    [ rneu ] = GPS_readrneu(frneuName,[],[]);
    %--------- day ---------
    %tt = rneu(:,2);
    %tt = (tt - rneu(1,2))*year2day;
    %--------- year ---------
    tt = rneu(:,2) - rneu(1,2);
    nn = rneu(:,3);
    ee = rneu(:,4);
    uu = rneu(:,5);
    
    % do Lomb-Scargle transformation
    if sum(isnan(nn))>0
       fprintf(1,'GPS_stack_scargle WARNING: skipped the N component of %s\n',siteName);
    else
       [ ~,ppN,probN,levelN,fcN ] = LombScargle_periodogram(tt,nn,ofac,hifac,signif,winFlag,ff);
    end
    if sum(isnan(ee))>0
       fprintf(1,'GPS_stack_scargle WARNING: skipped the E component of %s\n',siteName);
    else
       [ ~,ppE,probE,levelE,fcE ] = LombScargle_periodogram(tt,ee,ofac,hifac,signif,winFlag,ff);
    end
    if sum(isnan(uu))>0
       fprintf(1,'GPS_stack_scargle WARNING: skipped the U component of %s\n',siteName);
    else
       [ ~,ppU,probU,levelU,fcU ] = LombScargle_periodogram(tt,uu,ofac,hifac,signif,winFlag,ff);
    end

    % sum up
    psumN = psumN+ppN;
    psumE = psumE+ppE;
    psumU = psumU+ppU;
end
ppN = psumN/siteNum; indN = ppN>levelN(end);
ppE = psumE/siteNum; indE = ppE>levelE(end);
ppU = psumU/siteNum; indU = ppU>levelU(end);

fprintf(1,'Strong periods (year) for N:\n');
fprintf(1,'%f\n',1./ff(indN));
fprintf(1,'Strong periods (year) for E:\n');
fprintf(1,'%f\n',1./ff(indE));
fprintf(1,'Strong periods (year) for U:\n');
fprintf(1,'%f\n',1./ff(indU));

fprintf(1,'Strong frequency (cpy) for N:\n');
fprintf(1,'%f\n',ff(indN));
fprintf(1,'Strong frequency (cpy) for E:\n');
fprintf(1,'%f\n',ff(indE));
fprintf(1,'Strong frequency (cpy) for U:\n');
fprintf(1,'%f\n',ff(indU));
%[ ffNList,TNList ] = GPS_scargle_peak(ff,fcN,probN,prob0);
%[ ffEList,TEList ] = GPS_scargle_peak(ff,fcE,probE,prob0);
%[ ffUList,TUList ] = GPS_scargle_peak(ff,fcU,probU,prob0);

% -2 power function
%--------- day ---------
% W0 = P0/f0^2 = 1
%P0    = 1e-4;
%f0    = sqrt(P0);
%alpha = -2;
%ffFun = [ 1e-3:1e-4:1e-2 1e-2:1e-3:1e-1  1e-1:1e-2:1e0 1e0:1e-1:1e1 ];
%%%%%%yy = @(ffFun) 10*log10(P0)+10*log10(1+(f0/ffFun)^alpha)-10*alpha*log10(ffFun);
%yy    = P0.*(ffFun.^alpha+f0.^alpha);

% plot
figh = figure('Visible',figFlag);
% North power spectrum
subplot(1,3,1);
plot(ff,ppN); hold on;
plot(ff(indN),ppN(indN),'or');
%hdl = plot(ffFun,yy);
%set(hdl,'Color','red', 'LineStyle', '--', 'LineWidth', 3);
set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'XTick',[1e-1 1 10 100]);
for ii=1:sigNum
    hdN(ii) = plot(ff([1 end]),[levelN(ii) levelN(ii)],'Color',colorList(ii,:),'LineStyle','--');
end
xlim([0 fcN]); 
legend(hdN,num2str(signif(1)),num2str(signif(2)),num2str(signif(3)),num2str(signif(4)));
ylabel('Power');
title('North');

% East power spectrum
subplot(1,3,2);
plot(ff,ppE); hold on;
plot(ff(indE),ppE(indE),'or');
%hdl = plot(ffFun,yy);
%set(hdl,'Color','red', 'LineStyle', '--', 'LineWidth', 3);
set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'XTick',[1e-1 1 10 100]);
for ii=1:sigNum
    hdE(ii) = plot(ff([1 end]),[levelE(ii) levelE(ii)],'Color',colorList(ii,:),'LineStyle','--');
end
xlim([0 fcE]);
legend(hdE,num2str(signif(1)),num2str(signif(2)),num2str(signif(3)),num2str(signif(4)));
title('East');

% Up power spectrum
subplot(1,3,3);
plot(ff,ppU); hold on;
plot(ff(indU),ppU(indU),'or');
%hdl = plot(ffFun,yy);
%set(hdl,'Color','red', 'LineStyle', '--', 'LineWidth', 3);
set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'XTick',[1e-1 1 10 100]);
for ii=1:sigNum
    hdU(ii) = plot(ff([1 end]),[levelU(ii) levelU(ii)],'Color',colorList(ii,:),'LineStyle','--');
end
xlim([0 fcU]);
legend(hdU,num2str(signif(1)),num2str(signif(2)),num2str(signif(3)),num2str(signif(4)));
title('Vertical');

annotation('textbox',[ 0 0.9 1 0.1 ],'String',[ ' Stacked Lomb-Scargle Power Spectrum' ],'Fontsize',12,...
           'EdgeColor','None','VerticalAlignment','Top','Horizontalalignment','Center');

print(figh,'-depsc',figName);
fprintf(1,'-------------------------------------------------------\n');
