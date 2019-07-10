function [] = regrid(fin_name,fout_name,range,dx,dy,method,grdtype,title)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                   regrid.m                                      %
% Matlab program to regrid grd files						  %
% INPUT									  	  %
% (1) fin_name  - input file name                                            	  %
% (2) fout_name - output file name                                            	  %
% (3) range     - gmt style [lonmin lonmax latmin latmax]			  %
% (4) dx        - x/lon increment                                                 %
% (5) dy        - y/lat increment                                                 %
% (6) method    - interpolation method used in interp2()                          %
%                 including nearest,linear,spline,cubic				  %
% (7) grdtype   - 0 grid registration; 1 pixel/node registration		  %
% (8) title     - title for the output grd file					  %
%										  %
% OUTPUT									  %
% a new grd file								  %
%									  	  %
% first created based on Andy's code by Lujia Feng Wed Jun 30 07:28:18 EDT 2010   %
% last modified by Lujia Feng Wed Jun 30 07:57:26 EDT 2010			  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in input grid
[X1,Y1,Z1,header1]=grdread(fin_name);

% range of plot
lonmin = range(1); lonmax = range(2); 
latmin = range(3); latmax = range(4);

X=[lonmin:dx:lonmax]';
Y=[latmin:dy:latmax];
lonmax = X(end);
latmax = Y(end);
[Xi,Yi]=meshgrid(X,Y);

% regrid to new interpolated values
Zfinal=interp2(X1,Y1,Z1,Xi,Yi,method);

% write new grd file
zmin= min(min(Zfinal));
zmax= max(max(Zfinal));
grdwrite(Zfinal,[lonmin lonmax latmin latmax zmin zmax grdtype],fout_name,title);
%  mesh(X,Y,Zfinal)
%  view(-40,30)
