% matlab script to merge multiple grids to a single mixed resolution plot
clear;
 % [XBox,YBox,ZBox,headerBox]=grdread('grid_crica.grd');
  % 30 second land 
  [XTopo,YTopo,ZTopo,headerTopo]=grdread('SRTM_land.grd');
  % 2minute everything
  [XBase,YBase,ZBase,headerBase]=grdread('SOLOMON3.grd');


lonmin=145. ; lonmax=165.0 ; %# Longitude range of plots
latmin=-15  ; latmax=0.  ; %# Latitude range of plots

dx=0.05; % low resolution
dx=0.01; % half resolution 
%dx=0.005; % full resolution
dy=dx;

X=[lonmin:dx:lonmax]';
Y=[latmin:dy:latmax];
[Xi,Yi]=meshgrid(X,Y);
% regrid to new interpolated values
   ZTopoi=interp2(XTopo,YTopo,ZTopo,Xi,Yi);
   ZBasei=interp2(XBase,YBase,ZBase,Xi,Yi);
step=0;
npts=length(X)*length(Y);
Zfinal=zeros(length(Y),length(X));
for i=1:length(X)
   for j=1:length(Y)
	      Ztemp=ZTopoi(j,i); % read land 
	        if isnan(Ztemp); Ztemp=ZBasei(j,i); % read base 
	          if isnan(Ztemp); Ztemp=NaN;  % fill with NaNs
		  end
	        end
           Zfinal(j,i)=Ztemp;
   end
end

  zmin= min((min(Zfinal))');
  zmax= max((max(Zfinal))');
       grdwrite(Zfinal,[lonmin lonmax latmin latmax zmin zmax 0],'SOLOMON4.grd','Merged elevation')
%  mesh(X,Y,Zfinal)

%  mesh(XBase,YBase,ZBase)
%  hold on
%  mesh(XTopo,YTopo,ZTopo)
%  mesh(XTrench,YTrench,ZTrench)
%  mesh(XBox,YBox,ZBox)
%  view(-40,30)
