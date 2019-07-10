function [ ] = GPS_plotall(finName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              GPS_plotall.m                             %    
% Plot 3 components of all stations all on 3 plots separately            %
%                                                                        %	
% INPUT:                                                                 %
% finName - *.files                                                      %
% 1    2             3               4                 5                 %
% Site Site_Loc_File Data_File       Fit_Param_File    EQ_File           %
% ABGS SMT_IGS.sites ABGS_noise.rneu ABGS_noise.fitsum mb_ABGS_GPS.eqs   %
% BTET SMT_IGS.sites BTET_noise.rneu BTET_noise.fitsum mb_BTET_GPS.eqs   %
% 6                                                                      %
% Noise_File                                                             %
% ABGS_res1site.noisum                                                   %
% BTET_res1site.noisum                                                   %
%                                                                        %
% Note: file order can be different, because it uses extension to        %
%       identify file types                                              %
%                                                                        %
% OUTPUT:                                                                %
% 3 plots                                                                %
%                                                                        %
% first created by Lujia Feng Thu Jul 19 18:10:41 SGT 2012               %
% modified GPS_readrneu lfeng Tue Oct 23 18:34:43 SGT 2012               %
% last modified by Lujia Feng Tue Oct 23 18:34:57 SGT 2012               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% time period
ttRange = [2002 2012];
% offset multiplier between time series
offsetM = 3;
% horizontal shift for text names
offsetT = 0.2;
textT   = ttRange(2)+offsetT;

%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%
fprintf(1,'\n.......... reading %s ...........\n',finName);
[ siteList,~,datfList,~,~,~ ] = GPS_readfiles(finName);
siteNum = size(siteList,1);

fprintf(1,'\n.......... reading individual sites ...........\n');
rneuList = {};                          % list of rneu data for all stations [Cell]
for ii=1:siteNum
    % read data 
    name = datfList{ii};
    [ rneu ] = GPS_readrneu(name,[],0.001);
    rneuList = [ rneuList; rneu ];      % rneuList [Cell]
end

%%%%%%%%%%%%%%%%% plot files %%%%%%%%%%%%%%%%%
% generate siteNum colors from blue to red
colorMat = jet(siteNum);

% plot the 1st time series
site = siteList{1};
rneu = rneuList{1};
% offsets
tt = rneu(:,2); nn = rneu(:,3);
ee = rneu(:,4); uu = rneu(:,5);
offsetN = std(nn);
offsetE = std(ee);
offsetU = std(uu); 
curN = offsetM*offsetN;
curE = offsetM*offsetE;
curU = offsetM*offsetU;
nn = nn + curN;
ee = ee + curE; 
uu = uu + curU;

%cc = colorMat(1,:);
cc = [ 0 0 0 ];
% north component
fighN = figure('Visible','off','PaperType','usletter');
plot(tt,nn,'Color',cc,'Marker','o','LineStyle','none'); hold on
text(textT,curN,site); title('North'); xlim(ttRange);
% east component
fighE = figure('Visible','off','PaperType','usletter');
plot(tt,ee,'Color',cc,'Marker','o','LineStyle','none'); hold on
text(textT,curE,site); title('East');  xlim(ttRange);
% vertical component
fighU = figure('Visible','off','PaperType','usletter');
plot(tt,uu,'Color',cc,'Marker','o','LineStyle','none'); hold on
text(textT,curU,site); title('Vertical'); xlim(ttRange);
%axesN = get(fighN,'CurrentAxes');
%axesE = get(fighE,'CurrentAxes');
%axesU = get(fighU,'CurrentAxes');
curN = curN + offsetM*offsetN;
curE = curE + offsetM*offsetE;
curU = curU + offsetM*offsetU;

% plot the other time series
for ii=2:siteNum
    site = siteList{ii};
    rneu = rneuList{ii};
    tt = rneu(:,2); nn = rneu(:,3);
    ee = rneu(:,4); uu = rneu(:,5);
    offsetN = std(nn);
    offsetE = std(ee);
    offsetU = std(uu); 
    textN = curN + offsetM*offsetN;
    textE = curE + offsetM*offsetE;
    textU = curU + offsetM*offsetU;
    nn = rneu(:,3) + textN; 
    ee = rneu(:,4) + textE; 
    uu = rneu(:,5) + textU;
    curN = textN + offsetM*offsetN;
    curE = textE + offsetM*offsetE;
    curU = textU + offsetM*offsetU;
    cc = colorMat(ii,:);  
    % north component
    figure(fighN);
    plot(tt,nn,'Color',cc,'Marker','o','LineStyle','none');
    text(textT,textN,site); ylim([0 curN]);
    % east component
    figure(fighE);
    plot(tt,ee,'Color',cc,'Marker','o','LineStyle','none');
    text(textT,textE,site); ylim([0 curE]);
    % up component
    figure(fighU);
    plot(tt,uu,'Color',cc,'Marker','o','LineStyle','none');
    text(textT,textU,site); ylim([0 curU]);   
end
hold(get(fighN,'CurrentAxes'),'off'); 
hold(get(fighE,'CurrentAxes'),'off'); 
hold(get(fighU,'CurrentAxes'),'off');

% save figures
[ ~,basename,~ ] = fileparts(finName);
figName = [ basename '_N.ps' ];
print(fighN,'-depsc',figName);
figName = [ basename '_E.ps' ];
print(fighE,'-depsc',figName);
figName = [ basename '_U.ps' ];
print(fighU,'-depsc',figName);
