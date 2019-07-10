function [ ] = MESH_builder(coastFile,slabFile,trenchFile,...
                            slabRange,trenchRange,...
                            dipPatchSize,strPatchSize,...
                            lon0,lat0,dip0,str0,pars0,lb,ub,sweepAngle)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            MESH_builder				  %
% generate rectangle-shaped mesh with changes in both dip and strike      %
%                                                                         %
% INPUT:                                                                  %
% coastFile    - coastline file [optional]                                %
% slabFile     - slab contour file                                        %
% e.g.   > -620 contour -Z-620                                            %
%        107.30  -4.50   -620.00                                          %
%        107.30  -4.50   -620.00                                          %
%        > -620 contour -Z-620                                            %
%        107.34  -4.52   -620.00                                          %
%        107.33  -4.52   -620.00                                          %
% trenchFile   - trench file                                              %
%        1     2      3                                                   %
%        lon   lat    depth                                               %
% slabRange    - used to trim slab [m]                                    %
%              = [ xMin xMax; yMin yMax; zMin zMax ]                      %
%                depth positive down                                      %
% Note: the ranges for x and y may not need if using a constant dip,      %
%       can be set as NaN; but zMin and zMax are always needed            %
% trenchRange  - used to trim trench in lonlat coord system               %
%              = [ lonMin lonMax; latMin latMax ]                         %
% dipPatchSize - patch size along dip [m]                                 %
% strPatchSize - patch size along strike [m]                              %
% lon0,lat0    - origin used for local cartesian system                   %
%         e.g. = [ 99.969549 -4.229013 ]                                  %
% ----------------------------------------------------------------------- %
% Either use a constant dip for a cross-section profile                   %
% dip0         - constant dip                                             %
%                                                                         %
%                                 OR                                      %
%                                                                         %
% Or choose a portion to fit a cross-section profile                      %
% str0         - strike used for cross-section                            %
%                strke is CW from N                                       %
% pars0        - initial values for linear_poly3 fit                      %
% lb,ub        - lower and upper bounds for linear_poly3 fit              %
% sweepAngle   - angle between normal direction of fault trace and east   %
%                E=0 N=90 W=180 S=270 [deg]                               %
% Note: origin has to be along the trench if a dip profile is fit!        %
%                                                                         %
% OUTPUT:								  %
% -------------------------- for 2.5D geometry -------------------------- %
% dipFile - *.dip file                                                    %
%           1       2           3     4     5     6                       %
%           dip     fault_name  dip   z1    z2    rows                    %
% strFile - *.strike file                                                 %
%           1       2           3     4     5     6     7                 %
%           strike  fault_name  lon1  lat1  lon2  lat2  columns           %
% patchFiles - for importing to other programs, e.g, GTdef or inverse2    % 
%                                                                         %
% --------------------------- for 3D  geometry -------------------------- %
% patchFiles - for importing to other programs, e.g, GTdef or inverse2    % 
%									  %
% first created by Lujia Feng Mon Nov  3 14:57:56 SGT 2014                %
% added 3D rectangular geometry lfeng Tue Aug  4 23:05:58 SGT 2015        %
% changed latlon_to_xy/xy_to_latlon to LL2cmkd/cmk2LLd lfeng Aug 5 2015   %
% last modified by Lujia Feng Wed Aug  5 16:57:51 SGT 2015                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------- form dip ----------------------
% dipout  = [ dipList z1List z2List ]
if isempty(dip0)
   [ ~,dipPatchNum,dipout ] = MESH_form_dip(coastFile,slabFile,slabRange,dipPatchSize,lon0,lat0,str0,pars0,lb,ub);
else
   % form dipout
   zMin = slabRange(3,1);
   zMax = slabRange(3,2);
   depPatchSize = dipPatchSize*sind(dip0);
   dipPatchNum  = round((zMax-zMin)/depPatchSize);
   dipList = dip0*ones(dipPatchNum,1);
   z1List  = zMin:depPatchSize:depPatchSize*(dipPatchNum-1);
   z2List  = zMin+depPatchSize:depPatchSize:depPatchSize*dipPatchNum;
   dipout  = [ dipList z1List' z2List' ]; 
end

%---------------------- form strike ----------------------
% stroutLL = [ lon1 lat1 lon2 lat2 ]
% stroutXY = [ x1List y1List x2List y2List ]
[ strPatchNum,stroutLL,stroutXY ] = MESH_form_strike(coastFile,trenchFile,trenchRange,strPatchSize,lon0,lat0,sweepAngle);

