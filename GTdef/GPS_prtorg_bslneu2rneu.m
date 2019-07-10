function [ rneu ] = GPS_prtorg_bslneu2rneu(fileName,bslName,flipFlag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GPS_prtorg_bslneu2rneu.m                                  %
% (1) read bsl file that is extracted from GLOBK prt/org files using                      %
% grep PSBL_GPS-PUTR_GPS /gsoln/globk_gede_*.prt                                          %
% (2) convert *.bsl to *.rneu format                                                      %
%										          %
% INPUT:                                                                                  %
% fileName - GLOBK prt/org baseline format [mm]                                           %
% 1                     2                 3         4    5    6        7    8    9        %
%                                         North     Adj. +-   East     Adj. +-   Rne      %
% globk_gede_14285.prt: PSBL_GPS-PUTR_GPS 6189681.8 -5.7 6.1  564873.0 -2.8 9.4  -0.092   %
% 10          11     12                                                                   %
% Height      Adj    +-                                                                   %
% -325318.2   -16.3  35.8                                                                 %
%                                                                                         %
% bslName - baseline name                                                                 %
% e.g. PSBL_GPS-PUTR_GPS which means the position of PSBL - the position of PUTR          %
% Note: this convention is different from o-files                                         %
%                                                                                         %
% OUTPUT: 									          %
% rneu format    							                  %
% 1        2         3     4    5    6     7     8                                        %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                                    %
%										          %
% first created by Lujia Feng Mon Oct 12 01:09:07 SGT 2015                                %
% added flipFlag lfeng Mon Oct 12 09:08:35 SGT 2015                                       %
% last modified by Lujia Feng Mon Oct 12 09:17:40 SGT 2015                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_prtorg_bslneu2rneu ERROR: %s does not exist!',fileName); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(fileName,'r');

%%%%%%%%%% initialize parameters %%%%%%%%%%
day   = []; 
time  = [];
nn    = []; 
ee    = []; 
uu    = []; 
nnErr = []; 
eeErr = []; 
uuErr = [];

if nargin==2, flipFlag = false;  end

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
    % only read lines with the 2nd column matching bslName
    isdata = regexp(data(2,:),bslName,'match');
    if ~isempty(isdata)
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
       nn     = [ nn;    str2num(data(3,:)) ];
       nnErr  = [ nnErr; str2num(data(5,:)) ];
       ee     = [ ee;    str2num(data(6,:)) ];
       eeErr  = [ eeErr; str2num(data(8,:)) ];
       uu     = [ uu;    str2num(data(10,:)) ];
       uuErr  = [ uuErr; str2num(data(12,:)) ];
    end
end
fclose(fin);

%%%%%%%%%%%%%%% flip sign %%%%%%%%%%%%
if flipFlag
    nn = -nn;
    ee = -ee;
    uu = -uu;
end

%%%%%%%%%%%%%%% convert from mm to m %%%%%%%%%%%%
nn    = 1e-3*nn;
ee    = 1e-3*ee;
uu    = 1e-3*uu;
nnErr = 1e-3*nnErr;
eeErr = 1e-3*eeErr;
uuErr = 1e-3*uuErr;

%%%%%%%%%%%%%%% remove mean %%%%%%%%%%%%
nnMean  = mean(nn);
eeMean  = mean(ee);
uuMean  = mean(uu);
nn      = nn - nnMean;
ee      = ee - eeMean;
uu      = uu - uuMean;

rneu = [ day time nn ee uu nnErr eeErr uuErr ];

% save rneu file
[ ~,basename,~ ] = fileparts(fileName);
if flipFlag
    basename = [ basename(6:9) basename(5) basename(1:4) basename(10:end) ];
end
frneuName = [ basename '.rneu' ];
GPS_saverneu(frneuName,'w',rneu,1);
