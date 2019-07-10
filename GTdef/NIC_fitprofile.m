function [ ] = NIC_fitprofile(fin_name,xrange,yrange)

% e.g. NIC_fitprofile('*.profile,[0 160],[-100 0])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              NIC_fitprofile.m				        %
% read one or multiple *.profile files						%
% fit a user-defined function to the average profile				%
%										%
% INPUT:                                                                        %
% (1) fin_name: profile file(s) 						%
% one file e.g. 'ABC.profile' or multiple files e.g. 'A*.profile'		%
% Do not use ? in fin_name							%
% Profile file format is							%
% 1    2    3   4    5      6  							%
% lon  lat  xx  yy   dis   zz							%
% lon,lat - geographic location of interpolating points	  			%
% xx,yy   - local location of interpolating points		  		%
% dis     - distance to [lon0,lat0]				  		%
% zz      - elevation for topography & bathymetry or depth for EQs		%
% But only read in dis & zz     						%
%										%
% (2) fun_name: fit function      						%
% e.g. 'Func_linear_quad(x,a,b,m,n,p,d)'				        %
%										%
% (3) xrange,yrange [km] to constrain distance and depth                        %
% xrange = [0 160]; yrange = [-100 0]						%
%										%
% OUTPUT: 									%
% (1) fitobj - results returned in fit object					%
% (2) gof    - goodness of fit							%
%										%
% modified based on fitprofile.m lfeng Sun Nov 28 18:56:37 EST 2010		%
% last modified by lfeng Thu Dec  2 00:47:32 EST 2010				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

all_name = ls(fin_name);
all_name_cell = regexp(all_name,'\w+\.?\w+','match');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reading in %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = [];
fnum = length(all_name_cell);

for ii=1:fnum
   fname = char(all_name_cell(ii));
%   fprintf(1,'.......... reading %s ...........\n',fname);
   fin = fopen(fname,'r');
   data_cell = textscan(fin,'%*f %*f %*f %*f %f %f','CommentStyle','#');	 % Delimiter default White Space
   data = [ data;cell2mat(data_cell) ];
   fclose(fin); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cleaning up data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove nan values
logic_ind = ~isnan(data(:,2));
data = data(logic_ind,:);
% convert [m] to [km] for distance
data(:,1) = data(:,1)*1e-3;
% constrain distance
if ~isempty(xrange)
    logic_ind = data(:,1)>=xrange(1) & data(:,1)<=xrange(2);
    data = data(logic_ind,:);
end
% constrain depth 
if ~isempty(yrange)
    logic_ind = data(:,2)>=yrange(1) & data(:,2)<=yrange(2);
    data = data(logic_ind,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fitting data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open fit toolbox to test
%cftool(data(:,1),data(:,2));
% linear & quadratic
% fix sea level b = -4.5 km (the average value of Middle American Trench)
% fix d @ 80 km
ft = fittype('Func_linear_quad(x,a,b,m,n,d)','problem',{'b','d'});

%% free d find global minimum near 40 km, but not reasonable
%opt = fitoptions('Method','NonlinearLeastSquares','Startpoint',[fitobj1.a fitobj1.m fitobj1.n fitobj1.d]);
%ft = fittype('Func_linear_quad(x,a,b,m,n,d)','problem','b','options',opt);
%[ fitobj2,gof2 ] = fit(data(:,1),data(:,2),ft,'problem',-4.5);
%fitobj2
%gof2

%% exponential is not very suitable
%opt = fitoptions('Method','NonlinearLeastSquares','Startpoint',[-3.8 -6.88e-4 -3.71 0.02118]);
%ft = fittype('Func_exp(x,a,b,c,d)');
%[ fitobj3,gof3 ] = fit(data(:,1),data(:,2),ft,opt);
%fitobj3
%gof3


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting data & fit results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create a figure without poping up the window
figh = figure('Visible','off','PaperType','usletter');
datah = plot(data(:,1),data(:,2),'.m'); hold on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Saving fit results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fmodel = fopen('NIC_fitprofile.out','w');
fprintf(fmodel,'#(1) x<=d: a*x+b (2) x>d: m*x^2+n*x+p p=a*d+b-m*d^2-n*d\n#(1)a (2)b (3)m (4)n (5)p (6)d (7)sse (8)r2 (9)def (10)adj_r2 (11)rmse\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Saving function points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xx = 0:160;

bend = 40:10:90;
num = length(bend);
for ii=1:num
    % fit data
    [ fitobj,gof ] = fit(data(:,1),data(:,2),ft,'problem',{-4.5 bend(ii)});
    pp = fitobj.a*fitobj.d+fitobj.b-fitobj.m*fitobj.d*fitobj.d-fitobj.n*fitobj.d;
    fitobj
    gof
    % plot
    fh = plot(fitobj);
    % save model
    fprintf(fmodel,'%f  %f  %f  %f  %f  %f\t%f  %f  %f  %f  %f\n',...
           fitobj.a,fitobj.b,fitobj.m,fitobj.n,pp,fitobj.d,gof.sse,gof.rsquare,gof.dfe,gof.adjrsquare,gof.rmse);
    % save points
    yy = feval(fitobj,xx);		% note: xx is row vector;  y1 is column vector
    fpnt_name = [ 'NIC_dis160km_dp100km_bend' num2str(bend(ii),'%2d') 'km.points' ];
    fpnt = fopen(fpnt_name,'w');
    fprintf(fpnt,'#(1) x<=d: a*x+b (2) x>d: m*x^2+n*x+p p=a*d+b-m*d^2-n*d\n#(1)a (2)b (3)m (4)n (5)p (6)d   (7)sse (8)r2 (9)def (10)adj_r2 (11) rmse\n');
    fprintf(fpnt,'#%f  %f  %f  %f  %f  %f\t%f  %f  %f  %f  %f\n',fitobj.a,fitobj.b,fitobj.m,fitobj.n,pp,fitobj.d,gof.sse,gof.rsquare,gof.dfe,gof.adjrsquare,gof.rmse);
    fprintf(fpnt,'%8.1f %10.3f\n',[ xx;yy' ]);
    fclose(fpnt);
end

% finish plot
xlabel('Distance to Trench [km]'); ylabel('Depth [km]');
title('Subduction Interface Undearneath Nicoya','fontsize',12);
hold off;
print(figh,'-depsc','NIC_fitprofile.ps');
% close files
fclose(fmodel);
