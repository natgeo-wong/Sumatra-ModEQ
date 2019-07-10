function [ ] = GPS_scargle(frneuName,figExt,figFlag,winFlag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GPS_scargle.m                                   %
% Compute and plot the normalized Lomb-Scargle power spectrum/periodogram       %
% and corresponding probabilities for unevenly-spaced GPS data                  %
%                                                                               %
% INPUT:                                                                        %
% frneuName - a *.rneu file                                                     %
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
% figExt  - figure extention                                                    %
%         = '.ps' or '.png'                                                     %
%         = if empty do not save to a file                                      %
% figFlag = 'on' turn on figure visibility                                      %
%         = 'off' turn off figure visibility                                    %
% winFlag - windowing flag                                                      %
%         = 'hanning', 'hamming', or 'blackman'                                 %
%         if empty, no windowing is applied                                     %
%                                                                               %
% OUTPUT:                                                                       %
% a *.png figure                                                                %
%                                                                               %
% References:                                                                   %
% (1) Davis, J. L., B. P. Wernicke, and M. E. Tamisiea (2012),                  %
% On seasonal signals in geodetic time series,                                  %
% J. Geophys. Res., 117, doi:10.1029/2011JB008690.                              %
%                                                                               %
% first created by Lujia Feng Mon Apr  1 12:16:52 SGT 2013                      %
% added figFlag lfeng Fri Apr  5 20:10:45 SGT 2013                              %
% changed frequency to log scale lfeng Thu Oct 24 19:31:43 SGT 2013             %
% added spectral fit & modified plots lfeng Fri Nov  1 11:35:49 SGT 2013        %
% used year instead of day for time lfeng Tue May 26 11:05:38 SGT 2015          %
% added figExt lfeng Tue May 26 11:32:24 SGT 2015                               %
% changed Y axis to log scale lfeng Tue May 26 11:43:36 SGT 2015                %
% last modified by Lujia Feng Tue May 26 19:07:43 SGT 2015                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'-------------------------------------------------------\n');
fprintf(1,'input file is %s\n',frneuName);

[ rneu ] = GPS_readrneu(frneuName,[],[]);
[ ~,basename,~ ] = fileparts(frneuName);
figName  = [ basename '_lomb' figExt ];
foutName = [ basename '_lomb.txt' ]; 
MfigName = [ basename '_lomb.fig' ];
basename = strrep(basename,'_','\_');

%--------- day ---------
%year2day = 365.25;
%tt = rneu(:,2);
%tt = (tt - rneu(1,2))*year2day;
%--------- year ---------
tt = rneu(:,2) - rneu(1,2);

nn = rneu(:,3);
ee = rneu(:,4);
uu = rneu(:,5);

ofac  = 1;
hifac = 1;
prob0 = 0.001;
signif = [ 0.9 0.99 0.999 ]';
sigNum = length(signif);
colorList = [ 0 1 0; 1 0 0; 0.8 0 0.8 ];

% do Lomb-Scargle transformation
[ ffN,ppN,probN,levelN,fcN ] = LombScargle_periodogram(tt,nn,ofac,hifac,signif,winFlag);
[ ffNList,TNList ] = GPS_scargle_peak(ffN,fcN,probN,prob0);
[ ffE,ppE,probE,levelE,fcE ] = LombScargle_periodogram(tt,ee,ofac,hifac,signif,winFlag);
[ ffEList,TEList ] = GPS_scargle_peak(ffE,fcE,probE,prob0);
[ ffU,ppU,probU,levelU,fcU ] = LombScargle_periodogram(tt,uu,ofac,hifac,signif,winFlag);
[ ffUList,TUList ] = GPS_scargle_peak(ffU,fcU,probU,prob0);

%--------- day ---------
% -2 power function
% W0 = P0/f0^2 = 1
%P0    = 1e-4;
%f0    = sqrt(P0);
%alpha = -2;
%ff    = [ 1e-3:1e-4:1e-2 1e-2:1e-3:1e-1  1e-1:1e-2:1e0 1e0:1e-1:1e1 ];
%%%%%yy = @(ff) 10*log10(P0)+10*log10(1+(f0/ff)^alpha)-10*alpha*log10(ff);
%yy    = P0.*(ff.^alpha+f0.^alpha);
%--------- year ---------
% Equation 16 in ref1
% parameters need to be adjusted
sigma = 100;
beta  = 1.0/(5.5/12); % 5.5 months
ff    = [ 10e-1:1e-2:1e0 1e0:1e-1:1e1 1e1:1e0:1e2 ];
yy    = sigma^2*beta./((2*pi.*ff).^2+beta^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figh = figure('Visible',figFlag);
% North power spectrum
subplot(2,3,1);
%plot(ffN,ppN,'o'); hold on;
plot(ffN,ppN); hold on;
%hdl = plot(ff,yy);
%set(hdl,'Color','red', 'LineStyle', '--', 'LineWidth', 3);
set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'XTick',[1e-1 1 10 100]);
for ii=1:sigNum
    hdN(ii) = plot(ffN([1 end]),[levelN(ii) levelN(ii)],'Color',colorList(ii,:),'LineStyle','--');
end
xlim([0 fcN]);
legend(hdN,num2str(signif(1)),num2str(signif(2)),num2str(signif(3)));
ylabel('Power');
title('North');

