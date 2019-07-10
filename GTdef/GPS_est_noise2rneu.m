function [ ] = GPS_est_noise2rneu(fnName,feName,fuName,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_est_noise2rneu.m                               %
% convert Langbein's est_noise6xx output to *.rneu format                       %
% combine north, east, and vertical files into one file                         %
% WARNING: To run est_noise6xx successfully, all est_noise related files        %
% must be present in the running folder!                                        %
%                                                                               %
% INPUT:                                                                        %
% fnName - resid.out file for north                                             %
% feName - resid.out file for east                                              %
% fuName - resid.out file for vertical                                          %
% resid.out file                                                                %
% 1    2   3                     4     5                                        %
% Year DOY Residual(=Data-Model) Model Data                                     %
% Note: est_noise6xx outputs units in [mm]                                      %
% scaleOut  - scale to meter to output                                          %
%                                                                               %
% OUTPUT:                                                                       %
% *.rneu saved to the current directory                                         %
% 1        2         3      4      5      6         7         8                 %
% YEARMODY YEAR.DCML ModelN ModelE ModelU ResidualN ResidualE ResidualU         %
%                                                                               %
% first created by Lujia Feng Fri Nov 15 15:40:18 SGT 2013                      %
% last modified by Lujia Feng Thu Nov 21 11:51:54 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in data
fprintf(1,'\n.......... GPS_est_noise2rneu ...........\n');
fprintf(1,'\nreading %s\n',fnName);
[ yearN,doyN,residN,modelN,~ ] = read_resid(fnName);
fprintf(1,'\nreading %s\n',feName);
[ yearE,doyE,residE,modelE,~ ] = read_resid(feName);
fprintf(1,'\nreading %s\n',fuName);
[ yearU,doyU,residU,modelU,~ ] = read_resid(fuName);
if ~isequal(yearN,yearE,yearU), error('GPS_est_noise2rneu ERROR: years do not match for N, E, and U!'); end 
if ~isequal(doyN,doyE,doyU),    error('GPS_est_noise2rneu ERROR: doys do not match for N, E, and U!'); end 

% convert to yearmmdd & decyr
yearmmdd = zeros(size(yearN));
decyr    = zeros(size(yearN)); 
num      = length(yearN);
for ii=1:num
    [ yearmmdd(ii),~,~,decyr(ii) ] = GPS_YEARDOYtoYEARMMDD(yearN(ii),doyN(ii));
end

[~,basename,~] = fileparts(fnName);   % cut off . twice
[~,basename,~] = fileparts(basename);
foutName = [ basename '_resid.rneu' ];
fprintf(1,'\nsaving %s\n',foutName);
fout = fopen(foutName,'w');
scaleIn = 0.001; % est_noise6xx outputs in [mm]
fprintf(fout,'# combined %s, %s, and %s using GPS_est_noise2rneu.m\n',fnName,feName,fuName);
fprintf(fout,'# SCALE2M %8.3e\n',scaleOut);
rneu = [ modelN modelE modelU residN residE residU ]*scaleIn/scaleOut;
rneu = [ yearmmdd decyr rneu ];
fprintf(fout,'# 1        2         3      4      5      6         7         8\n');
fprintf(fout,'# YEARMODY YEAR.DCML ModelN ModelE ModelU ResidualN ResidualE ResidualU (Data=Model+Resdual)\n');
fprintf(fout,'%8.0f %14.6f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f\n',rneu'); 
fclose(fout);

function [ year,doy,resid,model,data ] = read_resid(fileName)
if ~exist(fileName,'file'), error('read_resid ERROR: %s does not exist!',fileName); end
fin      = fopen(fileName,'r');
dataCell = textscan(fin,'%f %f %f %f %f','CommentStyle','#');	 % Delimiter default White Space
dataMat  = cell2mat(dataCell);
year     = dataMat(:,1);
doy      = dataMat(:,2);
resid    = dataMat(:,3);
model    = dataMat(:,4);
data     = dataMat(:,5);
fclose(fin);
