function [ pars,dipPatchNum,dipout ] = ...
         MESH_form_dip(coastFile,slabFile,slabRange,dipPatchSize,lon0,lat0,str0,pars0,lb,ub)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              MESH_form_dip				  %
% generate a 2D profile along dip according to points on the slab         %
%									  %
% INPUT:                                                                  %
% coastFile - coastline file [optional]                                   %
% slabFile  - slab contour file                                           %
% e.g.   > -620 contour -Z-620                                            %
%        107.30  -4.50   -620.00                                          %
%        107.30  -4.50   -620.00                                          %
%        > -620 contour -Z-620                                            %
%        107.34  -4.52   -620.00                                          %
%        107.33  -4.52   -620.00                                          %
% slabRange    - used to trim slab [m]                                    %
%              = [ xMin xMax; yMin yMax; zMin zMax ]                      %
%                depth positive down                                      %
% dipPatchSize - patch size along dip [m]                                 %
% lon0,lat0    - origin used for local cartesian system                   %
%         e.g. = [ 99.969549 -4.229013 ]                                  %
% str0         - strike used for cross-section                            %
%                strke is CW from N                                       %
% pars0        - initial values for linear_poly3 fit                      %
% lb,ub        - lower and upper bounds for linear_poly3 fit              %
%                                                                         %
% OUTPUT:								  %
% dipFile - *.dip file                                                    %
%           1   2           3     4     5      6                          %
%           dip fault_name  dip   z1    z2     rows                       %
% pars        - parameters used for linear_poly3 fit                      %
% dipPatchNum - number of patches along dip                               %
% dipout      = [ dipList z1List z2List ]                                 %
% Note: depth positive down                                               %
%									  %
% first created by Lujia Feng Mon Nov  3 15:05:10 SGT 2014                %
% corrected a typo using coastFile lfeng Fri Jun 12 13:07:58 SGT 2015     %
% last modified by Lujia Feng Fri Jun 12 13:08:19 SGT 2015                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------ slab input ------------------%
% read in slab
if ~exist(slabFile,'file'), error('MESH_form_dip ERROR: %s does not exist!',slabFile); end
[ slablon0,slablat0,slabzz0 ] = GMT_readcont(slabFile);
slabzz0 = -1e3*slabzz0;     % convert depth negative & km in slab file to depth positive and meter

% convert lonlat to local cartesian system
% xx - from east  to along-dip
% yy - from north to along-strike
rot = str0-360;
[ slabxx0,slabyy0 ] = latlon_to_xy(slablon0,slablat0,lon0,lat0,-rot);

% trim slab according to slabRange
xMin    = slabRange(1,1);
xMax    = slabRange(1,2); 
yMin    = slabRange(2,1);
yMax    = slabRange(2,2); 
zMin    = slabRange(3,1);
zMax    = slabRange(3,2); 
ind1    = slabxx0>=xMin & slabxx0<=xMax & slabyy0>=yMin & slabyy0<=yMax & slabzz0>=zMin & slabzz0<=zMax;
ind2    = isnan(slabxx0);
slabind = ind1 | ind2; % has to keep NaN to separate contour segments
slabxx  = slabxx0(slabind);
slabyy  = slabyy0(slabind);
slabzz  = slabzz0(slabind);

% remove NaN values
nanind  = ~isnan(slabzz);
xdata   = slabxx(nanind);
zdata   = slabzz(nanind);

% plot slab to check
figure;
plot3(slabxx0,slabyy0,-slabzz0,'b'); hold on;
plot3(slabxx,slabyy,-slabzz,'r');
% read in coastline
if ~isempty(coastFile)
   if ~exist(coastFile,'file'), error('MESH_form_dip ERROR: %s does not exist!',coastFile); end
   fin       = fopen(coastFile,'r');
   coastCell = textscan(fin,'%f %f','CommentStyle','#');       % Delimiter default white space
   coast     = cell2mat(coastCell);
   coastlon  = coast(:,1);
   coastlat  = coast(:,2);
   fclose(fin);
   %[ coastxx,coastyy ] = LL2ckmd(coastlon,coastlat,lon0,lat0,-rot);
   [ coastxx,coastyy ] = latlon_to_xy(coastlon,coastlat,lon0,lat0,-rot);
   coastzz = zeros(size(coastxx));
   plot3(coastxx,coastyy,coastzz,'k');
end


