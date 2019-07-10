function [ eqsMat,starMat ] = GPS_read_GPSGUIeqs(filename,site)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                   GPS_read_GPSGUIeqs						%
% read *.eqs file output from GPSGUI                                                            %
% only reads lines that match site                                                              %
% sites starting with * are recorded but not directly recorded!                                 %
%                                                                                               %
% INPUT:					  		  			    	%
% 1    2  3  4  5  6       7          8         9     10	11	 12     13     14       %
% YEAR MO DY HR MI SS.SSSS LONGITUDE  LATITUDE  DEPTH MAGNITUDE EVENT ID DECYR  SITE   DIST     %
% 2011 07 10 05 09 06.2600 95.09900   4.61800 35.3000 4.70  201107101008 2011.521918 LEWK 23.64 %
%                                                                                               %
% OUTPUT:                                                                                       %
% eqsMat  - sites directly recorded                                                             %
%         = [ yy mm dd hh min sec lon lat dep mag id decyr dist ]                               %
% starMat - sites recorded but not directly                                                     %
%         = [ yy mm dd hh min sec lon lat dep mag id decyr dist ]                               %
% all column vectors                                                                            %
%                                                                                               %
% first created by Lujia Feng Sat Aug  4 18:19:18 SGT 2012                                      %
% added starMat lfeng Mon May 27 09:59:18 SGT 2013                                              %
% last modified by Lujia Feng Mon May 27 10:18:06 SGT 2013                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(filename,'file'), error('GPS_read_GPSGUIeqs ERROR: %s does not exist!',filename); end

%%%%%%%%%% open the file %%%%%%%%%%
fin     = fopen(filename,'r');
stdfst  = '^\d{4}\s+\w+'; 			% \w = [a-zA-Z_0-9]
starfst = '^\*\d{4}\s+\w+';               
eqsMat  = [];
starMat = [];

%%%%%%%%%% read in %%%%%%%%%%%
while(1)
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % read lines that start with year
    isdata = regexp(tline,stdfst,'match');
    if ~isempty(isdata)
        isdata = regexp(tline,site,'match');
        if isempty(site) || ~isempty(isdata)
            eqs = zeros(1,13);
            for ii=1:12
                [ eqs(1,ii),tline ] = GTdef_read1double(tline);
            end
            [ ~,tline ] = strtok(tline);
            [ eqs(1,13),tline ] = GTdef_read1double(tline);
            eqsMat = [ eqsMat; eqs ];
        end
    end
    % read lines that start with *year
    isdata = regexp(tline,starfst,'match');
    if ~isempty(isdata)
        isdata = regexp(tline,site,'match');
        if isempty(site) || ~isempty(isdata)
	    tline = tline(2:end);  % chop off *
            eqs = zeros(1,13);
            for ii=1:12
                [ eqs(1,ii),tline ] = GTdef_read1double(tline);
            end
            [ ~,tline ] = strtok(tline);
            [ eqs(1,13),tline ] = GTdef_read1double(tline);
            starMat = [ starMat; eqs ];
        end
    end
end
fclose(fin);
[ eqsMat,ind  ] = sortrows(eqsMat);
[ starMat,ind ] = sortrows(starMat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GTdef_read1double.m				%
% 	      function to read in one double number from a string		%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ value,tline ] = GTdef_read1double(str)

[str1,tline] = strtok(str);
if isempty(str1)||strncmp(str1,'#',1)
    error('GPS_read_GPSGUIeqs ERROR: The input file is wrong!');
end
value = str2double(str1);