%---------------------- generate patches ----------------------
x1List  = []; x2List = []; x3List = []; x4List = []; xcList  = [];
y1List  = []; y2List = []; y3List = []; y4List = []; ycList  = [];
z1List  = []; z2List = []; z3List = []; z4List = []; zcList  = [];
lenList = []; 
widList = [];
strList = [];
dipList = []; 
rakList = [];
slpList = [];

%  1 -------> 2 x1,x2,y1,y2,z1
%  |
%  |
%  |
%  \/
%  3 -------> 4 x3,x4,y3,y4,z2

% loop along strike/trench
for ii=1:strPatchNum
   x1 = stroutXY(ii,1); y1 = stroutXY(ii,2);
   x2 = stroutXY(ii,3); y2 = stroutXY(ii,4);
   % loop along dip
   for jj=1:dipPatchNum
      z1 = dipout(jj,2);               
      z2 = dipout(jj,3);
      dp = dipout(jj,1);
      dwidth  = dipPatchSize*cosd(dp);
      x3 = x1+dwidth*cosd(sweepAngle); y3 = y1+dwidth*sind(sweepAngle);
      x4 = x2+dwidth*cosd(sweepAngle); y4 = y2+dwidth*sind(sweepAngle);
      xc = (x1+x4)*0.5;
      yc = (y1+y4)*0.5;
      zc = (z1+z2)*0.5; % z1 correspond to (x1,y1) & (x2,x2) z2 correspond to (x3,y3) & (x4,x4)
      strike  = GTdef_strike(x1,y1,x2,y2);
      dist    = sqrt((x1-x2)^2+(y1-y2)^2);

      x1List  = [ x1List;  x1 ]; x2List  = [ x2List;  x2 ]; xcList  = [ xcList;  xc ];
      y1List  = [ y1List;  y1 ]; y2List  = [ y2List;  y2 ]; ycList  = [ ycList;  yc ];
      z1List  = [ z1List;  z1 ]; z2List  = [ z2List;  z1 ]; zcList  = [ zcList;  zc ];

      x3List  = [ x3List;  x3 ]; x4List  = [ x4List;  x4 ];
      y3List  = [ y3List;  y3 ]; y4List  = [ y4List;  y4 ];
      z3List  = [ z3List;  z2 ]; z4List  = [ z4List;  z2 ];

      dipList = [ dipList; dp ]; 
      strList = [ strList; strike ];
      lenList = [ lenList; strPatchSize ]; 
      %lenList = [ lenList; dist ]; 
      widList = [ widList; dipPatchSize ];

      % next patch along dip
      x1 = x3; y1 = y3;
      x2 = x4; y2 = y4;
   end
end
rakList  = 90*ones(size(x1List));
slpList  = zeros(size(x1List));
% convert from local cartesian to lonlat
[ loncList,latcList ] = ckm2LLd(xcList,ycList,lon0,lat0,0);
[ lon1List,lat1List ] = ckm2LLd(x1List,y1List,lon0,lat0,0);

