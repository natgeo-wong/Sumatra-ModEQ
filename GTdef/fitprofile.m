function [ fitobj,gof ] = fitprofile(fin_name,fun_name,xrange,yrange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                fitprofile.m				        %
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
% e.g. 'Func_linear_quad(x,a,b,m,n,p,d)'			                %
%										%
% (3) xrange,yrange to constrain distance and depth                             %
%										%
% OUTPUT: 									%
% (1) fitobj - results returned in fit object					%
% (2) gof    - goodness of fit							%
%										%
% first created by lfeng Wed Nov 24 10:11:42 EST 2010				%
% last modified by lfeng Sun Nov 28 18:59:26 EST 2010				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

all_name = ls(fin_name);
all_name_cell = regexp(all_name,'\w+\.?\w+','match');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reading in %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = [];
fnum = length(all_name_cell);

for ii=1:fnum
   fname = char(all_name_cell(ii));
   fprintf(1,'.......... reading %s ...........\n',fname);
   fin = fopen(fname,'r');
   data_cell = textscan(fin,'%*f %*f %*f %*f %f %f','CommentStyle','#');	 % Delimiter default White Space
   data = [ data;cell2mat(data_cell) ];
   fclose(fin); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cleaning up data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
cftool(data(:,1),data(:,2));
%ft = fittype(fun_name);
%[ fitobj,gof ] = fit(data(:,1),data(:,2),ft);
