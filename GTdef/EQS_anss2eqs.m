function [ eqs ] = EQS_anss2eqs(filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                      EQS_anss2eqs                                             %
% convert ANSS format to eqs format                                                             %
% add decimal years to the end of each line                                                     %
%                                                                                               %
% INPUT:                                                                                        %
% ANSS catolog readable format downloaded from ANSS (Advanced National Seismic System)          %
% Readable 80-col format has no Event ID                                                        %
% http://www.ncedc.org/anss/catalog-search.html                                                 %
% http://www.quake.geo.berkeley.edu/anss/catalog-search.html                                    %
%                                                                                               %
% *.anss file                                                                                   %
% 1          2           3       4        5      6    7    8   9    10   11   12  13            %
% Date       Time        Lat     Lon      Depth  Mag  Magt Nst Gap  Clo  RMS  SRC Event ID      %
% 2002/01/01 19:32:18.48 -2.0320 100.6650 100.00 4.50 Mb   7             0.63 NEI 200201014032  %
% Note: Nst, Gap & Clo are sometimes left blank                                                 %
%       "Unk" is used for no magnitude reported, ignore events flagged as "Unk"                 %
%                                                                                               %
% OUTPUT:                                                                                       %
% *.eqs file                                                                                    %
% 1    2  3  4  5  6       7          8          9       10	    11		12              %
% YEAR MO DY HR MI SS.SSSS LONGITUDE  LATITUDE   DEPTH   MAGNITUDE  EVENT ID    DECYR           %
% 2008 07 04 19 46 30.3100 -118.81384 37.57717   6.3500  0.86                                   %
% 2011 07 10 05 09 06.2600 95.09900    4.61800  35.3000  4.70    201107101008  2011.521918      %
%                                                                                               %
% the same as perl script toeqs                                                                 %
% first created by Lujia Feng Mon Feb 17 11:48:20 SGT 2014                                      %
% last modified by Lujia Feng Mon Feb 17 12:00:14 SGT 2014                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(filename,'file'), error('EQS_anss2eqs ERROR: %s does not exist!',filename); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(filename,'r');

%%%%%%%%%% read in %%%%%%%%%%%
anssCell = textscan(fin,'%96s','CommentStyle','#','Whitespace','','Delimiter',''); % Whitespace is not delimiter
anssCell = anssCell{1};
eqNum    = length(anssCell);
fclose(fin);

%%%%%%%%%% loop through EQs %%%%%%%%%%%
eqs = [];
for ii=1:eqNum
    tline    = anssCell{ii};
    if ~isempty(regexp(tline,'Unk','match'))  
       fprintf('%s ignored!\n',tline);
       continue; 
    end
    oneCell  = regexp(tline,'[/:\s]*','split');
    oneCell  = oneCell([1 2 3 4 5 6 8 7 9 10 end]);
    oneStr   = char(oneCell);
    one      = str2num(oneStr);
    yearmmdd = one(1)*1e4 + one(2)*1e2 + one(3);
    [ ~,~,decyr ] = GPS_YEARMMDDtoDCMLYEAR(yearmmdd);
    eqs = [ eqs; one' decyr ];
end

%%%%%%%%%% save eqs file %%%%%%%%%%%
[ ~,basename,~ ] = fileparts(filename);
foutname = [ basename '.eqs' ];
EQS_saveeqs(eqs,foutname);