% inum, dnum, snum
patchNum = size(z1List,1);
inum = [ 1:patchNum ]';
dlin = round(linspace(1,dipPatchNum,dipPatchNum)'); 
slin = round(linspace(1,strPatchNum,strPatchNum));
dmat = dlin(1:end,ones(1,strPatchNum));    
smat = slin(ones(dipPatchNum,1),1:end);
dnum = reshape(dmat,[],1);        
snum = reshape(smat,[],1);

%---------------------- save patches ----------------------
if isempty(dip0)
   % inverse 2 format
   foutName = [ 'inverse2_' num2str(dipPatchSize*1e-3,'%2.0f') 'km2_2.5D.input' ];
   fout = fopen(foutName,'w');
   fprintf(fout,'# created by MESH_builder.m\n');
   fprintf(fout,'# (1)midLon (2)midLat (3)midDepth[m] (4)strike (5)dip (6)patchLength[m] (7)patchWidth[m]\n');
   out  = [ loncList latcList zcList strList dipList lenList widList ];
   fprintf(fout,'%14.8f %14.8f %14.4f %8.2f %8.2f %14.5e %14.4e\n',out');
   fclose(fout);

   % GTdef format - topleft point
   outFlag  = 'GTdef';
   basename = [ 'SMT_' num2str(dipPatchSize*1e-3,'%2.0f') 'km2_2.5D' ];
   % 1  2    3    4   5   6 7      8     9      10  11   12
   % no dnum snum lon lat z length width strike dip rake slip
   out  = [ inum dnum snum lon1List lat1List z1List lenList widList strList dipList rakList slpList ];
   [ fout ] = GTdef_GTdef2subfaults_head(outFlag,basename);
   GTdef_GTdef2subfaults_body(outFlag,fout,out);
end

%---------------------- modify patches according to 3D slab geometry ----------------------
% read in slab
if ~exist(slabFile,'file'), error('MESH_form_dip ERROR: %s does not exist!',slabFile); end
[ slablon0,slablat0,slabzz0 ] = GMT_readcont(slabFile);
slabzz0 = -1e3*slabzz0;     % convert depth negative & km in slab file to depth positive and meter
% convert lonlat to local cartesian system
% xx - from east  to along-dip
% yy - from north to along-strike
[ slabxx0,slabyy0 ] = LL2ckmd(slablon0,slablat0,lon0,lat0,0);
% remove NaN values
nanind  = ~isnan(slabxx0) & ~isnan(slabyy0) & ~isnan(slabzz0);
slabxx  = slabxx0(nanind);
slabyy  = slabyy0(nanind);
slabzz  = slabzz0(nanind);
% don't trim slab here for better interpolation
% create the interpolant
%                                  Interpolation Method , Extrapolation Method
FF = scatteredInterpolant(slabxx,slabyy,slabzz,'natural','nearest');
% evaluate the interpolant at query locations
z1ListI  = FF(x1List,y1List);
z2ListI  = FF(x2List,y2List);
z3ListI  = FF(x3List,y3List);
z4ListI  = FF(x4List,y4List);
% calculate using new depth values
lenListM = []; 
widListM = [];
dipListM = []; 
strListM = [];
xcListM  = [];
ycListM  = [];
zcListM  = [];
x1ListM  = [];
y1ListM  = [];
z1ListM  = [];
%  1 -------> 2 x1,x2,y1,y2,z1,z2
%  |
%  |
%  |
%  \/
%  3 -------> 4 x3,x4,y3,y4,z3,z4
for ii=1:patchNum
   str = strList(ii);
   if str<0, str = str + 360; end % in case strike is given in negative
   x1  = x1List(ii);  x2 = x2List(ii);  x3 = x3List(ii);  x4 = x4List(ii);
   y1  = y1List(ii);  y2 = y2List(ii);  y3 = y3List(ii);  y4 = y4List(ii);
   z1  = z1ListI(ii); z2 = z2ListI(ii); z3 = z3ListI(ii); z4 = z4ListI(ii); % depth value is positive 
   % horizontal length
   lenM   = 0.5*(sqrt((x1-x2)^2+(y1-y2)^2) + sqrt((x3-x4)^2+(y3-y4)^2));
   % middle points
   upmidx = 0.5*(x1+x2); dwmidx = 0.5*(x3+x4);
   upmidy = 0.5*(y1+y2); dwmidy = 0.5*(y3+y4);
   upmidz = 0.5*(z1+z2); dwmidz = 0.5*(z3+z4);
   % center point
   xcM    = 0.5*(upmidx+dwmidx);
   ycM    = 0.5*(upmidy+dwmidy);
   zcM    = 0.5*(upmidz+dwmidz);
   % distance between middle points
   midxy  = sqrt((upmidx-dwmidx)^2+(upmidy-dwmidy)^2);
   midzz  = abs(dwmidz-upmidz);
   % width
   widM   = sqrt(midxy^2+midzz^2);
   if upmidz<=dwmidz
      % orthogonal to strike direction
      [ orthstr ] = GTdef_strike(upmidx,upmidy,dwmidx,dwmidy);
      % two possible strike directions
      strminus = orthstr - 90;
      if strminus<0, strminus = strminus+360; end
      strplus  = orthstr + 90;
      if strplus>360, strplus = strplus-360; end
      if abs(str-strminus) <= abs(str-strplus) % dip < 90, consistent with preassigned strike
         strM = strminus;
	 %               +     +
         dipM = atan2d(midzz,midxy);
      else % dip >90
         strM = strminus;
	 %               +     -
         dipM = atan2d(midzz,-midxy);
      end
   else
      error('MESH_builder ERROR: burial depth cannot be larger than locking depth!');
   end
   % convert center point back to topleft point using new parameters
   ll  = 0.5*lenM;
   ww  = 0.5.*widM.*cosd(dipM);
   dx  = ll.*sind(strM) + ww.*cosd(strM);
   dy  = ll.*cosd(strM) - ww.*sind(strM); 
   x1M = xcM - dx;
   y1M = ycM - dy;
   z1M = zcM - 0.5.*widM.*sind(dipM);
   % add to the list
   lenListM = [ lenListM; lenM ]; 
   widListM = [ widListM; widM ];
   dipListM = [ dipListM; dipM ]; 
   strListM = [ strListM; strM ]; 
   xcListM  = [ xcListM;  xcM ];
   ycListM  = [ ycListM;  ycM ];
   zcListM  = [ zcListM;  zcM ];
   x1ListM  = [ x1ListM;  x1M ];
   y1ListM  = [ y1ListM;  y1M ];
   z1ListM  = [ z1ListM;  z1M ];
end
rakListM = 90*ones(size(x1ListM));
slpListM = ones(size(x1ListM));

% convert from local cartesian to lonlat
[ loncListM,latcListM ] = ckm2LLd(xcListM,ycListM,lon0,lat0,0);
[ lon1ListM,lat1ListM ] = ckm2LLd(x1ListM,y1ListM,lon0,lat0,0);
%---------------------- save patches ----------------------
% inverse 2 format - center point
foutName = [ 'inverse2_' num2str(dipPatchSize*1e-3,'%2.0f') 'km2_3D.input' ];
fout = fopen(foutName,'w');
fprintf(fout,'# created by MESH_builder.m\n');
fprintf(fout,'# (1)midLon (2)midLat (3)midDepth[m] (4)strike (5)dip (6)patchLength[m] (7)patchWidth[m]\n');
out  = [ loncListM latcListM zcListM strList dipListM lenListM widListM ];
fprintf(fout,'%14.8f %14.8f %14.4f %8.2f %8.2f %14.5e %14.4e\n',out');
fclose(fout);

% GTdef format - topleft point
outFlag  = 'GTdef';
basename = [ 'SMT_' num2str(dipPatchSize*1e-3,'%2.0f') 'km2_3D' ];
% 1  2    3    4   5   6 7      8     9      10  11   12
% no dnum snum lon lat z length width strike dip rake slip
out  = [ inum dnum snum lon1ListM lat1ListM z1ListM lenListM widListM strList dipListM rakListM slpListM ];
[ fout ] = GTdef_GTdef2subfaults_head(outFlag,basename);
GTdef_GTdef2subfaults_body(outFlag,fout,out);

%---------------------- plot patches ----------------------
figure;
% plot constant cross-section profile
[ xcop,ycop,zcop,ucop ] = transform4patch(x1List,y1List,z1List,slpList,lenList,widList,dipList,strList);
patch(xcop,ycop,-zcop,ucop); hold on; colorbar, box on;
plot3(xcList,ycList,-zcList,'ob');

% plot real 3D
[ xcopM,ycopM,zcopM,ucopM ] = transform4patch(x1ListM,y1ListM,z1ListM,slpListM,lenListM,widListM,dipListM,strList);
patch(xcopM,ycopM,-zcopM,ucopM); hold on; colorbar, box on;
plot3(xcListM,ycListM,-zcListM,'*k');

% plot slab
if ~exist(slabFile,'file'), error('MESH_builder ERROR: %s does not exist!',slabFile); end
[ slablon,slablat,slabzz ] = GMT_readcont(slabFile);
slabzz = -1e3*slabzz;     % convert depth negative & km in slab file to positive up and meter
[ slabxx,slabyy ] = LL2ckmd(slablon,slablat,lon0,lat0,0);
plot3(slabxx,slabyy,-slabzz,'r');

% plot coastline
if ~isempty(coastFile)
   if ~exist(coastFile,'file'), error('MESH_builder ERROR: %s does not exist!',slabFile); end
   fin       = fopen(coastFile,'r');
   coastCell = textscan(fin,'%f %f','CommentStyle','#');       % Delimiter default white space
   coast     = cell2mat(coastCell);
   coastlon  = coast(:,1);
   coastlat  = coast(:,2);
   fclose(fin);
   %[ coastxx,coastyy ] = LL2ckmd(coastlon,coastlat,lon0,lat0,-rot);
   [ coastxx,coastyy ] = LL2ckmd(coastlon,coastlat,lon0,lat0,0);
   coastzz = zeros(size(coastxx));
   plot3(coastxx,coastyy,coastzz,'k');
end
