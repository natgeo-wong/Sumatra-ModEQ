function [ figh,axnh,axeh,axuh ] = GPS_plotNrneu(figName,figFlag,...
         rneuCell,lineCell,markCell,sizeCell,colorCell,eqCell,eqlinCell,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        GPS_plotNrneu.m                           %
% plot N rneu data sets overlaying on each other                   %
%                                                                  %	
% INPUT:                                                           %
% figName  - figure name with or without extenstion                %
% figFlag  - show figure or not                                    %
% Note: figure will be saved according to extention                %
%   figName without extension or figName='' means no figure output %
% rneuCell - cells of rneu                                         %
%   e.g. { rneu1; rneu2; rneu3 }                                   %
%   each rneu has a dayNum*8 matrix to store data                  %
%          = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]           %
% lineCell - specify line style                                    %
%   e.g. { '-'; '--'; ':'; '-.'; 'none' }                          %
% markCell - specify marker symbol                                 %
%   e.g. { 'o'; '+'; '*'; 'x'; '.'; 'v'; 'errorbar' }              %
% sizeCell - specify marker size                                   %
%   e.g. { 2; 5; 10 }                                              %
% colorCell- specify marker color by short name, long name and rgb %
%   e.g. { 'g'; 'red'; [0.6 0.6 0.6] }                             %
%   if two colors specified like [0.6 0.6 0.6; 0.8,0.8,0.8]        %
%   1st color for errorbar and 2nd color for marker;               %
%   otherwise, the same one color is used for both                 %
% eqCell   - earthquake time datasets                              %
%   e.g. { eqMat1; eqMat2; eqMat3 }                                %
%   eqMat1 = [ Deq Teq ]                 (eqNum*2)                 %
% eqlinCell- specify line style & color for EQ lines               %
%   e.g. { '-r'; '--' }                                            %
% scaleOut - scale to meter in output rneu, fitsum files           %
%   only used for writing out unit, not for scaling data           %
%                                                                  %
% OUTPUT:                                                          %
% 1 plot with NEU 3 subplots                                       %
% a fig file is also automatically saved                           %
%                                                                  %
% first created by Lujia Feng Mon May 13 14:58:35 SGT 2013         %
% generalized this script lfeng Wed Nov 27 13:50:49 SGT 2013       %
% added figFlag lfeng Tue Dec  3 12:19:12 SGT 2013                 %
% save to matlab *.fig file too lfeng Tue Dec  3 16:58:32 SGT 2013 %
% added eqCell lfeng Tue Feb 18 13:33:10 SGT 2014                  %
% added axnh, axeh, and axuh lfeng Mon Mar 24 10:40:28 SGT 2014    %
% added version check for saveFigure & savefig lfeng Jan 22 2015   %
% used verLessThan lfeng Fri Jan 23 17:51:54 SGT 2015              %
% added path to *.fig file lfeng Sat Feb 21 00:57:13 SGT 2015      %
% last modified by Lujia Feng Tue Feb 24 12:46:43 SGT 2015         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rneuNum  = length(rneuCell);
lineNum  = length(lineCell);
markNum  = length(markCell);
sizeNum  = length(sizeCell);
colorNum = length(colorCell);

ext = [];
if isempty(figName)
    basename = [];
else
    [ dirname,basename,ext ] = fileparts(figName);
    if isempty(dirname)
       MfigName = [ basename '.fig' ];
    else
       MfigName = [ dirname '/' basename '.fig' ];
    end
    % replace '_' with '\_'
    basename = strrep(basename,'_','\_');
end

figh = figure('Visible',figFlag);
labelFontSize  = 14;

% north component
axnh = subplot(3,1,1);
for ii=1:rneuNum
    rneu = rneuCell{ii};
    if isempty(rneu), continue; end   % skip when rneu is []
    if ii>lineNum  
       linestyle = 'none'; % default mark is circle
    else
       linestyle = lineCell{ii};
    end
    if ii>markNum  
       mark = 'o'; % default mark is circle
    else
       mark = markCell{ii};
    end
    if ii>sizeNum  
       marksize = 5; % default mark is circle
    else
       marksize = sizeCell{ii};
    end
    if ii>colorNum  
       clr = 'g'; % default color is green
    else
       clr = colorCell{ii};
    end
    if strcmp(mark,'errorbar')
        errorbar(rneu(:,2),rneu(:,3),rneu(:,6),'LineStyle',linestyle,'Color',clr(1,:),...
        'Marker','o','MarkerSize',marksize,'MarkerFaceColor',clr(end,:),'MarkerEdgeColor',clr(end,:)); hold on;
    else
        plot(rneu(:,2),rneu(:,3),'LineStyle',linestyle,'Color',clr(1,:),...
        'Marker',mark,'MarkerSize',marksize,'MarkerFaceColor',clr(end,:),'MarkerEdgeColor',clr(end,:)); hold on;
    end
