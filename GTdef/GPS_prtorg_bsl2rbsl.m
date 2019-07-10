function [ rneu ] = GPS_prtorg_bsl2rbsl(fileName,siteName1,siteName2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GPS_prtorg_bsl2rbsl.m                                     %
% (1) read bsl file that is extracted from GLOBK prt/org files using                      %
% grep PSBL_GPS-PUTR_GPS /gsoln/globk_gede_*.prt                                          %
% (2) convert *.bsl to *.rbsl format                                                      %
%										          %
% INPUT:                                                                                  %
% fileName - GLOBK prt/org baseline format [mm]                                           %
% 1                     2        3  4           5             6            7              %
% BASELINE                                      Length (m)    Adjust (m)   Sigma (m)      %
% globk_gede_14283e.org MKRW_GPS to PSBL_GPS    16778.72639   0.00742      0.00347        %
%                                                                                         %
% siteName1 & siteName2 - baseline between station names in order                         %
%                                                                                         %
% OUTPUT: 									          %
% rbsl format    							                  %
% 1        2         3        4                                                           %
% YEARMODY YEAR.DCML Baseline Baseline_err                                                %
%										          %
% first created by Lujia Feng Wed Oct 14 19:14:30 SGT 2015                                %
% last modified by Lujia Feng Wed Oct 14 19:17:19 SGT 2015                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_prtorg_bsl2rbsl ERROR: %s does not exist!',fileName); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(fileName,'r');

%%%%%%%%%% initialize parameters %%%%%%%%%%
day   = []; 
time  = [];
bb    = []; 
bbErr = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% start reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % split data fields
    dataCell = regexp(tline,'\s+','split');
    % convert from cell to string
    data    = char(dataCell);		% has trailing spaces filled up to the longest record
    isdata1 = regexp(data(2,:),siteName1,'match');
    isdata2 = regexp(data(4,:),siteName2,'match');
    if ~isempty(isdata1) && ~isempty(isdata2)
       % e.g., basenam = 'globk_gede_14312'
       [ ~,basename,~ ] = fileparts(data(1,:)); % 1st is prt/org filename
       yyStr  = basename(12:13);
       doyStr = basename(14:16);
       yy     = str2num(yyStr);
       if yy>80
          year = 1900 + yy;
       else
          year = 2000 + yy;
       end
       doy    = str2num(doyStr);
       % convert time expression
       [ yearmmdd,mm,dd,decyr ] = GPS_YEARDOYtoYEARMMDD(year,doy);

       day    = [ day;   double(yearmmdd) ];
       time   = [ time;  decyr ];
       bb     = [ bb;    str2num(data(5,:)) ];
       bbErr  = [ bbErr; str2num(data(7,:)) ];
    end
end
fclose(fin);

rbsl = [ day time bb bbErr ];

% save baseline file
[ ~,basename,~ ] = fileparts(fileName);
scaleOut  = 1;
frneuName = [ basename '.rbsl' ];
fout      = fopen(frneuName,'w');
if ~isempty(scaleOut)
    fprintf(fout,'# SCALE2M %8.3e\n',scaleOut);
end
fprintf(fout,'# 1        2         3        4\n');
fprintf(fout,'# YEARMODY YEAR.DCML Baseline Baseline_err\n');
fprintf(fout,'%8.0f %14.6f %14.6f %14.6f\n',rbsl'); 
fclose(fout);
