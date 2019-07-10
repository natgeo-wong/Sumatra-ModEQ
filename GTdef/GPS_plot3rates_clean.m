function [ ] = GPS_plot3rates_clean(site,x0,rate,rate_err,num,TT,rneu,dflag,plot_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         GPS_plot3rates_clean.m				%	
% plot three components of the time series with its fitting parameters		%
% This is a clean version of GPS_plot3rates.m  					%
% Does not write out rchi2,wrms,w_amp,f_amp					%
%										%
% INPUT:									% 
% site - 4-letter site name							%
% ----------------------------- column vectors -------------------------------- %
% --------- the order is north, east, vertical as in *.rneu files  ------------	%
% x0 - intercept of linear fit to the time series				%
% rate,rate_err - long-term rate and its associated error [mm/yr]		%
% ----------------------------------------------------------------------------- %
% num - num of data points used to fit						%
% TT -  length of time period used to fit					%
% rneu = [ day time north east vert north_err east_err vert_err ] 		%
% dflag - data flag: 1 means data; 0 means outliers 				%
% dflag,day,time,north,east,vert,north_err,east_err,vert_err all column vectors	%
%                                                                               %
% first created by lfeng Fri Apr  1 22:06:50 EDT 2011				%
% simplified from GPS_plot3rates.m lfeng Fri Apr  1 22:07:14 EDT 2011		%
% last modified by lfeng Fri Apr  1 23:28:42 EDT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% data
ind = find(dflag); data = rneu(ind,:);
% outliers
ind = find(dflag==0); out = rneu(ind,:);
out_num = size(out,1);
% xrange
xrange = [ rneu(1,2) rneu(end,2) ];

% create a figure without poping up the window
figh = figure('Visible','off','PaperType','usletter');

% plot the data first then trim or add new features as needed
for ii=1:3
   subplot(3,1,ii);
   % plot data used
   keeph = errorbar(data(:,2),data(:,ii+2),data(:,ii+5),'.g'); hold on;
   % plot outliers
   if ~isempty(out)
      outh  = errorbar(out(:,2),out(:,ii+2),out(:,ii+5),'.r');
   end
   % create a linear function
   fn = @(x) x0(ii)+rate(ii)*x; 
   fplot(fn,xrange,'color','k');

   set(gca,'PlotBoxAspectRatio',[5 1 1]);		% fix current axis [gca] aspect ratio; disable default stretch
   % legend
   str_data = strcat(num2str(num,'%d'),' days  ',num2str(TT,'%.2f'),' yrs'); 
   if ~isempty(out)
      str_out = strcat(num2str(out_num,'%d'),' outliers'); 
      legh = legend([keeph,outh],str_data,str_out);
   else
      out_num = 0;
      legh = legend(keeph,str_data);
   end
   if rate(ii)>=0
      set(legh,'Location','NorthWest','Fontsize',10);
   else
      set(legh,'Location','NorthEast','Fontsize',10);
   end
   legend('Boxoff');
   % position to place text
   str_rate = strcat('R = ',num2str(rate(ii),'%.1f'),'+/-',num2str(rate_err(ii),'%.1f'),' mm/yr');
   if rate(ii)>0
      text(0.95,0.15,{str_rate},'Fontsize',10,'Horizontalalignment','Right','Units','Normalized');
   else
      text(0.05,0.15,{str_rate},'Fontsize',10,'Horizontalalignment','Left','Units','Normalized');
   end
   % labels
   xlabel('Year'); ylabel('Relative Position [mm]');
   % set xrange
   xlim(xrange);
   % title
   switch ii
      case 1
         title(strcat(site,' North'),'fontsize',11);
      case 2
         title(strcat(site,' East'),'fontsize',11);
      case 3
         title(strcat(site,' Vertical'),'fontsize',11);
   end
   hold off;
end

print(figh,'-depsc',plot_name);
%saveas(h,'.eps');
