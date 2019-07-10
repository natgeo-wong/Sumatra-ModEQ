function [ prf ] = xyzprofile(fxyzName,fprfName,method,prfFormat,pars)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                xyzprofile.m				  	%
% create profile transects and get corresponding values from xyz file           %
%									  	%
% INPUT:					  		  	  	%
% fxyzName - xyz data file						  	%
% fprfName - output profile file					  	%
%   fprfName = '' do not write an output file			  		%
% method  - method used to find the value				  	%
%   'nearest' - use the nearest data point point existing in xyz data	  	%
%   'sphere'  - use the average value within a sphere of a certain radius	%
%   only 'nearest' available currently						%
% prfFormat - format of specifying line parameters			  	%
%   1: pars = [lon0 lat0 len1 len2 str num]				  	%
%      lon0,lat0 - origin of profile transect   		  	  	%
%                  where the distance is calculated from		  	%
%      len1      - profile length left of lon0,lat0 [m]		  		%
%                  usually negavtive					  	%
%      len2      - profile length right of lon0,lat0 [m]		  	%
%      str       - strike of profile from lon0,lat0			  	%
%      num       - number of interpolating points along profile	  		%
%   2: pars = [lon0 lat0 lon1 lat1 num]				  		%
%      lon0,lat0 - starting point of profile transects 		  		%	
%      lon1,lat1 - endpoint of profile transects 		  	  	%	
%      num       - number of sampling points along profile		  	%
%   3: line is represented by individual points			  		%
%      pars = [lon0 lat0] (nx2)					  		%
%             [lon1 lat1]				  		  	%
%             [lon2 lat2]						  	%
%             [lon3 lat3]				  		  	%
%              ...  ...						  		%	
%                                                                         	%
% OUTPUT:								  	%
% structure prf including fields						%
%   prf.lon,prf.lat - geographic location of interpolating points	  	%
%   prf.xx,prf.yy   - local location of interpolating points		  	%
%   prf.dis         - distance to [lon0,lat0]				  	%
%   prf.zz          - elevation for topography & bathymetry		  	%
%		       depth for EQs					  	%
%										%
% first created by Lujia Feng Sat Jul 31 12:34:46 EDT 2010	   	  	%
% added method by lfeng Thu Nov 18 15:01:24 EST 2010			  	%
% completely modified by lfeng Fri Oct 14 15:23:57 SGT 2011		  	%
% last modified by lfeng Fri Oct 14 21:15:07 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% only 'nearest' working right now
method = 'nearest';

%%%%%%%%%% prepare profile %%%%%%%%%%
switch prfFormat
   case 1
      lon0 = pars(1); lat0 = pars(2); 
      len1 = pars(3); len2 = pars(4); 
      str  = pars(5); num = pars(6);
      xx1  = len1*sind(str);  yy1 = len1*cosd(str); 
      xx2  = len2*sind(str);  yy2 = len2*cosd(str); 
      prf.xx = linspace(xx1,xx2,num); prf.yy = linspace(yy1,yy2,num);
      [ prf.lon,prf.lat ] = ckm2LLd(prf.xx,prf.yy,lon0,lat0,0);		
   case 2
      lon0 = pars(1); lat0 = pars(2); 
      lon1 = pars(3); lat1 = pars(4); 
       num = pars(5);  xx0 = 0; yy0 = 0; 
      [ xx1,yy1 ] = LL2ckmd(lon1,lat1,lon0,lat0,0);
      prf.xx = linspace(xx0,xx1,num); prf.yy = linspace(yy0,yy1,num);
      str = 90-180*atan2(yy1-yy0,xx1-xx0)/pi;   		% degree CW from N [0-360]
      [ prf.lon,prf.lat ] = ckm2LLd(prf.xx,prf.yy,lon0,lat0,0);	
   case 3
      lon0 = pars(1,1); lat0 = pars(1,2); num = size(pars,1);
      prf.lon = pars(:,1)'; prf.lat = pars(:,2)';
      xx0 = 0; yy0 = 0; 
      [ prf.xx,prf.yy ] = LL2ckmd(prf.lon,prf.lat,lon0,lat0,0);
      [ str ] = GTdef_strike(0,0,prf.xx(2),prf.yy(2));		% use the strike from point1 to point2 as the positive strike direction
   otherwise
      error('xyzprofile ERROR: profile input parameters are wrong!');
end

%%%%%%%%%% read in xyz file %%%%%%%%%%
[ xyzLon,xyzLat,xyzZZ ] = readxyz(fxyzName);
[ xyzXX,xyzYY ] = LL2ckmd(xyzLon,xyzLat,lon0,lat0,0);			% convert to local coord


%%%%%%%%%% calculate distance %%%%%%%%%%
for ii=1:num
   xx = prf.xx(ii); yy = prf.yy(ii);
   [ ss ] = GTdef_strike(0,0,xx,yy);
   if abs(ss-str)<90
      prf.dis(ii) = sqrt(xx*xx+yy*yy);
   else
      prf.dis(ii) = -sqrt(xx*xx+yy*yy);
   end
   % find the nearest xyz point
   dis = sqrt((xyzXX-xx).^2+(xyzYY-yy).^2);
   [ dis_sort,ind ] = sort(dis);
   prf.zz(ii) = xyzZZ(ind(1));
end

%%%%%%%%%% write out profile if output given %%%%%%%%%%
if ~isempty(fprfName)
   fout = fopen(fprfName,'w');
   fprintf(fout,'#xyz data source %s\n#origin %-14.8f  %-12.8f\n',fxyzName,lon0,lat0);
   switch prfFormat
      case 1
      fprintf(fout,'#profile across %-14.8f %-12.8f %-6.4e %-6.4e %-5.2f %d\n',pars);
      case 2
      fprintf(fout,'#profile across %-14.8f %-12.8f %14.8f %-12.8f %d\n',pars);
      case 3
      fprintf(fout,'#profile across a series of individual points\n');
   end
   fprintf(fout,'#lon\tlat\txx [m]\tyy [m]\tdis [m]\televation [m] or [km] the same as input xyz file\n');
   prfMat = [ prf.lon; prf.lat; prf.xx; prf.yy; prf.dis; prf.zz ];
   fprintf(fout,'%-14.8f %-12.8f %-12.4e %-12.4e %-12.4e %-12.8f\n',prfMat);
   fclose(fout);
end
