function [ gapMat ] = GPS_gapcheck_1site(rneu)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           	 GPS_gapcheck_1site.m                                   % 
% check daily position availability for one site                                        %
%                                                                                       %
% INPUT:                                                                                %
% rneu = an nx8 array (n is number of data points)                                      %
% 1        2         3     4    5    6     7     8                                      %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                                  %
%                                                                                       %
% OUTPUT:                                                                               %
% gapMat - missing days for this site                                                   %
% gapMat = [ Dstart Tstart Dend Tend Days ]                                             %
%                                                                                       %	
% a simplified version of GPS_gapcheck.m                                                %
% first created by Lujia Feng Thu Feb 20 11:27:08 SGT 2014                              %
% last modified by Lujia Feng Thu Feb 20 12:23:25 SGT 2014                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

oneday11 = 1/365*1.1; % a little more than 1 day
ymd      = rneu(:,1);
decyr    = rneu(:,2);
datNum   = size(decyr,1);
tdiff    = zeros(datNum,1);  
for ii=2:datNum
   tdiff(ii,1) = decyr(ii)-decyr(ii-1) ;
end
ind    = find(tdiff>oneday11); % find out points not consecutive to previous days
segNum = length(ind);
gapMat = zeros(segNum,5); % matrix for storing time segments; each column represents a continuous time period
for ii=1:segNum
   % start
   str     = num2str(ymd(ind(ii)-1),'%8.0f');
   yy      = str2double(str(1,1:4));
   mm      = str2double(str(1,5:6));
   dd      = str2double(str(1,7:8));
   datnum1 = datenum(yy,mm,dd)+1;
   [yy,mm,dd,~,~,~] = datevec(datnum1);
   gapMat(ii,1) = yy*1e4 + mm*1e2 + dd;
   [ ~,~,gapMat(ii,2) ] = GPS_YEARMMDDtoDCMLYEAR(gapMat(ii,1));
   % end
   str     = num2str(ymd(ind(ii)),'%8.0f');
   yy      = str2double(str(1,1:4));
   mm      = str2double(str(1,5:6));
   dd      = str2double(str(1,7:8));
   datnum2 = datenum(yy,mm,dd)-1;
   [yy,mm,dd,~,~,~] = datevec(datnum2);
   gapMat(ii,3) = yy*1e4 + mm*1e2 + dd;
   [ ~,~,gapMat(ii,4) ] = GPS_YEARMMDDtoDCMLYEAR(gapMat(ii,3));
   % missing days
    gapMat(ii,5) = datnum2-datnum1+1;
end