end
for ii=1:length(eqCell)
    eqMat = eqCell{ii};
    for jj=1:size(eqMat,1)
        Teq = eqMat(jj,2);
        plot([Teq Teq],ylim,eqlinCell{ii});
    end
end
set(gca,'XMinorTick','on','YMinorTick','on');
title(gca,[ basename ' North' ],'FontSize',labelFontSize); hold off

% east component
axeh = subplot(3,1,2);
for ii=1:rneuNum
    rneu = rneuCell{ii};
    if isempty(rneu), continue; end   % skip when rneu is []
    if ii>lineNum  
       linestyle = 'none'; % default mark is circle
    else
       linestyle = lineCell{ii};
    end
    if ii>markNum  
       mark = 'o'; % default mark is circle
    else
       mark = markCell{ii};
    end
    if ii>sizeNum  
       marksize = 5; % default mark is circle
    else
       marksize = sizeCell{ii};
    end
    if ii>colorNum  
       clr = 'g'; % default color is green
    else
       clr = colorCell{ii};
    end
    if strcmp(mark,'errorbar')
        errorbar(rneu(:,2),rneu(:,4),rneu(:,7),'LineStyle',linestyle,'Color',clr(1,:),...
        'Marker','o','MarkerSize',marksize,'MarkerFaceColor',clr(end,:),'MarkerEdgeColor',clr(end,:)); hold on;
    else
        plot(rneu(:,2),rneu(:,4),'LineStyle',linestyle,'Color',clr(1,:),...
        'Marker',mark,'MarkerSize',marksize,'MarkerFaceColor',clr(end,:),'MarkerEdgeColor',clr(end,:)); hold on;
    end
end
for ii=1:length(eqCell)
    eqMat = eqCell{ii};
    for jj=1:size(eqMat,1)
        Teq = eqMat(jj,2);
        plot([Teq Teq],ylim,eqlinCell{ii});
    end
end
switch scaleOut
    case 1
        ylabel(gca,'Relative Position (m)','FontSize',labelFontSize);
    case 0.01
        ylabel(gca,'Relative Position (cm)','FontSize',labelFontSize);
    case 0.001
        ylabel(gca,'Relative Position (mm)','FontSize',labelFontSize);
    otherwise
        ylabel(gca,'Relative Position','FontSize',labelFontSize);
end
set(gca,'XMinorTick','on','YMinorTick','on');
title(gca,[ basename ' East' ],'FontSize',labelFontSize); hold off

% up component
axuh = subplot(3,1,3);
for ii=1:rneuNum
    rneu = rneuCell{ii};
    if isempty(rneu), continue; end   % skip when rneu is []
    if ii>lineNum  
       linestyle = 'none'; % default mark is circle
    else
       linestyle = lineCell{ii};
    end
    if ii>markNum  
       mark = 'o'; % default mark is circle
    else
       mark = markCell{ii};
    end
    if ii>sizeNum  
       marksize = 5; % default mark is circle
    else
       marksize = sizeCell{ii};
    end
    if ii>colorNum  
       clr = 'g'; % default color is green
    else
       clr = colorCell{ii};
    end
    if strcmp(mark,'errorbar')
        errorbar(rneu(:,2),rneu(:,5),rneu(:,8),'LineStyle',linestyle,'Color',clr(1,:),...
        'Marker','o','MarkerSize',marksize,'MarkerFaceColor',clr(end,:),'MarkerEdgeColor',clr(end,:)); hold on;
    else
        plot(rneu(:,2),rneu(:,5),'LineStyle',linestyle,'Color',clr(1,:),...
        'Marker',mark,'MarkerSize',marksize,'MarkerFaceColor',clr(end,:),'MarkerEdgeColor',clr(end,:)); hold on;
    end
end
for ii=1:length(eqCell)
    eqMat = eqCell{ii};
    for jj=1:size(eqMat,1)
        Teq = eqMat(jj,2);
        plot([Teq Teq],ylim,eqlinCell{ii});
    end
end
set(gca,'XMinorTick','on','YMinorTick','on');
xlabel(gca,'Time (years)','FontSize',labelFontSize);
title(gca,[ basename ' Vertical' ],'FontSize',labelFontSize); hold off

% save to a file
if ~isempty(ext)
    if verLessThan('matlab','8.4.0')
        saveFigure(figh,MfigName);
    else
        savefig(figh,MfigName);
    end
    %savefig(figh,MfigName);
    if strcmp(ext,'.ps')
        print(figh,'-depsc',figName);
    elseif strcmp(ext,'.png')
        print(figh,'-dpng',figName);
    else
        error('GPS_plotNrneu ERROR: plots can be only saved to png or ps formats!');
    end
end

if strcmp(figFlag,'off');
    close all;
end