%------------------ form dip ------------------%
pars  = lsqcurvefit(@linear_poly3,pars0,xdata,zdata,lb,ub);
aa = pars(1);
bb = 0;
ll = pars(2);
mm = pars(3);
nn = pars(4);
dd = pars(5);
fprintf(1,'dip fits:\naa = %f,dip = %f\nll = %f\nmm = %f\nnn = %f\ndd = %f\n',aa,atand(aa),ll,mm,nn,dd);
pp = bb + (aa-nn)*dd - mm*dd^2 - ll*dd^3;
dp = atand(aa); % dip for the linear part
x2 = 0;
z2 = linear_poly3(pars,x2);
z1List  = [];
z2List  = [];
x1List  = [];
x2List  = [];
dipList = [];
%options = optimset('TolX',1e-10);
dipPatchNum = 0;
while z2<=zMax
   %if dipPatchNum >100, break; end
   x1 = x2; 
   z1 = z2;
   func = @(x) abs((x-x1)^2+(linear_poly3(pars,x)-z1)^2-dipPatchSize^2);
   % fzero root-solving has some problems
   % x2 = fzero(func,x1+dipPatchSize);
   [ x2,xval ] = fminbnd(func,x1,x1+dipPatchSize);
   z2   = linear_poly3(pars,x2);
   dp   = atand((z2-z1)/(x2-x1));
   % check if dist is correct
   % fprintf(1,'dipdist=%14.6f;  xval=%14.6f\n',sqrt((x2-x1)^2+(z2-z1)^2),sqrt(xval));
   if x2<x1, fprintf(1,'MESH_form_dip WARNING: loop stopped due to x2<x1\n'); break; end
   x1List  = [ x1List;  x1 ];
   z1List  = [ z1List;  z1 ];
   x2List  = [ x2List;  x2 ];
   z2List  = [ z2List;  z2 ];
   dipList = [ dipList; dp ];
   dipPatchNum = dipPatchNum+1;
end

% plot cross-section to check
figure;
fitxx = 0:dipPatchSize:xMax;
fitzz = linear_poly3(pars,fitxx);
plot(xdata,zdata,'ob'); hold on;
set(gca,'YDir','reverse');
plot(fitxx,fitzz,'k'); hold on
plot(x1List,z1List,'or');


%------------------ write out dip ------------------%
[ ~,basename,~ ] = fileparts(slabFile);
dipFile = [ basename '_' num2str(dipPatchSize*1e-3,'%3.0f') 'km.dip' ];
fout    = fopen(dipFile,'w');
fprintf(fout,'# created by MESH_form_dip.m\n');
fprintf(fout,'# (1) x<=d: a*x+b\n');
fprintf(fout,'# (2) x>d:  l*x^3+m*x^2+n*x+p p = b+(a-n)*d-m*d^2-l*d^3\n');
fprintf(fout,'# (1)a (2)b (3)l (4)m (5)n (6)p (7)d\n');
fprintf(fout,'# %12.6e  %12.6e  %12.6e  %12.6e  %12.6e  %12.6e  %12.6e\n',aa,bb,ll,mm,nn,pp,dd);
fprintf(fout,'# The number of segments along-dip is %8.0f\n',dipPatchNum);
fprintf(fout,'# (1)dip (2)faultname (3)z1 (4)z2 (5)rows\n');
dipout = [ dipList z1List z2List ];
fprintf(fout,'dip   faultname   %6.2f %14.6e %14.6e     1\n',dipout');
fclose(fout);

function [ ypred ] = linear_poly3(xx,xdata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              linear_poly3                               %
% curve fitting for 2D slab profile                                       %
% use linear function for shallow and polynomial cubic function for deep  %
% calculates responses, not responses minus data                          %
% designed to be used by lsqcurvefit                                      %
%                                                                         %
% Data:       xdata                                                       %
% Parameters: a,b,l,m,n,d                                                 %
% Function:                                                               %
% 1 xdata<=d -> ypred = a*xdata + b; here a & b are both known            %
% 2 xdata>d  -> ypred = l*xdata*xdata*xdata + m*xdata*xdata + n*xdata + p %
%                                                                         %
% first created by Lujia Feng Thu Sep 19 15:26:37 SGT 2013                %
% modified based on Func_linear_poly2 lfeng Thu Sep 19 15:26:58 SGT 2013  %
% last modified by Lujia Feng Mon Nov  3 15:45:59 SGT 2014                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aa = xx(1);
bb = 0;
ll = xx(2);
mm = xx(3);
nn = xx(4);
dd = xx(5) ;

% to make the two functions continuous p is determined by other parameters
pp = bb + (aa-nn)*dd - mm*dd^2 - ll*dd^3;

% for x<=d, a linear fit
ypred = aa*xdata + bb;

% for x>d, a cubic polynomial fit
ind    = xdata>dd;
xdata2 = bsxfun(@times,xdata(ind),xdata(ind));
xdata3 = bsxfun(@times,xdata2,xdata(ind));
ypred(ind) = ll*xdata3 + mm*xdata2 + nn*xdata(ind) + pp;
