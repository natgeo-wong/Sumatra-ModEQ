function [ rneu,rbsl ] = GPS_ofile_bsl2rneu(fileName,bslName,flipFlag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GPS_ofile_bsl2rneu.m                                      %
% (1) read bsl file that is extracted from GAMIT O-files using                            %
% grep -h PSBL_PUTR */???/o*a.??? | grep 'X N'                                            %
% (2) convert *.bsl to *.rneu format                                                      %
%										          %
% INPUT:                                                                                  %
% fileName - GAMIT O-file baseline format [m]                                             %
% 1         2         3 4          5  6      7 8        9  10     11 12       13 14       %
% PSBL_PUTR 2014.285X N -6150.9059 +- 0.0143 E 832.8015 +- 0.0321 U  322.2887 +- 0.0506   %
% 15 16        17 18     19           20            21  22         23        24           %
% L  6215.3899 +- 0.0143 Correlations (N-E,N-U,E-U) =   -0.03912   0.32603   0.00978      %
%                                                                                         %
% bslName - baseline name                                                                 %
% e.g. PSBL_PUTR which means the position of PUTR - the position of PSBL                  %
% Note: this convention is different from GLOBK prt/org files                             %
%                                                                                         %
% flipFlag - if set true, switch the order of the stations                                %
%                                                                                         %
% OUTPUT: 									          %
% rneu format                                                                             %
% 1        2         3     4    5    6     7     8                                        %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                                    %
%										          %
% rbsl format                                                                             %
% 1        2         3        4                                                           %
% YEARMODY YEAR.DCML BASELINE BASELINE_err                                                %
%										          %
% first created by Lujia Feng Thu Oct  1 12:57:43 SGT 2015                                %
% added flipFlag lfeng Mon Oct 12 09:08:35 SGT 2015                                       %
% added saving baseline lfeng Wed Oct 14 11:35:04 SGT 2015                                %
% found a bug if U-12451391.2489 +-   0.0221 exists lfeng Tue Feb  2 11:35:00 SGT 2016    %
% added ignoring comment lines lfeng Wed Feb  3 15:27:29 SGT 2016                         %
% last modified by Lujia Feng Wed Feb  3 15:28:07 SGT 2016                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% check if this file exists %%%%%%%%%%
if ~exist(fileName,'file'), error('GPS_ofile_bsl2rneu ERROR: %s does not exist!',fileName); end

%%%%%%%%%% open the file %%%%%%%%%%
fin = fopen(fileName,'r');

%%%%%%%%%% initialize parameters %%%%%%%%%%
day   = []; 
time  = [];
nn    = []; 
ee    = []; 
uu    = []; 
bb    = [];
nnErr = []; 
eeErr = []; 
uuErr = [];
bbErr = [];

if nargin==2, flipFlag = false;  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% start reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)   
   % read in one line
   tline = fgetl(fin);
   % test if it is the end of file; exit if yes
   if ischar(tline)~=1, break; end
   % omit '#' comment lines
   if strncmp(tline,'#',1), continue; end

   % only read lines started with bslName
   isdata = regexp(tline,bslName,'match');
   if ~isempty(isdata)
      % split data fields
      dataCell = regexp(tline,'\s+','split');
      % convert from cell to string
      data    = char(dataCell);		% has trailing spaces filled up to the longest record
      yearStr = data(2,1:4);
      doyStr  = data(2,6:8);
      year    = str2num(yearStr);
      doy     = str2num(doyStr);
      % convert time expression
      [ yearmmdd,mm,dd,decyr ] = GPS_YEARDOYtoYEARMMDD(year,doy);

      day    = [ day;   double(yearmmdd) ];
      time   = [ time;  decyr ];

      % data
      colnum = size(data,1);
      for ii=3:colnum
         if strncmp(data(ii,:),'N',1)
            if strncmp(data(ii,:),'N ',2)
               nn    = [ nn;    str2num(data(ii+1,:)) ];
               nnErr = [ nnErr; str2num(data(ii+3,:)) ];
            else
               nn    = [ nn;    str2num(data(ii,2:end)) ];
               nnErr = [ nnErr; str2num(data(ii+2,:)) ];
            end
         end
         if strncmp(data(ii,:),'E',1)
            if strncmp(data(ii,:),'E ',2)
               ee    = [ ee;    str2num(data(ii+1,:)) ];
               eeErr = [ eeErr; str2num(data(ii+3,:)) ];
            else
               ee    = [ ee;    str2num(data(ii,2:end)) ];
               eeErr = [ eeErr; str2num(data(ii+2,:)) ];
            end
         end
         if strncmp(data(ii,:),'U',1)
            if strncmp(data(ii,:),'U ',2)
               uu    = [ uu;    str2num(data(ii+1,:)) ];
               uuErr = [ uuErr; str2num(data(ii+3,:)) ];
            else
               uu    = [ uu;    str2num(data(ii,2:end)) ];
               uuErr = [ uuErr; str2num(data(ii+2,:)) ];
            end
         end
         if strncmp(data(ii,:),'L',1)
            if strncmp(data(ii,:),'L ',2)
               bb    = [ bb;    str2num(data(ii+1,:)) ];
               bbErr = [ bbErr; str2num(data(ii+3,:)) ];
            else
               bb    = [ bb;    str2num(data(ii,2:end)) ];
               bbErr = [ bbErr; str2num(data(ii+2,:)) ];
            end
         end
      end
   end
end
fclose(fin);

%%%%%%%%%%%%%%% flip sign %%%%%%%%%%%%
if flipFlag
   nn = -nn;
   ee = -ee;
   uu = -uu;
end

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
scaleOut  = 1;
frneuName = [ basename '.rneu' ];
GPS_saverneu(frneuName,'w',rneu,scaleOut);

% save baseline file
frneuName = [ basename '.rbsl' ];
fout = fopen(frneuName,'w');
if ~isempty(scaleOut)
    fprintf(fout,'# SCALE2M %8.3e\n',scaleOut);
end
rbsl = [ day time bb bbErr ];
fprintf(fout,'# 1        2         3        4\n');
fprintf(fout,'# YEARMODY YEAR.DCML Baseline Baseline_err\n');
fprintf(fout,'%8.0f %14.6f %18.6f %14.6f\n',rbsl'); 
fclose(fout);
