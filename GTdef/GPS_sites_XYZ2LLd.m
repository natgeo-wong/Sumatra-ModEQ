function [ ] = GPS_sites_XYZ2LLd(finName,foutName,fieldNum)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          GPS_sites_XYZ2LLd.m			          %
% convert *.sites GPS location files with XYZ coordinates to              %
% *.sites files with geographic coordinates                               %
%                                                                         %
% INPUT:                                                                  %
% (1) finName - *.sites files                                             %
% 1      2              3              4                                  %
% Site	 XX             YY             ZZ                                 %
% BICA   -3456566.3795  5159016.6349  1451287.2330                        %
%                                                                         %
% (2) fieldNum - number of columns                                        %
%     fieldNum = 4 or 6                                                   %
%                                                                         %
% OUTPUT: 							          %
% (1) foutName - *.sites files                                            %
% 1      2              3              4                                  %
% Site	 Lon		Lat	       Height [m]                         %
% ABGS   99.387520914   0.220824642    236.2533                           %
%                                                                         %
% first created by Lujia Feng Mon Sep  7 19:15:37 SGT 2015                %
% last modified by Lujia Feng Mon Sep  7 19:36:40 SGT 2015                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==2, fieldNum = 4;  end

[ siteList,loc,period ] = GPS_readsites(finName,fieldNum);

siteNum = length(siteList);
XX = loc(:,1);
YY = loc(:,2);
ZZ = loc(:,3);

[ lat,lon,hh ] = XYZ2LLd(XX,YY,ZZ);
fout = fopen(foutName,'w');
%             1     2    3    4      5      6
fprintf(fout,'#Site    Lon            Lat            Height(m)        Start           End\n');

%%%%%%%%%% write the file %%%%%%%%%%
for ii=1:siteNum
   site = siteList{ii};
   if isempty(period)
      %             1   2      3      4      
      fprintf(fout,'%4s %15.9f %15.9f %12.4f\n',site,lon(ii),lat(ii),hh(ii));
   else
      %             1   2      3      4      5      6
      fprintf(fout,'%4s %15.9f %15.9f %12.4f %12.0f %12.0f\n',site,lon(ii),lat(ii),hh(ii),period(ii,:));
   end
end

fclose(fout);
