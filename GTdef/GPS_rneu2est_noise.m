function [ ] = GPS_rneu2est_noise(frneuName,scaleIn,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_rneu2est_noise.m                               %
% convert *.rneu to Langbein's est_noise6xx format                              %
% est_noise6xx accepts 3 file formats                                           %
% otr: year doy data error                                                      %
% otd: yearmmdd data error                                                      %
% otx: year mon day  data error                                                 %
% Type otr has been thoroughly tested, so this code converts rneu to type otr   %
% Note: est_noise6xx takes units in [mm]                                        %
%       input data files cannot have comment lines!                             %
% WARNING: To run est_noise6xx successfully, all est_noise related files        %
% must be present in the running folder!                                        %
%                                                                               %
% INPUT:                                                                        %
% frneuName - *.rneu                                                            %
% 1        2         3     4    5    6     7     8                              %
% YEARMODY YEAR.DCML NORTH EAST VERT N_err E_err V_err                          %
% scaleIn   - scale to meter in input fileName                                  %
%    if scaleIn = [], an optimal unit will be determined                        %
% scaleOut  - scale to meter in output rneu                                     %
%    if scaleOut = [], units won't be changed                                   %
% scaleIn & scaleOut is used in GPS_readrneu.m                                  %
%                                                                               %
% OUTPUT:                                                                       %
% *.re *.rn *.ru                                                                %
% 1    2   3    4                                                               %
% YEAR DOY DATA ERROR                                                           %
%                                                                               %
% first created by Lujia Feng Wed Nov 13 11:45:41 SGT 2013                      %
% last modified by Lujia Feng Thu Nov 14 15:29:32 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in data
fprintf(1,'\n.......... GPS_rneu2est_noise ...........\n');
fprintf(1,'\nreading %s\n',frneuName);
scaleOut = 0.001; % est_noise6xx takes [mm]
[ rneu ] = GPS_readrneu(frneuName,scaleIn,scaleOut);
yearmmdd = rneu(:,1);
nn       = rneu(:,3);
ee       = rneu(:,4);
uu       = rneu(:,5);
nnErr    = rneu(:,6);
eeErr    = rneu(:,7);
uuErr    = rneu(:,8);

% convert to year & doy
year     = zeros(size(yearmmdd));
doy      = zeros(size(yearmmdd)); 
num      = length(year);
for ii=1:num
    [ year(ii),doy(ii),~ ] = GPS_YEARMMDDtoDCMLYEAR(yearmmdd(ii));
end

% output to 3 files
[ ~,basename,~ ] = fileparts(frneuName);
frnName = [ basename '.rn' ];
freName = [ basename '.re' ];
fruName = [ basename '.ru' ];

% save *.rn
fprintf(1,'saving %s\n',frnName);
fout = fopen(frnName,'w');
%fprintf(fout,'# converted from %s using GPS_rneu2est_noise.m\n',frneuName);
%fprintf(fout,'# 1    2   3     4\n');
%fprintf(fout,'# Year DOY North North_Err\n');
out = [ year doy nn nnErr ];
fprintf(fout,'%4.0f %14.5f %12.5f %12.5f\n',out'); 
fclose(fout);

% save *.re
fprintf(1,'saving %s\n',freName);
fout = fopen(freName,'w');
%fprintf(fout,'# converted from %s using GPS_rneu2est_noise.m\n',frneuName);
%fprintf(fout,'# 1    2   3    4\n');
%fprintf(fout,'# Year DOY East East_Err\n');
out = [ year doy ee eeErr ];
fprintf(fout,'%4.0f %14.5f %12.5f %12.5f\n',out'); 
fclose(fout);

% save *.ru
fprintf(1,'saving %s\n',fruName);
fout = fopen(fruName,'w');
%fprintf(fout,'# converted from %s using GPS_rneu2est_noise.m\n',frneuName);
%fprintf(fout,'# 1    2   3  4\n');
%fprintf(fout,'# Year DOY Up Up_Err\n');
out = [ year doy uu uuErr ];
fprintf(fout,'%4.0f %14.5f %12.5f %12.5f\n',out'); 
fclose(fout);