% North probability
subplot(2,3,4);
plot(ffN,probN); hold on;
set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'XTick',[1e-1 1 10 100]);
text(0.9,0.5,{'Frequency';'[cpy]';num2str(ffNList)},'Fontsize',12,...
     'Horizontalalignment','Right','VerticalAlignment','Top','Units','Normalized');
text(0.9,0.9,{'Periods';'[yrs]';num2str(TNList)},'Fontsize',12,...
     'Horizontalalignment','Right','VerticalAlignment','Top','Units','Normalized');
xlim([0 fcN]); 
ylabel('Probability');
xlabel('Frequency [cpy]');

% East power spectrum
subplot(2,3,2);
%plot(ffE,ppE,'o'); hold on;
plot(ffE,ppE); hold on;
%hdl = plot(ff,yy);
%set(hdl,'Color','red', 'LineStyle', '--', 'LineWidth', 3);
set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'XTick',[1e-1 1 10 100]);
for ii=1:sigNum
    hdE(ii) = plot(ffE([1 end]),[levelE(ii) levelE(ii)],'Color',colorList(ii,:),'LineStyle','--');
end
xlim([0 fcE]);
legend(hdE,num2str(signif(1)),num2str(signif(2)),num2str(signif(3)));
title('East');

% East probability
subplot(2,3,5);
plot(ffE,probE); hold on;
set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'XTick',[1e-1 1 10 100]);
text(0.9,0.5,{'Frequency';'[cpy]';num2str(ffEList)},'Fontsize',12,...
     'Horizontalalignment','Right','VerticalAlignment','Top','Units','Normalized');
text(0.9,0.9,{'Periods';'[yrs]';num2str(TEList)},'Fontsize',12,...
     'Horizontalalignment','Right','VerticalAlignment','Top','Units','Normalized');
xlim([0 fcE]); 
xlabel('Frequency [cpy]');

% Up power spectrum
subplot(2,3,3);
%plot(ffU,ppU,'o'); hold on;
plot(ffU,ppU); hold on;
%hdl = plot(ff,yy);
%set(hdl,'Color','red', 'LineStyle', '--', 'LineWidth', 3);
set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'XTick',[1e-1 1 10 100]);
for ii=1:sigNum
    hdU(ii) = plot(ffU([1 end]),[levelU(ii) levelU(ii)],'Color',colorList(ii,:),'LineStyle','--');
end
xlim([0 fcU]);
legend(hdU,num2str(signif(1)),num2str(signif(2)),num2str(signif(3)));
title('Vertical');

% Up probability
subplot(2,3,6);
plot(ffU,probU); hold on;
set(gca,'XScale','log');
set(gca,'YScale','log');
set(gca,'XTick',[1e-1 1 10 100]);
text(0.9,0.5,{'Frequency';'[cpy]';num2str(ffUList)},'Fontsize',12,...
     'Horizontalalignment','Right','VerticalAlignment','Top','Units','Normalized');
text(0.9,0.9,{'Periods';'[yrs]';num2str(TUList)},'Fontsize',12,...
     'Horizontalalignment','Right','VerticalAlignment','Top','Units','Normalized');
xlim([0 fcU]); 
xlabel('Frequency [cpy]');

annotation('textbox',[ 0 0.9 1 0.1 ],'String',[ basename ' Lomb-Scargle Power Spectrum' ],'Fontsize',12,...
           'EdgeColor','None','VerticalAlignment','Top','Horizontalalignment','Center');
annotation('textbox',[ 0 0.4 1 0.1 ],'String',[ basename ' False-alarm Probabilities' ],'Fontsize',12,...
           'EdgeColor','None','VerticalAlignment','Top','Horizontalalignment','Center');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lomb = [ ffN ppN ppE ppU ];
fout = fopen(foutName,'w');
fprintf(fout,'# 1                 2        3        4\n');
fprintf(fout,'# Frequency [cpy]   PowerN   PowerE   PowerU\n');
fprintf(fout,'%12.5f %12.5f %12.5f %12.5f\n',lomb');
fclose(fout);

if ~isempty(figExt)
    if verLessThan('matlab','8.4.0')
        saveFigure(figh,MfigName);
    else
        savefig(figh,MfigName);
    end
    if strcmp(figExt,'.ps')
        print(figh,'-depsc',figName);
    elseif strcmp(figExt,'.png')
        print(figh,'-dpng',figName);
    else
        error('GPS_scargle ERROR: plots can be only saved to png or ps formats!');
    end
end

fprintf(1,'-------------------------------------------------------\n');



function [ ffList,TList ] = GPS_scargle_peak(ff,fc,prob,prob0)
% false-alarm probability < prob0 is real
% ignore frequency below Nyquist frequency
ind = prob<prob0 & ff<fc;
% ignore the total length of time series
ind(1) = 0;
num = length(ff);
ffSum  = 0;
ffNum  = 0;
ffList = [];
flag   = 'off';
for ii=1:num
    if ind(ii)==0 && strcmp(flag,'on')
       ffList = [ ffList; ffSum/ffNum ];
       ffSum = 0; ffNum = 0;
       flag = 'off';
    end
    if ind(ii)==1
       ffNum = ffNum + 1;
       ffSum = ffSum + ff(ii);
       flag = 'on';
    end
end

% convert frequency to periods 
T     = double(int32(100./ffList))*0.01;
TList = sort(unique(T),'descend');

% convert frequency to two decimal digits
ff     = double(int32(100.*ffList))*0.01;
ffList = sort(unique(ff),'descend');
