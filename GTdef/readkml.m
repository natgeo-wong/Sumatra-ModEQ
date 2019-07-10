function [ lon,lat,height ] = readkml(fkmlName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            readkml.m                                 %
% read coordinates in eoogle *.kml files                               %
%                                                                      %
% INPUT:                                                               %
% fkmlName -  name of kml files                                        %
%                                                                      %
% OUTPUT:                                                              %
% lon,lat,height  - column vectors                                     %
%                                                                      %
% first created by lfeng Thu Nov 15 22:40:57 SGT 2012                  %
% last modified by lfeng Thu Nov 15 23:11:13 SGT 2012                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
%if ~exist(fkmlName,'file'), error('readkml ERROR: %s does not exist!',fkmlName); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(fkmlName,'r');

values = [];
startFlag = '<coordinates>';
endFlag   = '</coordinates>';
start = false;
%%%%%%%%%% start reading %%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % check if data starts
    if start
       dataCell = regexp(tline,'[,|\s]','split');
       dataNum  = size(dataCell,2);
       for ii=1:dataNum
           str   = dataCell{ii};
           dflag = ~isempty(regexp(str,'[0-9]'));
	   if dflag
               values = [ values; str2num(str) ];
	   end
       end
       start  = false;
    end
    start  = ~isempty(regexp(tline,startFlag));
end
dataMat = reshape(values,3,[])';
lon     = dataMat(:,1);
lat     = dataMat(:,2);
height  = dataMat(:,3);
fclose(fin);
