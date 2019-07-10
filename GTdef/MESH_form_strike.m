function [ strPatchNum,stroutLL,stroutXY ] = MESH_form_strike(coastFile,trenchFile,trenchRange,strPatchSize,lon0,lat0,sweepAngle)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            MESH_form_strike				  %
% discretize a trench line to segments with designed lengths              %
%									  %
% INPUT:                                                                  %
% coastFile    - coastline file [optional]                                %
% trenchFile   - trench file                                              %
%              1     2      3                                             %
%              lon   lat    depth                                         %
% trenchRange  - used to trim trench in lonlat coord system               %
%              = [ lonMin lonMax; latMin latMax ]                         %
% strPatchSize - patch size along strike [m]                              %
% lon0,lat0    - origin used for local cartesian system                   %
%         e.g. = [ 99.969549 -4.229013 ]                                  %
% sweepAngle   - angle between normal direction of fault trace and east   %
%                E=0 N=90 W=180 S=270 [deg]                               %
%                                                                         %
% OUTPUT:                                                                 %
% strFile      - *.strike file                                            %
%        1       2           3     4     5     6     7        8           %
%        strike  fault_name  lon1  lat1  lon2  lat2  columns  sweepAngle  %
% strPatchNum  - number of patches along strike                           %
% stroutLL     = [ lon1 lat1 lon2 lat2 ]                                  %
% stroutXY     = [ x1List y1List x2List y2List ]                          %
%									  %
% first created by Lujia Feng Wed Nov  5 11:30:53 SGT 2014                %
% added sweepAngle lfeng Thu Nov 13 11:47:38 SGT 2014                     %
% last modified by Lujia Feng Thu Nov 13 12:17:04 SGT 2014                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------ input ------------------%
% read in trench
fin        = fopen(trenchFile,'r');
trenchCell = textscan(fin,'%f %f %f','CommentStyle','#');
lonlat     = cell2mat(trenchCell);
trenchlon0 = lonlat(:,1);
trenchlat0 = lonlat(:,2);
depth0     = lonlat(:,3);
fclose(fin);

% trim trench according to trenchRange
lonMin    = trenchRange(1,1);
lonMax    = trenchRange(1,2); 
latMin    = trenchRange(2,1);
latMax    = trenchRange(2,2); 
ind       = trenchlon0>=lonMin & trenchlon0<=lonMax & trenchlat0>=latMin & trenchlat0<=latMax;
trenchlon = trenchlon0(ind);
trenchlat = trenchlat0(ind);
% reverse trench to start from low latitude to high latitude
if trenchlat(1)>trenchlat(end)
   trenchlon = trenchlon(end:-1:1);
   trenchlat = trenchlat(end:-1:1);
end


% convert from lonlat to local cartesian system
% xx - east
% yy - north
% no rotation
[ trenchxx0,trenchyy0 ] = latlon_to_xy(trenchlon0,trenchlat0,lon0,lat0,0);
[ trenchxx,trenchyy ]   = latlon_to_xy(trenchlon,trenchlat,lon0,lat0,0);

%------------------ form strike ------------------%
% use method="spline" to do interpolation and get piecewise polynomial
% note xx & yy are switched!
pp = interp1(trenchyy,trenchxx,'spline','pp');
y2      = trenchyy(1);
x2      = ppval(pp,y2);
x1List  = [];
y1List  = [];
x2List  = [];
y2List  = [];
strPatchNum  = 0;
while y2<=trenchyy(end)
   y1 = y2;
   x1 = x2;
   func = @(y) abs((y-y1)^2+(ppval(pp,y)-x1)^2-strPatchSize^2);
   [ y2,yval ] = fminbnd(func,y1,y1+strPatchSize);
   x2   = ppval(pp,y2);
   % check if dist is correct
   % fprintf(1,'strdist=%14.6f;   xval=%14.6f\n',sqrt((x2-x1)^2+(y2-y1)^2),sqrt(yval));
   % y increases, so the initial y1 must be smallest!
   if y2<y1, fprintf(1,'MESH_form_strike WARNING: loop stopped due to y2<y1\n'); break; end
   x1List = [ x1List; x1 ];
   y1List = [ y1List; y1 ];
   x2List = [ x2List; x2 ];
   y2List = [ y2List; y2 ];
   strPatchNum = strPatchNum+1;
end

% convert from local cartesian system to lonlat
[ lon1,lat1 ] = xy_to_latlon(x1List,y1List,lon0,lat0,0);
[ lon2,lat2 ] = xy_to_latlon(x2List,y2List,lon0,lat0,0);

% plot map view to check
figure;
plot(trenchxx0,trenchyy0,'b'); hold on;
plot(trenchxx,trenchyy,'r');
plot(x1List,y1List,'og');
% read in coastline
if ~isempty(coastFile)
   if ~exist(coastFile,'file'), error('MESH_form_strike ERROR: %s does not exist!',coastFile); end
   fin       = fopen(coastFile,'r');
   coastCell = textscan(fin,'%f %f','CommentStyle','#');       % Delimiter default white space
   coast     = cell2mat(coastCell);
   coastlon  = coast(:,1);
   coastlat  = coast(:,2);
   fclose(fin);
   [ coastxx,coastyy ] = latlon_to_xy(coastlon,coastlat,lon0,lat0,0);
   coastzz = zeros(size(coastxx));
   plot(coastxx,coastyy,'k');
end

%------------------ write out strike ------------------%
[ ~,basename,~ ] = fileparts(trenchFile);
strFile  = [ basename '_' num2str(strPatchSize*1e-3,'%3.0f') 'km.strike' ];
fout     = fopen(strFile,'w');
fprintf(fout,'# created by MESH_form_strike.m\n');
fprintf(fout,'# The number of segments along-strike is %8.0f\n',strPatchNum);
fprintf(fout,'# (1)strike (2)faultname (3)lon1 (4)lat1 (5)lon2 (6)lat2 (7)columns (8)sweepAngle\n');
stroutLL = [ lon1 lat1 lon2 lat2 ];
stroutXY = [ x1List y1List x2List y2List ];
out      = [ stroutLL sweepAngle*ones(size(lon1)) ];
fprintf(fout,'strike   faultname   %14.6f %14.6f %14.6f %14.6f   1   %12.3f\n',out');
fclose(fout);
