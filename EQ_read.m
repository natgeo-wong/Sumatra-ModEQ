function [ data ] = EQ_read (inFile)

%                                  EQ_read.m
%             Reads in .eq files to extract event information
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This script reads in the event information line by line based on flags at
% the front of each line.
%
% INPUT:
% -- inFile : file name
%
% OUTPUT:
% -- data   : information of earthquake event
%
% FORMAT OF CALL: EQ_read (file)
% 
% OVERVIEW:
% 1) This function will first open the file for reading and set aside a
%    data structure to hold the information
%
% 2) The function will then read in the file line by line and break it up
%    into flags and input parameters.  Based on the flag, the data will go
%    into each respective holder
%
% 3) When there are no more lines, then the function ends.
%
% VERSIONS:
% 1) -- Final version validated on 20190812 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%% CHECK IF FILE EXISTS %%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist(inFile,'file') ~= 2, error('File does not exist!');
else, finFile = fopen(inFile,'r');
end

%%%%%%%%%%%%%%%%%%%%%%%%% INITIALIZING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%

data.EQID = {}; data.type = []; data.xyz  = []; data.dgeo = [];
data.slip = []; data.inv0 = []; data.invX = []; data.invN = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%% READ FILE BY LINE %%%%%%%%%%%%%%%%%%%%%%%%%%%%

while 1
    
    tline = fgetl(finFile); % read in line by line
    if ischar(tline) ~= 1, break; end % exit if end file
    
    [ flag,input ] = strtok(tline); % read flag for each line
    if (EQ_read_skip(flag)), continue; end % omit comment lines
    
    if     strcmpi (flag,'EQID'), data.EQID = strtrim(input); %#ok<*ST2NM>
    elseif strcmpi (flag,'Type'), data.type = str2num(input);
    elseif strcmpi (flag,'XYZ'),  data.xyz  = str2num(input); 
    elseif strcmpi (flag,'DGeo'), data.dgeo = str2num(input);
    elseif strcmpi (flag,'Slip'), data.slip = str2num(input);
    elseif strcmpi (flag,'Inv0'), data.inv0 = str2num(input);
    elseif strcmpi (flag,'InvX'), data.invX = str2num(input);
    elseif strcmpi (flag,'InvN'), data.invN = str2num(input);
    end
    
end

end

function out = EQ_read_skip(str)

if strncmpi(str,'#',1) || isempty(str), out = true(); 
else, out = false();
end

end