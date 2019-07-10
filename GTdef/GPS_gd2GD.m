function [ ] = GPS_gd2GD(site)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           	  GPS_gd2GD.m				       	%
% cat all GIPSY daily gd files of one station into one GD file			%
%										%
% INPUT: 									%
% site - site name								%
% if site = '' meaning running for all *.gd files in the current directory  	%
%										%
% gd FORMAT example								%
% ABGS       LAT   07JAN01      0.220824642  +-     0.0008  -0.033586  -0.017738%
% ABGS       LON   07JAN01     99.387520914  +-     0.0018   0.022608		%
% ABGS       RAD   07JAN01         236.2533  +-     0.0034			%
%										%
% OUTPUT: 									%
% GD FORMAT									%
% 1     2    3          4           5          6        7           8           %
% DATE  GD   Lat(deg)+/-Sigma(m)    Lon(deg)+/-Sigma(m) Height(m)+/-Sigma(m)    %
%										%
% first created by lfeng Fri Jul 15 16:21:56 SGT 2011				%
% last modified by lfeng Mon Jul 18 14:08:32 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%% check if for all *.GD files %%%%%%%%%%%%%%%%%%%%%%%
if isempty(site)
   allNamesStruct = dir('*.gd');	% not regexp \. here
else
   siteName = [ '*' site '*.gd' ];
   allNamesStruct = dir(siteName);	% * like linux system can be used
end

fnum = length(allNamesStruct);
if fnum==0, error('GPS_gd2GD ERROR: no gd files exist in the current directory satisfying input!'); end

%%%%%%%%%%%%%%%%%%%%%%% initialization %%%%%%%%%%%%%%%%%%%%%%%
siteList = {}; 	 dayList  = {};	 	% siteList & dayList are cells
ymdList    = []; decyrList   = [];
latList    = []; dlatList    = []; 
lonList    = []; dlonList    = []; 
heightList = []; dheightList = [];

for ii=1:fnum
   gd_name = allNamesStruct(ii).name;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n.......... reading %s ...........\n',gd_name);
   [ site,day,lat,dlat,lon,dlon,height,dheight ] = GPS_readgd1day(gd_name);
   fprintf(1,'%s on %s\n',site,day);
   [ yearmmdd,decyr ] = GPS_YYMONDDtoYEARMMDD(day);
   siteList{end+1} = site; 		% site - string; siteList - cell
   dayList{end+1}  = day; 		% day - string; dayList - cell
   ymdList	= [ ymdList; yearmmdd ];
   decyrList	= [ decyrList; decyr ];
   latList      = [ latList; lat ];
   lonList      = [ lonList; lon ];
   heightList   = [ heightList; height ];
   dlatList     = [ dlatList; dlat ];
   dlonList     = [ dlonList; dlon ];
   dheightList  = [ dheightList; dheight ];
   % add this site to name list if it's not there yet
   if ii==1  					% always add 1st file
      siteNamesList = { site }; 
   elseif all(strcmpi(site,siteNamesList)==0)	% check following files
      siteNamesList{end+1} = site;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save GD file for each site %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
siteNum = length(siteNamesList);
for ii=1:siteNum
   site = char(siteNamesList{ii});
   GDName = [ site '.GD' ];
   % find out all records for this site
   ind = strcmpi(site,siteList);
   day = dayList(ind);
   decyr    = decyrList(ind);
   lat      = latList(ind);
   lon      = lonList(ind);
   height   = heightList(ind);
   dlat     = dlatList(ind);
   dlon     = dlonList(ind);
   dheight  = dheightList(ind);
   % sort ascendingly
   [~,IX] = sort(decyr);
   day 	   = day(IX);
   lat     = lat(IX);
   lon     = lon(IX);
   height  = height(IX);
   dlat    = dlat(IX);
   dlon    = dlon(IX);
   dheight = dheight(IX);
   % save GD file
   fprintf(1,'\n.......... saving %s ...........\n',GDName);
   fout = fopen(GDName,'w');
   fprintf(fout,'  DATE  GD   Lat(deg)+/-Sigma(m)    Lon(deg)+/-Sigma(m) Height(m)+/-Sigma(m)\n');
   dayNum = length(IX);
   for ii=1:dayNum
      fprintf(fout,'%7s GD %14.9f %-7.4f %14.9f %-7.4f %9.4f %-7.4f\n',...
              char(day(ii)),lat(ii),dlat(ii),lon(ii),dlon(ii),height(ii),dheight(ii));
   end
   fclose(fout);
end
