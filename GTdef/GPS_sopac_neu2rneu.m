function [ rneu ] = GPS_sopac_neu2rneu(fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_sopac_neu2rneu.m                               %
% read Sopac *.neu files and convert *.neu to *.rneu format                     %
%										%
% INPUT:                                                                        %
% SOPAC neu format                                                              %
% 1         2    3   4     5    6    7     8     9                              %
% YEAR.DCML YEAR DOY NORTH EAST VERT N_err E_err V_err                          %
%										%
% OUTPUT: 									%
% rneu format    							        %
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
%										%
% first created by Lujia Feng Wed Jul  2 14:00:04 SGT 2014                      %
% last modified by Lujia Feng Wed Jul  2 14:26:12 SGT 2014                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_sopac_neu2rneu ERROR: %s does not exist!',fileName); end

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
stdfst = '^[0-9]{4}';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% start reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)   
    % read in one line
    tline = fgetl(fin);
    % test if it is the end of file; exit if yes
    if ischar(tline)~=1, break; end
    % only read lines started with YYMONDD
    isdata = regexp(tline,stdfst,'match');
    if ~isempty(isdata)
       % split data fields
       dataCell = regexp(tline,'\s+','split');
       % convert from cell to string
       data = char(dataCell);		% has trailing spaces filled up to the longest record
       year = str2num(data(2,:));
       doy  = str2num(data(3,:));
       % convert time expression
       [ yearmmdd,mm,dd,decyr ] = GPS_YEARDOYtoYEARMMDD(year,doy);

       day    = [ day;   double(yearmmdd) ];
       time   = [ time;  decyr ];
       nn     = [ nn;    str2num(data(4,:)) ];
       nnErr  = [ nnErr; str2num(data(7,:)) ];
       ee     = [ ee;    str2num(data(5,:)) ];
       eeErr  = [ eeErr; str2num(data(8,:)) ];
       uu     = [ uu;    str2num(data(6,:)) ];
       uuErr  = [ uuErr; str2num(data(9,:)) ];
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
