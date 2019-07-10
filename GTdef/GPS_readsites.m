function [ siteList,loc,period ] = GPS_readsites(fileName,fieldNum)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_readsites.m			          %
% read *.sites GPS location files				          %
% only reads lines started with 4-letter site name		          %
% fields are separated by spaces				          %
%                                                                         %
% INPUT:                                                                  %
% (1) fileName - *.sites files                                            %
% 1      2              3              4                                  %
% Site	 Lon		Lat	       Height [m]                         %
% ABGS   99.387520914   0.220824642    236.2533                           %
% (2) fieldNum - number of columns                                        %
%     fieldNum = 4 or 6                                                   %
%                                                                         %
% OUTPUT: 							          %
% (1) siteList - site names stored as a cell			          %
%     note: output is CELL, not String Arrays			          %
% (2) loc = [ lon lat height ] (an nx3 array)                             %
% (3) period = [ start end ] (an nx2 array)                               %
%     n is number of data points                                          %
%                                                                         %
% first created by Lujia Feng Wed Jul 27 15:11:06 SGT 2011                %
% added fieldNum lfeng Mon Feb 17 15:36:24 SGT 2014                       %
% last modified by Lujia Feng Mon Feb 17 15:40:53 SGT 2014                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_readsites ERROR: %s does not exist!',fileName); end

fin = fopen(fileName,'r');
stdfst   = '^\w{4}\s+';        % \w = [a-zA-Z_0-9]
siteList = {};
loc      = [];
period   = [];

if nargin==1, fieldNum = 4;  end

%%%%%%%%%%%%%%%%%% start reading %%%%%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % only read lines started with SITE
    isdata = regexp(tline,stdfst,'match');
    if ~isempty(isdata)
        dataCell = regexp(tline,'\s+','split');
        %fieldNum = size(dataCell,2);	% the number of fields is not determined
        dataStr = char(dataCell);
        siteList = [ siteList; dataStr(1,1:4) ];
        data = str2num(dataStr(2:fieldNum,:));
        if fieldNum>=4
            loc = [ loc;data(1:3)' ];
        end
        if fieldNum>=6
            period = [ period;data(4:5)' ];
        end
    end
end

fclose(fin);
