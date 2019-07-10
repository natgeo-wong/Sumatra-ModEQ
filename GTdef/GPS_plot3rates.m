function [ ] = GPS_plot3rates(site,x0,rate,rate_err,rchi2,wrms,w_amp,f_amp,num,TT,rneu,dflag,plot_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_plot3rates.m				        %
% plot three components of the time series with its fitting parameters		%
%										%
% INPUT:									% 
% site - 4-letter site name							%
% ----------------------------- column vectors -------------------------------- %
% --------- the order is north, east, vertical as in *.rneu files  ------------	%
% x0 - intercept of linear fit to the time series				%
% rate,rate_err - long-term rate and its associated error [mm/yr]		%
% rchi2 - reduced chi-square							%
% wrms - weighted root-mean-square residual [mm]				%
% w_amp - amplitude for white noise [mm]					%
% f_amp - amplitude for flicker noise [mm/yr^0.25]				%
% ----------------------------------------------------------------------------- %
% num - num of data points used to fit						%
% TT -  length of time period used to fit					%
% rneu = [ day time north east vert north_err east_err vert_err ] 		%
% dflag - data flag: 1 means data; 0 means outliers 				%
% dflag,day,time,north,east,vert,north_err,east_err,vert_err all column vectors	%
%                                                                               %
% first created by lfeng Thu Oct 21 23:14:57 EDT 2010				%
% added delete(figh) lfeng Mon Aug 22 19:57:15 SGT 2011				%
% last modified by lfeng Mon Aug 22 19:57:24 SGT 2011				%
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
   str_rate1 = strcat('\sigma_w = ',num2str(w_amp(ii),'%.1f'),' mm \sigma_f = ',num2str(f_amp(ii),'%.1f'),' mm/yr^{0.25} ');
   str_rate2 = strcat('R = ',num2str(rate(ii),'%.1f'),'+/-',num2str(rate_err(ii),'%.1f'),' mm/yr ',...
                      'WRMS = ',num2str(wrms(ii),'%.1f'),' mm \kappa_r^2 = ',num2str(rchi2(ii),'%.2f'));
   if rate(ii)>0
      text(0.95,0.15,{str_rate1;str_rate2},'Fontsize',10,'Horizontalalignment','Right','Units','Normalized');
   else
      text(0.05,0.15,{str_rate1;str_rate2},'Fontsize',10,'Horizontalalignment','Left','Units','Normalized');
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
delete(figh);
