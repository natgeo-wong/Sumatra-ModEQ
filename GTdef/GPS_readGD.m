function [ day,time,lat,lon,height,nsErr,ewErr,udErr ] = GPS_readGD(fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           	GPS_readGD.m				        %
% read Miami GD files                             				%
%										%
% INPUT:                                                                        %
% GD FORMAT									%
% 1     2    3          4           5          6        7           8           %
% DATE  GD   Lat(deg)+/-Sigma(m)    Lon(deg)+/-Sigma(m) Height(m)+/-Sigma(m)    %
%										%
% OUTPUT: 									%
% all column vectors in [m]							%
%										%
% first created by lfeng Thu Mar  3 01:59:00 EST 2011				%
% last modified by lfeng Thu Mar  3 12:36:42 EST 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_readGD ERROR: %s does not exist!',fileName); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(fileName,'r');

%%%%%%%%%% initialize parameters %%%%%%%%%%
day = []; time = [];
lon = []; lat = []; height = []; 
nsErr = []; ewErr = []; udErr = [];

% fst column of data always has format like 10MAR14
stdfst = '^[0-9]{2}[A-Z]{3}[0-9]{2}';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% start reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % only read lines started with YYMONDD
    isdata = regexp(tline,stdfst,'match');
    if ~isempty(isdata)
       % split data fields
       dataCell = regexp(tline,'\s+','split');
       % convert from cell to string
       data = char(dataCell);		% has trailing spaces filled up to the longest record
       % convert time expression
       [ yearmmdd,decyr ] = GPS_YYMONDDtoYEARMMDD(data(1,:));

       day    = [ day;    yearmmdd ];
       time   = [ time;   decyr ];
       lat    = [ lat;    str2num(data(3,:)) ];
       nsErr  = [ nsErr; str2num(data(4,:)) ];
       lon    = [ lon;    str2num(data(5,:)) ];
       ewErr  = [ ewErr; str2num(data(6,:)) ];
       height = [ height; str2num(data(7,:)) ];
       udErr  = [ udErr; str2num(data(8,:)) ];
    end
end

fclose(fin);
