function [ ] = GPS_plot3rates_subplot(figh,row,col,x0,y0,ww,hh,dx,dy,ind,period,site,rate_x0,rate,rneu,dflag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot time series and best-fitting line in a subplot				%
%										%
% INPUT:									% 
% figh - figure handle for plotting						%
% row,col - subplot features							%
% x0 - left boundary of subplot to left edge of figure				%
% y0 - top boundary of subplot to top edge of figure				%
% ww - width of each subplot							%
% hh - height of each subplot							%
% dx - horizontal space between two subplots 					%
% dy - vertical space between two subplots					%
% x0,y0,ww,hh,dx,dy all in ratio						%
% values suggested								%
% (3,3,0.1,0.1,?,?,0.05,0.08)                                            	%
% ----------------------------------------------------------------------------- %
% ind  - subplot index for this site						%
% site - 4-letter site name							%
% ----------------------------- column vectors -------------------------------- %
% --------- the order is north, east, vertical as in *.rneu files  ------------	%
% rate_x0 - intercept of linear fit to the time series				%
% rate - long-term rate and its associated error [mm/yr]			%
% ----------------------------------------------------------------------------- %
% rneu = [ day time north east vert north_err east_err vert_err ] 		%
% dflag - data flag: 1 means data; 0 means outliers 				%
% dflag,day,time,north,east,vert,north_err,east_err,vert_err all column vectors	%
%                                                                               %
% first created by lfeng Sat Mar  5 14:49:02 EST 2011				%
% last modified by lfeng Sun Mar  6 03:13:50 EST 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------- set up figure ------------------------------------
set(0,'CurrentFigure',figh);
% ii - row number, jj - column number
% note: ind2sub is column-wise, while subplot is row-wise, thus switch ii & jj
[ jj ii ] = ind2sub([row col],ind);
lef = x0+(jj-1)*(ww+dx);
bot = 1-(y0+hh+(ii-1)*(hh+dy));
subplot(row,col,ind);
%set(gca,'Position',[ lef bot ww hh ],'FontName','helvetica','FontSize',9,'Box','on',...				% position = [ left bottom width height ]
%        'XTick',[2005 2007 2009 2011],'TickLength',[0.02 0.025],'XMinorTick','on','YMinorTick','on');% default TickLength is [ 0.01 0.025 ]
set(gca,'Position',[ lef bot ww hh ],'FontName','helvetica','FontSize',10,'Box','on',...				% position = [ left bottom width height ]
        'TickLength',[0.02 0.025],'XMinorTick','on','YMinorTick','on');		% default TickLength is [ 0.01 0.025 ]
hold on;

%------------------------ prepare info for plotting -----------------------------
ind = find(dflag); data = rneu(ind,:);
time = data(:,2);  xrange = [ time(1) time(end) ];
north = data(:,3); north_err = data(:,6);
east  = data(:,4); east_err  = data(:,7);
vert  = data(:,5); vert_err  = data(:,8);
% to plot 3 rates together; not change vert
vert_x0 = rate_x0(3);   vert_rate = rate(3);
vmax = max(vert);       yoffset = 0; 
% overlap east above vert
east = east+vmax+yoffset;       east_x0 = rate_x0(2)+vmax+yoffset;   
east_rate = rate(2);    
emax = max(east);       yoffset = 0;
% north on the top
north = north+emax+yoffset; north_x0 = rate_x0(1)+emax+yoffset;  
north_rate = rate(1);
yrange = [ min(vert) max(north) ];
%yrange = [ -100 400 ];

%------------------------------- plot -------------------------------------------
% plot data
errorbar(time,north,north_err,'.g');
errorbar(time,east,east_err,'.g');
errorbar(time,vert,vert_err,'.g');

% plot best-fitting line
fn = @(x) north_x0+north_rate*x; 
%funh = ezplot(fn,xrange);		% will plot x lable too
%set(funh,'Color','r','LineWidth',1.5);
% or 
[ x,y ] = fplot(fn,xrange);	% fplot only accept a linespec
plot(x,y,'Color','r','LineWidth',1.5);
fe = @(x) east_x0+east_rate*x; 
%funh = ezplot(fe,xrange);
%set(funh,'Color','k','LineWidth',1.5);
[ x,y ] = fplot(fe,xrange);	% fplot only accept a linespec
plot(x,y,'Color','k','LineWidth',1.5);
fu = @(x) vert_x0+vert_rate*x; 
%funh = ezplot(fu,xrange);
%set(funh,'Color','b','LineWidth',1.5);
[ x,y ] = fplot(fu,xrange);	% fplot only accept a linespec
plot(x,y,'Color','b','LineWidth',1.5);

% title
title(site,'FontSize',12);
% set ranges
if ~isempty(period), xlim(period); else xlim(xrange); end
ylim(yrange);
% label
if jj==1
    ylabel('Relative Position [mm]','FontSize',10);
end
if ii==row  
    xlabel('Year','FontSize',10); 
end;
hold off;
