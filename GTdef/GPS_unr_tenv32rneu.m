function [ rneu ] = GPS_unr_tenv32rneu(fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_unr_tenv32rneu.m                              %
% read UNR Nevada Geodetic Lab *.tenv3 files                                    %
% and convert *.tenv3 to *.rneu format                                          %
%										%
% INPUT:                                                                        %
% tenv3 format									%
% 1    2       3         4   5    6 7                                           %
% site YYMMMDD yyyy.yyyy MJD week d refee                                       %
% 8      9       10    11       12    13                                        %
% e0(m)  east(m) n0(m) north(m) u0(m) up(m)                                     %
% 14     15       16       17       18      19      20                          %
% ant(m) sig_e(m) sig_n(m) sig_u(m) corr_en corr_eu corr_nu                     %
%										%
% OUTPUT: 									%
% rneu format   							        %
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
%										%
% first created by Lujia Feng Thu Jun 26 17:40:17 SGT 2014                      %
% added removing mean lfeng Fri Jun 27 10:28:52 SGT 2014                        %
% last modified by Lujia Feng Fri Jun 27 10:33:46 SGT 2014                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_unr_tenv32rneu ERROR: %s does not exist!',fileName); end

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

% 2nd column of data always has format like 10MAR14
std2nd = '[0-9]{2}[A-Z]{3}[0-9]{2}';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% start reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % only read lines started with YYMONDD
    isdata = regexp(tline,std2nd,'match');
    if ~isempty(isdata)
       % split data fields
       dataCell = regexp(tline,'\s+','split');
       % convert from cell to string
       data = char(dataCell);		% has trailing spaces filled up to the longest record

       % convert time expression
       [ yearmmdd,decyr ] = GPS_YYMONDDtoYEARMMDD(data(2,:));

       day    = [ day;   double(yearmmdd) ];
       time   = [ time;  decyr ];
       nn     = [ nn;    str2num(data(11,:)) ];
       nnErr  = [ nnErr; str2num(data(16,:)) ];
       ee     = [ ee;    str2num(data(9,:))  ];
       eeErr  = [ eeErr; str2num(data(15,:)) ];
       uu     = [ uu;    str2num(data(13,:)) ];
       uuErr  = [ uuErr; str2num(data(17,:)) ];
    end
end
fclose(fin);

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
frneuName = [ basename '.rneu' ];
GPS_saverneu(frneuName,'w',rneu,1);
