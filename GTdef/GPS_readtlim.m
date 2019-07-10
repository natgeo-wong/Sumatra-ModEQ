function [ trange ] = GPS_readtlim(fileName,siteName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_readtlim.m			          %
% read *.tlim files that gives time ranges that should be removed in rneu %
% only reads lines started with siteName		                  %
% fields are separated by spaces				          %
%								          %
% INPUT:                                                                  %
% (1) fileName: *.sites files                                             %
% 1      2        3        4      5                                       %
% Site   Dstart   Tstart   Dend   Tend                                    %
% ABGS   99.387520914   0.220824642    236.2533                           %
% (2) siteName: 4-letter site name; if empty, it reads all sites          %
%								          %
% OUTPUT: 							          %
% trange = [ Dstart Tstart Dend Tend ]			                  %
%								          %
% first created by Lujia Feng Thu Nov 28 14:11:18 SGT 2013                %
% added identifying comment lines lfeng Mon Apr  7 11:08:33 SGT 2014      %
% last modified by Lujia Feng Mon Apr  7 11:08:54 SGT 2014                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist(fileName,'file'), error('GPS_readtlim ERROR: %s does not exist!',fileName); end

fin = fopen(fileName,'r');
if isempty(siteName)
    siteName = '^\w{4}\s+'; 			% \w = [a-zA-Z_0-9]
end

trange = [];
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % test if comment line
    iscomment = regexp(tline,'^#','match');
    if ~isempty(iscomment) continue; end
    % only read lines started with siteName
    isdata = regexp(tline,siteName,'match');
    if ~isempty(isdata)
       dataCell = regexp(tline,'\s+','split');
       %fieldNum = size(dataCell,2);	% the number of fields is not determined
       fieldNum = 5;			% only the first four fields used
       dataStr  = char(dataCell);
       data     = str2num(dataStr(2:fieldNum,:));
       trange   = [ trange;data' ];
    end
end

fclose(fin);
