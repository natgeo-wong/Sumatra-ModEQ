function [ ] = GPS_gapcheck(fsitesName,frneuName,feqName,magMin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           	  GPS_gapcheck.m                                        % 
% check daily position availability for sites                                           %
%                                                                                       %
% INPUT:                                                                                %
% (1) fsitesName - site location file [optional]                                        %
% 1      2      3     4                                                                 %
% Site	 Lon	Lat   Height                                                            %
% If fsitesName = '', no site information file is provided!                             %
%                                                                                       %
% (2) frneuName - *.rneu all in [m]                                                     %
% 1        2         3     4    5    6     7     8                                      %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                                  %
% If frneuName = '', run this script for all *.rneu files in the current dir            %
%                                                                                       %
% (3) feqName - *.eqs earthquake file [optional]                                        %
% 1    2  3  4  5  6       7          8          9       10	    11          12      %
% YEAR MO DY HR MI SS.SSSS LONGITUDE  LATITUDE   DEPTH   MAGNITUDE  EVENT ID    DECYR   %
% If feqName = '', no earthquake file is provided!                                      %
%                                                                                       %
% (4) magMin - minimum magnitude for plotting                                           %
% default is 7 if magMin = []                                                           %
%                                                                                       %
% OUTPUT:                                                                               %
% (1) solution availability plot for sations                                            %
% (2) missing days for each station                                                     %
%                                                                                       %	
% first created by Lujia Feng Tue Sep 13 11:16:24 SGT 2011                              %
% added output file for missing days lfeng Thu Sep 22 10:48:46 SGT 2011                 %
% name changed from GPS_checkstatus to GPS_gapcheck lfeng Thu Feb 20 11:32:27 SGT 2014  %
% last modified by Lujia Feng Thu Sep 22 19:19:41 SGT 2011                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------------------------------------
% read site file to get site location info
if isempty(fsitesName)
   disp('GPS_gapcheck WARNING: *.sites location file is not provided!');
   siteNum = 0;
else
   fprintf(1,'\n.......... reading %s ...........\n',fsitesName);
   [ siteList,~,~ ] = GPS_readsites(fsitesName,1);  % siteList is cell
   siteNum = size(siteList,1);
end

%---------------------------------------------------------------------------------
% do for all *.rneu files
if isempty(frneuName)
   allNameStruct = dir('*.rneu');                   % not regexp \. here
else
   allNameStruct = dir(frneuName);                  % * like linux system can be used in frneuName
end

fNum = length(allNameStruct);
if fNum==0  
   error('GPS_gapcheck ERROR: no rneu files exist in the current directory satisfying input!'); 
end

%---------------------------------------------------------------------------------
% initialize figure setup
figName = 'sites_daily_solution_status.ps';
% create a figure without poping up the window
figHandle = figure('Visible','off','PaperType','usletter','PaperOrientation','landscape');
%figure('PaperType','A4','PaperOrientation','landscape');

% missing days output file
ftxtName = 'sites_missing_days.txt';
fout = fopen(ftxtName,'w');

%---------------------------------------------------------------------------------
% loop through stations
halfday = 1/365*0.5;
oneday = 1/365;
oneday11  = 1/365*1.1;                                % a little more than 1 day
for ii=1:fNum
   fName = allNameStruct(ii).name;                  % file name doesn't have to be 4-letter site name
   site = '';
   if siteNum ~= 0
   	% find out site name
   	for jj=1:siteNum
   	   siteNameStr = char(siteList(jj,:));          % convert from cell to character array
   	   if strfind(fName,siteNameStr)
   	      site = siteNameStr;
   	      break
   	   end
   	end
   end
   if isempty(site)
	[ ~,site,~ ] = fileparts(fName);
      	fprintf(1,'\nGPS_gapcheck WARNING: use file name %s for site name!\n',site);
   end
   fprintf(1,'\n/////---------------------- SITE: %s ----------------------/////\n',site);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read in %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fprintf(1,'\n.......... reading %s  ...........\n',fName);
   [ rneu ] = GPS_readrneu(fName,[],[]);
   decyr = rneu(:,2);
   datNum = size(decyr,1);
   tDiff = [];  tDiff(1,1) = 1;
   for jj=2:datNum
	tDiff(jj,1) = decyr(jj)-decyr(jj-1) ;
   end
   ind = find(tDiff>oneday11);                        % find out points not consecutive to previous days
   segNum = length(ind);
   % matrix for storing time segments; each column represents a continuous time period
   segXX = [];				
   for kk=1:segNum-1
        segXX(1,kk) = decyr(ind(kk))-halfday;
        segXX(2,kk) = decyr(ind(kk+1)-1)+halfday;	
	% 1st in ind is the start day, so ignore
	missStart = decyr(ind(kk+1)-1)+oneday;
	missEnd   = decyr(ind(kk+1))-oneday;
	[ yearmmddStart,~,~,~,doyStart ] = GPS_DCMLYEARtoYEARMMDD(missStart);
	[ yearmmddEnd,~,~,~,doyEnd ] = GPS_DCMLYEARtoYEARMMDD(missEnd);
   	fprintf(fout,'%s\t%d(%03d:%.4f)  -  %d(%03d:%.4f)\n',...
	        site,yearmmddStart,doyStart,missStart,yearmmddEnd,doyEnd,missEnd);
   end
   kk = segNum;
   segXX(1,kk) = decyr(ind(kk))-halfday;
   segXX(2,kk) = decyr(end)+halfday;
   segYY = ones(size(segXX))*ii;
   line(segXX,segYY,'Color','r','LineWidth',3);
   xlim = get(gca,'XLim');
   % replace _ with \_
   site = strrep(site,'_','\_');
   text(xlim(2)+0.1,ii,site,'Fontsize',7,...
        'Horizontalalignment','Left','VerticalAlignment','Middle');
end
fclose(fout);

% read earthquake file to get earthquake list
if isempty(fsitesName)
   disp('GPS_gapcheck WARNING: *.eqs earthquake file is not provided!');
else
   xlim = get(gca,'XLim'); ylim = get(gca,'YLim');
   fprintf(1,'\n.......... reading %s ...........\n',feqName);
   [ eqs ] = EQS_readeqs(feqName);
   % time limits
   eqTime = eqs(:,12);	eqMag = eqs(:,10);
   indKeep = eqTime >= xlim(1);
   eqTime = eqTime(indKeep); eqMag = eqMag(indKeep);
   indKeep = eqTime <= xlim(2);
   eqTime = eqTime(indKeep); eqMag = eqMag(indKeep);
   % magnitude limits
   indKeep = eqMag >= magMin;         	
   eqTime = eqTime(indKeep)'; eqMag = eqMag(indKeep);
   eqXX = eqTime(ones(2,1),1:end);			% copy eqTime twice
   eqYY = ones(size(eqXX)); 
   eqYY(1,:) = eqYY(1,:)*ylim(1); eqYY(2,:) = eqYY(2,:)*ylim(2);
   line(eqXX,eqYY,'Color','b','LineWidth',1); 
   % magnitude limits >= 8
   indKeep = eqMag >= 8;         	
   eqTime = eqTime(indKeep); eqMag = eqMag(indKeep);
   eqXX = eqTime(ones(2,1),1:end);			% copy eqTime twice
   eqYY = ones(size(eqXX)); 
   eqYY(1,:) = eqYY(1,:)*ylim(1); eqYY(2,:) = eqYY(2,:)*ylim(2);
   line(eqXX,eqYY,'Color','k','LineWidth',1); 
end

% make adjustments
set(gca,'Xlim',[2002 2014],'YDir','reverse','XGrid','on','XMinorGrid','on','YAxisLocation','left',...
        'Units','normalized','Position',[0.1 0.1 0.7 0.8]);                    
title('Station Solution Availability','FontSize',14);
xlabel('Year','FontSize',12); ylabel('Stations','FontSize',12);

print(figHandle,'-depsc',figName);
delete(figHandle);
