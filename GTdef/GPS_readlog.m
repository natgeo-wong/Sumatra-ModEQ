function [ stainfo ] = GPS_readlog(fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_readlog.m                               %
% read *.sites GPS location files                                         %
%                                                                         %
% INPUT: *.log GPS station instrumentation files                          %
% 1     2          3         4             5         6             7      %
% Site  StartDate  EndDate   Manufacturer  Receiver  Antenna       Radome %
% PSKI  20020805   20070409  ASHTECH       MICROZ    ASH701945B_M  SCIT   %
% PSKI  20070410   20120131  TRIMBLE       NETRS     ASH701945B_M  SCIT   %
% PSKI  20120201   99999999  TRIMBLE       NETR9     ASH701945B_M  SCIT   %
%                                                                         %
% OUTPUT:                                                                 %
% stainfo - station info structure                                        %
%   stainfo.name [cell]                                                   %
%   stainfo.time [nx2 matrix]                                             %
%   stainfo.make, stainfo.rec, stainfo.ant, stainfo.dom [cell]            %
%                                                                         %
% first created by Lujia Feng Fri Mar  8 19:25:28 SGT 2013                %
% fixed a bug in stainfo.time lfeng Mon May 11 15:28:58 SGT 2015          %
% last modified by Lujia Feng Mon May 11 15:29:05 SGT 2015                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_readlog ERROR: %s does not exist!',fileName); end

fin = fopen(fileName,'r');
stdfst = '^\w{4}\s+'; 			% \w = [a-zA-Z_0-9]
stainfo.name  = {};
stainfo.time  = []; 
stainfo.make  = {};
stainfo.rec   = {};
stainfo.ant   = {};
stainfo.dom   = {};

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
       % site name
       stainfo.name = [ stainfo.name; dataCell(1) ];
       % period
       stainfo.time = [ stainfo.time; str2num(dataCell{2}) str2num(dataCell{3}) ];
       % instrument
       stainfo.make = [ stainfo.make; dataCell(4) ];
       stainfo.rec  = [ stainfo.rec;  dataCell(5) ];
       stainfo.ant  = [ stainfo.ant;  dataCell(6) ];
       stainfo.dom  = [ stainfo.dom;  dataCell(7) ];
    end
end

fclose(fin);
