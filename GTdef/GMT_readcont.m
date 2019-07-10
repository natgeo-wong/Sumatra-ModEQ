function [ lon,lat,height ] = GMT_readcont(fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%				 GMT_readcont				        %
% read in an ASCII contour or xyz or xy file  					%
%                                                                               %
% INPUT:                                                        		%
%   1     2       3    								% 
%   LON   LAT     DEPTH     							%
%   contour line divider is '>'							%
%   patch divider is '> -Z 0.0'							%
%                                                                               %
% OUTPUT: 									%
%   lon, lat  									%
%   height - normally negative meaning below sea level				%
%   all in column vectors							%
%   nan values used to separate different contour lines                         %
%                                                                               %
% related function: writecont.m							%
% first created by lfeng Tue Jun 21 10:39:34 SGT 2011				%
% changed name from CUBIT_cont2jou_read.m to GMT_readcont lfeng Oct  6 2011     %
% '>' for dividers & '#' for comments lfeng Mon Oct 17 15:16:24 SGT 2011	%
% can read scienfitic expressions lfeng Mon Nov 19 20:13:20 SGT 2012            %
% modified to read in gmt patch lfeng Fri Jun 26 12:25:36 SGT 2015              %
% last modified by lfeng Fri Jun 26 13:06:14 SGT 2015                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GMT_readcont ERROR: %s does not exist!',fileName); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(fileName,'r');

%%%%%%%%%% initialize parameters %%%%%%%%%%
lon    = []; 
lat    = []; 
height = []; 
commentFlag = '^#';		% match the beginning of the line
dividerFlag = '^>';
% data line should only include numbers, - and .
anum = '-?[0-9]+\.?[0-9eE-\+]+';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% start reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % skip comment lines
    if regexp(tline,commentFlag), continue; end;
    % check data or divider
    dflag  = isempty(regexp(tline,dividerFlag));
    if dflag
       dataCell = regexp(tline,anum,'match');
       dataNum = size(dataCell,2);
       if dataNum == 1
          lon    = [ lon; str2num(dataCell{1}) ];
	  lat    = [ lat; nan ];
          height = [ height; nan ];
       elseif dataNum ==2
          lon    = [ lon; str2num(dataCell{1}) ];
          lat    = [ lat; str2num(dataCell{2}) ];
          height = [ height; nan ];
       else
          lon    = [ lon; str2num(dataCell{1}) ];
          lat    = [ lat; str2num(dataCell{2}) ];
          height = [ height; str2num(dataCell{3}) ];
       end
    else 
       % use nan in all fields for divider lines
       lon    = [ lon; nan ];
       lat    = [ lat; nan ];
       value  = nan;
       [ ~,remain ]   = strtok(tline);		% skip >
       [ flag,remain] = strtok(remain);
       if strcmpi(flag,'-Z')
          [ valuestr,remain ] = strtok(remain);
          if ~isempty(valuestr)
             value = str2double(valuestr);
          end
       end
       height = [ height; value ];
    end
end

fclose(fin);
