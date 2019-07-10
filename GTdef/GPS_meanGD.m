function [ lat,lon,height ] = GPS_meanGD(filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           GPS_meanGD.m				        %
% read miami GD files to get site average location				%
% problem may arise if any location record is wrong				%
%										%
% first created by lfeng Fri Oct 22 03:02:09 EDT 2010				%
% check existence lfeng Tue Mar  1 12:45:00 EST 2011				%
% renamed from GPS_readGD to GPS_meanGD lfeng Thu Mar  3 01:57:14 EST 2011	%
% last modified by lfeng Tue Mar  1 12:47:23 EST 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(filename,'file'), error('%s does not exist!',filename); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(filename,'r');

%%%%%%%%%% initialize parameters %%%%%%%%%%
lon = []; lat = []; height = []; 

% fst column of data always has format like 10MAR15
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
       data_cell = regexp(tline,'\s+','split');
       data = char(data_cell);
       lat = [ lat;str2num(data(3,:)) ];
       lon = [ lon;str2num(data(5,:)) ];
       height = [ height;str2num(data(7,:)) ];
    end
end

lat = mean(lat); lon = mean(lon); height = mean(height);
fclose(fin);
