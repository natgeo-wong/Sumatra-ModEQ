function [ dat123 ] = GPS_readmb(fmbName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GPS_readmb.m				        %
% read individual EOS GAMIT output mb files					%
% mb_SITE_GPS.dat1, mb_SITE_GPS.dat2, mb_SITE_GPS.dat3				%
%										%
% INPUT: 									%
% fmbName - a GAMIT mb file name                               			%
%										%
% GAMIT dat1 = N, dat2, dat3 = U 						%
% 1         2               3     						%
% YEAR.DCML NORTH/EAST/VERT N_err/E_err/V_err                          		%
% unit in [m]									%
%										%
% OUTPUT:                                                                       %
% a matrix with each row is a data point					%
%										%
% first created by lfeng Mon Jul  4 13:20:58 SGT 2011				%
% corrected sign matching problem lfeng Mon Jul 18 17:21:51 SGT 2011		%
% last modified by lfeng Mon Jul 18 17:29:12 SGT 2011				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fmbName,'file')  
   error('GPS_readmb ERROR: %s does not exist!',fmbName); 
end

%%%%%%%%%% open the file %%%%%%%%%%
fprintf(1,'\n.......... GPS_readmb: reading %s ...........\n',fmbName);
fin = fopen(fmbName,'r');

%%%%%%%%%% initialize parameters %%%%%%%%%%
% fst column of data always has format like 2009.00137
stdfst = '[1-2]{1}[0-9]{3}\.';
% data line shouldn't include any letters
letter = '[a-zA-Z_]';
anum = '-?[0-9]+\.[0-9]+';
dat123 = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% start reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % only read lines started with decimal year
    isdata = regexp(tline,stdfst,'match');
    iscomm = regexp(tline,letter,'match');
    if ~isempty(isdata) && isempty(iscomm)
       dataCell = regexp(tline,anum,'match');
       dataStr = char(dataCell);		% cell2mat won't work for numeric arrays
       data = str2num(dataStr);
       dat123 = [ dat123;data' ];
    end
end

fclose(fin);
