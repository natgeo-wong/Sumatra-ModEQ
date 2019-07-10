function [ figh ] = GPS_plot_config(row,col,x0,y0,ww,hh,dx,dy)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% configure plots for plotting sites together					%
%										%
% INPUT:									% 
% row,col - subplots								%
% x0 - left boundary of subplot to left edge of figure				%
% y0 - top boundary of subplot to top edge of figure				%
% ww - width of each subplot							%
% hh - height of each subplot							%
% dx - horizontal space between two subplots 					%
% dy - vertical space between two subplots					%
% x0,y0,ww,hh,dx,dy all in ratio						%
%										%
% values suggested								%
% (3,3,0.1,0.05,0.25,0.25,0.05,0.05)                                            %
%										%
% first created by lfeng Sat Mar  5 14:10:33 EST 2011				%
% last modified by lfeng Sat Mar  5 16:27:09 EST 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------- create a figure without poping up the window -------------------%
% features not used: Units normalized; PaperPosition not affected when using ps
figh = figure('Visible','off','PaperType','usletter');

%------------------- set up each subplot ------------------%
for ii=1:row
   for jj=1:col
      ind = (ii-1)*col+jj;
      subplot(row,col,ind);
      lef = x0+(jj-1)*(ww+dx);
      bot = y0+hh+(ii-1)*(hh+dy);
      set(gca,'Position',[ lef bot ww hh ],'FontName','helvetica','FontSize',10);		% position = [ left bottom width height ]
   end
end

%print(figh,'-depsc','test.ps');
%saveas(h,'.eps');
