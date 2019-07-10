function [ siteList,siteqs,flagList ] = EQS_readsiteqs(filename,fieldnum)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                       EQS_readsiteqs                                                    %
% read in a siteqs file                                                                                   %
%                                                                                                         %
% INPUT:                                                                                                  %
% 1    2   3   4    5   6   7       8       9         10  11           12          13   14       15       %
% Year Mon Day Hour Min Sec Lon     Lat     Depth(km) Mag ID           Decyr       Site Dist(km) Flag     %
% 2004 12 26 00 58 53.4500 95.98200 3.29500 30.0000  9.00 200412264001 2004.984973 ABGS 510.58   recorded %
% fieldnum - number of fields [14]                                                                        %
%                                                                                                         %
% OUTPUT:                                                                                                 %
% (1) siteList - site names stored as a cell                                                              %
%     note: output is CELL, not String Arrays                                                             %
% (2) siteqs = [ yy mm dd hh min sec lon lat dep mag id decyr dist ]                                      %
%     all column vectors                                                                                  %
%                                                                                                         %
% first created by Lujia Feng Tue Feb 18 11:39:37 SGT 2014                                                %
% corrected stdfst for stations that have numbers as their names lfeng Sat May 28 18:12:03 SGT 2016       %
% last modified by Lujia Feng Sat May 28 18:12:33 SGT 2016                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(filename,'file'), error('EQS_readsiteqs ERROR: %s does not exist!',filename); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(filename,'r');
stdfst   = '^\d{4} \d{2} \d{2}\s+';
siteList = {};
flagList = {};
siteqs   = [];
if nargin==1, fieldnum=14; end

%%%%%%%%%% read in %%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % only read lines started with Year
    isdata = regexp(tline,stdfst,'match');
    if ~isempty(isdata)
        dataCell = regexp(tline,'\s+','split');
        dataStr  = char(dataCell);
        if fieldnum==14
            siteList = [ siteList; dataStr(end-1,1:4) ];
            eqs      = str2num(dataStr(1:end-2,:));
            dist     = str2num(dataStr(end,:));
            siteqs   = [ siteqs; eqs' dist ];
        else
            siteList = [ siteList; dataStr(end-2,1:4) ];
            flagList = [ flagList; dataStr(end,:) ];
            eqs      = str2num(dataStr(1:end-3,:));
            dist     = str2num(dataStr(end-1,:));
            siteqs   = [ siteqs; eqs' dist ];
        end
    end
end

fclose(fin);
