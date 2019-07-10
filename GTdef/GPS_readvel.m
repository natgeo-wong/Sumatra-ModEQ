function [ siteList,vel ] = GPS_readvel(fileName,scaleIn,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                GPS_readvel.m				        %
% read *.vel GPS velocity files							%
% *.vel is my velocity file format						%
% only reads lines started with 4-letter site name				%
% fields are separated by spaces						%
%										%
% INPUT:                                                                        %
% 1   2   3   4    5  6  7  8   9   10  11     12 13  14 15  16  17  18         %
% Sta Lon Lat Elev VE VN VU ErE ErN ErU Weight T0 T0D T1 T1D Cne Ceu Cnu        %
% Note: Cne is correlation coefficient between North and East uncertainties!	%
%										%
% OUTPUT: 									%
% (1) siteList - site names stored as a cell			                %
%     note: output is CELL, not String Arrays			                %
% (2) vel  - an nx? array (n is number of data points)				%
%            ?=17 up to all three correlation coefficients			%
%            ?=15 up to Cne correlation coefficient				%
%            ?=14 up to period							%
%            ?=10 up to Weight							%
% scaleIn  - scale to meter in input fileName                                   %
%    if scaleIn = [], an optimal unit will be determined                        %
% scaleOut - scale to meter in output rneu                                      %
%    if scaleOut = [], units won't be changed                                   %
%										%
% first created by Lujia Feng Wed Nov  3 12:28:38 EDT 2010                      %
% use cell array of strings for names lfeng Wed Dec  1 18:10:37 EST 2010	%
% added fields for each row record lfeng Tue Mar  1 20:53:00 EST 2011		%
% removed Ceu Cnu lfeng Sun Apr  3 20:34:00 EDT 2011				%
% added scaleIn & scaleOut lfeng Mon Oct 20 16:58:19 SGT 2014                   %
% last modified by Lujia Feng Mon Oct 20 17:07:54 SGT 2014                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1
   scaleIn = []; scaleOut = [];
end

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_readvel ERROR: %s does not exist!',fileName); end

fin = fopen(fileName,'r');
stdfst = '^\w{4}\s+'; 			% \w = [a-zA-Z_0-9]
siteList = {};
vel = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start Reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % only read lines started with SITE
    isdata = regexp(tline,stdfst,'match');
    if ~isempty(isdata)
       dataCell = regexp(tline,'\s+','split');
       fieldNum = size(dataCell,2);		% the number of fields is not determined
       dataStr = char(dataCell);
       siteList = [ siteList; dataStr(1,1:4) ];
       data = str2num(dataStr(2:fieldNum,:));
       vel = [ vel;data' ];
    end
end
fclose(fin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% check unit %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if scale in the input file is not specified
if ~isempty(scaleOut)
    if isempty(scaleIn)
       error('GPS_readvel ERROR: scaleIn must be provided!');
    end
    scale = scaleIn/scaleOut;
    vel(:,4:9) = vel(:,4:9)*scale;
end
