function [ ] = GPS_est_noise_sum(frneuName,siteName,folderName,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GPS_est_noise_sum.m                                 %
% summarize output files from Langbein's est_noise code                             %
% combine seperate 3 components into one file                                       %
%                                                                                   %
% INPUT:                                                                            %
% frneuName  - *.rneu that est_noise is based on                                    %
% siteName   - a 4-letter string                                                    %
% folderName - folder that has output files                                         %   
% scaleOut   - scale to meter in output                                             % 
% Note: est_noise6xx outputs units in [mm]                                          %
% This script reads other related files according to file name conventions!         %
%                                                                                   %
% --------------------------------------------------------------------------------- %
% est_noise output files for east component                                         %
% e.g. ABGS_res1site.rneu                                                           %
% ABGS_res1site.re_prob1.out - time, data and A matrix after redundencies removed   %
% ABGS_res1site.re_prob2.out - time, data and A matrix before redundencies removed  % 
% ABGS_res1site.re_cross_cor.out -                                                  %
% ABGS_res1site.re_max.dat   - MLE parameters                                       %
% MLE 0 data_points whiteAmp whiteErr powerAmp powerAmpErr powerIndex powerIndexErr %
% ABGS_res1site.re_max.out                                                          %
% ABGS_res1site.re_model.dat - model parameters                                     %
% b bErr v vErr                                                                     %
% ABGS_res1site.re_model.out -                                                      %
% ABGS_res1site.re_resid.out - year doy residual calculated data                    %
% --------------------------------------------------------------------------------- %
%                                                                                   %
% OUTPUT:                                                                           %
% *.noisum - a noise summary file for frneuName est_noise output                    %
%            save to the current directory                                          %
%                                                                                   %
% first created by Lujia Feng Wed Nov 20 12:06:58 SGT 2013                          %
% index=0 for white noise lfeng Mon Jan  6 18:02:46 SGT 2014                        %
% last modified by Lujia Feng Mon Jan  6 18:02:55 SGT 2014                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(1,'\n.......... GPS_est_noise_sum ...........\n');
[~,basename,~] = fileparts(frneuName);
fePrefix = [ folderName basename '.re_' ];
fnPrefix = [ folderName basename '.rn_' ]; 
fuPrefix = [ folderName basename '.ru_' ]; 

%----------------------- read rneu -----------------------
fprintf(1,'\nreading %s\n',frneuName);
[ rneu ] = GPS_readrneu(frneuName,[],[]);
yearmmdd = rneu(:,1);
decyr    = rneu(:,2);
D1 = yearmmdd(1); D2 = yearmmdd(end);
T1 = decyr(1); T2 = decyr(end); TT = T2 - T1; % length of time period

%----------------------- read max.dat -----------------------
maxSuffix = 'max.dat';
fnMax = [ fnPrefix maxSuffix ]; [ maxdatN ] = read_maxdat(fnMax);
feMax = [ fePrefix maxSuffix ]; [ maxdatE ] = read_maxdat(feMax);
fuMax = [ fuPrefix maxSuffix ]; [ maxdatU ] = read_maxdat(fuMax);

%----------------------- read model.dat -----------------------
modelSuffix = 'model.dat';
fnModel = [ fnPrefix modelSuffix ]; [ moddatN ] = read_moddat(fnModel);
feModel = [ fePrefix modelSuffix ]; [ moddatE ] = read_moddat(feModel);
fuModel = [ fuPrefix modelSuffix ]; [ moddatU ] = read_moddat(fuModel);

%----------------------- fit info -----------------------
foutName = [ basename '.noisum' ];
fout = fopen(foutName,'w');
fprintf(1,'\nsaving %s\n',foutName);
fprintf(fout,'# 1    2    3  4    5      6  \n');
fprintf(fout,'# Site STAT TT Pnts Params MLE\n');
fprintf(fout,'%4s STAT_N %12.4f %8d %6d %15.8f\n',siteName,TT,maxdatN.pntNum,maxdatN.parNum,maxdatN.mle);
fprintf(fout,'%4s STAT_E %12.4f %8d %6d %15.8f\n',siteName,TT,maxdatE.pntNum,maxdatE.parNum,maxdatE.mle);
fprintf(fout,'%4s STAT_U %12.4f %8d %6d %15.8f\n',siteName,TT,maxdatU.pntNum,maxdatU.parNum,maxdatU.mle);

%----------------------- unit info -----------------------
scaleIn = 0.001; % est_noise6xx outputs in [mm]
if ~isempty(scaleOut)
    fprintf(fout,'# 1    2       3\n');
    fprintf(fout,'# Site SCALE2M ScaleToMeter Unit\n');
    fprintf(fout,'%4s SCALE2M %8.3e\n',siteName,scaleOut);
end

%----------------------- basic linear info -----------------------
fprintf(fout,'# 1   2     3        4      5      6    7     8          9\n');
fprintf(fout,'# Sta Comp  Fittype  Dstart Tstart Dend Tend  Intercept  Rate\n');
% base model = intercept + rate*t
fprintf(fout,'%4s N linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e FIT\n',siteName,D1,T1,D2,T2,moddatN.intercept(1)*scaleIn/scaleOut,moddatN.rate(1)*scaleIn/scaleOut);
fprintf(fout,'%4s E linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e FIT\n',siteName,D1,T1,D2,T2,moddatE.intercept(1)*scaleIn/scaleOut,moddatE.rate(1)*scaleIn/scaleOut);
fprintf(fout,'%4s U linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e FIT\n',siteName,D1,T1,D2,T2,moddatU.intercept(1)*scaleIn/scaleOut,moddatU.rate(1)*scaleIn/scaleOut);
% base model error
fprintf(fout,'%4s N linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e ERR\n',siteName,D1,T1,D2,T2,moddatN.intercept(2)*scaleIn/scaleOut,moddatN.rate(2)*scaleIn/scaleOut);
fprintf(fout,'%4s E linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e ERR\n',siteName,D1,T1,D2,T2,moddatE.intercept(2)*scaleIn/scaleOut,moddatE.rate(2)*scaleIn/scaleOut);
fprintf(fout,'%4s U linear %8.0f %8.5f %8.0f %8.5f %12.4e %12.4e ERR\n',siteName,D1,T1,D2,T2,moddatU.intercept(2)*scaleIn/scaleOut,moddatU.rate(2)*scaleIn/scaleOut);

%%----------------------- seasonal info -----------------------
%if ~isempty(fqMat)
%    fprintf(fout,'# 1    2     3        4     5      6      7     8     9\n');
%    fprintf(fout,'# Site Comp  Fittype  fqSin fqCos  Tstart Tend  ASin  ACos\n');
%    % seasonal model = A*sin(2pi*fqSin*t) + B*cos(2pi*fqCos*t)
%    fqNum = size(fqMat,1);
%    for ii=1:fqNum
%        fqS = fqMat(ii,1);         fqC = fqMat(ii,2);
%        T1  = ampMat(ii,fstind+1); T2  = ampMat(ii,fstind+2);
%        fprintf(fout,'%4s N seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e FIT\n',siteName,fqS,fqC,T1,T2,nnS,nnC);
%        fprintf(fout,'%4s E seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e FIT\n',siteName,fqS,fqC,T1,T2,eeS,eeC);
%        fprintf(fout,'%4s U seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e FIT\n',siteName,fqS,fqC,T1,T2,uuS,uuC);
%        fprintf(fout,'%4s N seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e ERR\n',siteName,fqS,fqC,T1,T2,nnS,nnC);
%        fprintf(fout,'%4s E seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e ERR\n',siteName,fqS,fqC,T1,T2,eeS,eeC);
%        fprintf(fout,'%4s U seasonal %12.4e %12.4e %8.5f %8.5f %12.4e %12.4e ERR\n',siteName,fqS,fqC,T1,T2,uuS,uuC);
%    end
%end

%----------------------- noise info -----------------------
fprintf(fout,'# 1    2     3        4      5      6    7     8     9\n');
fprintf(fout,'# Site Comp  Fittype  Dstart Tstart Dend Tend  Index Power\n');
% index = 0 -> white noise     
fprintf(fout,'%4s N %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e FIT\n',...
             siteName,'noise',D1,T1,D2,T2,0.0,maxdatN.whiteAmp(1)*scaleIn/scaleOut);
fprintf(fout,'%4s E %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e FIT\n',...
       	     siteName,'noise',D1,T1,D2,T2,0.0,maxdatE.whiteAmp(1)*scaleIn/scaleOut);
fprintf(fout,'%4s U %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e FIT\n',...
             siteName,'noise',D1,T1,D2,T2,0.0,maxdatU.whiteAmp(1)*scaleIn/scaleOut);
fprintf(fout,'%4s N %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e ERR\n',...
             siteName,'noise',D1,T1,D2,T2,0.0,maxdatN.whiteAmp(2)*scaleIn/scaleOut);
fprintf(fout,'%4s E %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e ERR\n',...
       	     siteName,'noise',D1,T1,D2,T2,0.0,maxdatE.whiteAmp(2)*scaleIn/scaleOut);
fprintf(fout,'%4s U %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e ERR\n',...
             siteName,'noise',D1,T1,D2,T2,0.0,maxdatU.whiteAmp(2)*scaleIn/scaleOut);
% index > 0
fprintf(fout,'%4s N %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e FIT\n',...
             siteName,'noise',D1,T1,D2,T2,maxdatN.power1Index(1),maxdatN.power1Amp(1)*scaleIn/scaleOut);
fprintf(fout,'%4s E %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e FIT\n',...
       	     siteName,'noise',D1,T1,D2,T2,maxdatE.power1Index(1),maxdatE.power1Amp(1)*scaleIn/scaleOut);
fprintf(fout,'%4s U %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e FIT\n',...
             siteName,'noise',D1,T1,D2,T2,maxdatU.power1Index(1),maxdatU.power1Amp(1)*scaleIn/scaleOut);
fprintf(fout,'%4s N %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e ERR\n',...
             siteName,'noise',D1,T1,D2,T2,maxdatN.power1Index(2),maxdatN.power1Amp(2)*scaleIn/scaleOut);
fprintf(fout,'%4s E %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e ERR\n',...
       	     siteName,'noise',D1,T1,D2,T2,maxdatE.power1Index(2),maxdatE.power1Amp(2)*scaleIn/scaleOut);
fprintf(fout,'%4s U %s %8.0f %8.5f %8.0f %8.5f %12.6f %12.4e ERR\n',...
             siteName,'noise',D1,T1,D2,T2,maxdatU.power1Index(2),maxdatU.power1Amp(2)*scaleIn/scaleOut);
fclose(fout);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ maxdat ] = read_maxdat(fileName)
if ~exist(fileName,'file'), error('read_maxdat ERROR: %s does not exist!',fileName); end
fprintf(1,'\nreading %s\n',fileName);
fin = fopen(fileName,'r');
%                        1  2  3  4  5  6  7  8  9  10 11 12  13  14  15  16  17  18  19  20
dataCell = textscan(fin,'%s %f %f %d %d %f %f %f %f %f %f %*f %*f %*f %*f %*f %*f %*f %*f %*f','CommentStyle','#');
maxdat.name        = dataCell{1}; % file name
maxdat.mle         = dataCell{2}; % maximum likelihood 
maxdat.pntNum      = dataCell{4}; % number of data points
maxdat.parNum      = dataCell{5}; % number of parameters
maxdat.whiteAmp    = [dataCell{6} dataCell{7}];   % white noise amplitude & error
maxdat.power1Amp   = [dataCell{8} dataCell{9}];   % 1st power law noise amplitude & error
maxdat.power1Index = [dataCell{10} dataCell{11}]; % 1st power law noise index & error 
maxdat.power2Amp   = [0 0]; % 2nd power law noise amplitude & error
maxdat.power2Index = [0 0]; % 2nd power law noise index & error 
fclose(fin);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ moddat ] = read_moddat(fileName)
if ~exist(fileName,'file'), error('read_maxdat ERROR: %s does not exist!',fileName); end
fprintf(1,'\nreading %s\n',fileName);
fin = fopen(fileName,'r');
%                        1  2  3   4  5  6  7 
dataCell = textscan(fin,'%s %f %s %f %f %s %f','CommentStyle','#');
moddat.name       = dataCell{1};
moddat.intercept  = [dataCell{2} dataCell{4}]; % intercept & error
moddat.rate       = [dataCell{5} dataCell{7}]; % rate & error
fclose(fin);
