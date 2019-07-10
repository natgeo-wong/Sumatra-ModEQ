function [ ] = GPS_est_noise_prep(finName,est)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               GPS_est_noise_prep.m                                %
% prepare input file for Langbein's est_noise code                                  %
%                                                                                   %
% INPUT:                                                                            %
% finName - *.rn *.re *.ru                                                          %
% 1    2   3    4                                                                   %
% YEAR DOY DATA ERROR                                                               %
% est - structure for est_noise parameters                                          %
%                                                                                   %
% OUTPUT:                                                                           %
% a est_noise *.inp file for finName                                                %
%                                                                                   %
% --------------------------------------------------------------------------------- %
% output files after running est_noise                                              %
% prob1.out - time, data and A matrix after redundencies removed                    %
% prob2.out - time, data and A matrix before redundencies removed                   % 
% cross_cor.out -                                                                   %
% max.dat   - MLE parameters                                                        %
% MLE 0 data_points whiteAmp whiteErr powerAmp powerAmpErr powerIndex powerIndexErr %
% mat.out   -                                                                       %
% model.dat - model parameters                                                      %
% b bErr v vErr                                                                     %
% model.out -                                                                       %
% resid.out - year doy residual calculated data                                     %
% resid_dec.out - decimated data; if no decimation the same as resid.out            %
% --------------------------------------------------------------------------------- %
%                                                                                   %
% first created by Lujia Feng Thu Nov 14 10:10:03 SGT 2013                          %
% added est lfeng Wed Nov 20 10:54:30 SGT 2013                                      %
% last modified by Lujia Feng Wed Nov 20 11:06:21 SGT 2013                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist(finName,'file'), error('GPS_est_noise_prep ERROR: %s does not exist!',finName); end
fin      = fopen(finName,'r');
dataCell = textscan(fin,'%f %f %f %f','CommentStyle','#');         % Delimiter default White Space
data     = cell2mat(dataCell);
year     = data(:,1);     % data coverage
doy      = data(:,2);     % doy can be decimal days 300.5
fclose(fin);

% default parameters
if isempty(est)
   est.fileFormat  = 'otr';      % file format style 
                                 % [otr:year doy data error; otd: yearmmdd, data error; otx: year mon day data error]
   est.datsetNum   = 1;          % number of dataset = set of PSD functions
   est.rateFlag    = 'y';        % estimate a secular rate or not [y/n]
   est.rchangeNum  = 0;          % number of rate changes
   est.rchanges    = [];
   est.periodNum   = 0;          % number of periods
   est.periods     = 0.5*365.25; % periods in days
   est.offsetNum   = 0;          % number of offsets
   est.offsets     = [];         % first day after offset
   est.explogNum   = 0;          % number of exponential and logarithmic
   est.auxsetNum   = 0;          % nuber of time-series of auxillary data (e.g. pressure)
   est.sampleMin   = 1;          % mininum sampling in days  (usually 1 day for CGPS)
   est.sampleFlag  = 'n';        % get rid of "redundent" data [y/n]
   est.testFlag    = 'n';        % subsittute real data with random numbers [y/n]
   est.decimNum    = 0;          % 0,1,2, or 3; 0 for best results, others toss out observations for quick and dirty check
   est.whiteAmp    = 1;          % initial white noise amplitude is 1 mm
   est.whiteFlag   = 'float';    % estimate white noise amplitude [fix/float]
   est.powerAmp    = 1;          % initial power law amplitude
   est.powerFlag   = 'float';    % estimate power law amplitude [fix/float]
   est.powerIndex  = 1;          % initial guess of power law index
   est.indexFlag   = 'float';    % estimate index [fix/float]
   est.GMTime      = 0;          % Gauss Markov time constant to 0
   est.GMFlag      = 'fix';      % do not estimate GM time constant [fix/float]
   est.bandMin     = 0.5;        % bandpass filter low frequency stop band [cycles/yr]
   est.bandMax     = 2;          % bandpass filter high frequncy stop band [cycles/yr]
   est.poleNum     = 1;          % number of poles in the BP filter (1,2,3,4,5,6)
   est.BPAmp       = 0;          % initial bandpass filter amplitude
   est.BPFlag      = 'fix';      % do not estimate BP amplitude [fix/float]
   est.power2Index = 2;          % second power law index
   est.index2Flag  = 'fix';      % do not estimate second powr law index [fix/float]
   est.power2Amp   = 0;          % initial amplitude for second power law
   est.power2Flag  = 'fix';      % don not estimate second power law amplitude [fix/float]
   est.white2Amp   = 0;          % add white noise to data
end

% output an input file for est_noise
finpName = [ finName '.inp' ];
fprintf(1,'\n.......... GPS_est_noise_prep: writing %s ...........\n',finpName);
fout = fopen(finpName,'w');

fprintf(fout,'%s\n',est.fileFormat);
fprintf(fout,'%.0f\n',est.datsetNum);
fprintf(fout,'%4.0f %4.0f %4.0f %4.0f\n',year(1),doy(1),year(end),doy(end));
% background rate
fprintf(fout,'%s\n',est.rateFlag);
% rate changes
fprintf(fout,'%.0f\n',est.rchangeNum);
if est.rchangeNum>0
    fprintf(fout,'%4.0f %4.0f\n',est.rchanges');
end
% periods
fprintf(fout,'%.0f\n',est.periodNum);
if est.periodNum>0
    fprintf(fout,'%.4f\n',est.periods);
end
% offsets
fprintf(fout,'%.0f\n',est.offsetNum);
if est.offsetNum>0
    fprintf(fout,'%4.0f %4.0f\n',est.offsets'); % year doy
end
% postseismic
fprintf(fout,'%.0f\n',est.explogNum);
% input data style
fprintf(fout,'%s\n',est.fileFormat);
% input file name
fprintf(fout,'%s\n',finName);
% auxillary data
fprintf(fout,'%.0f\n',est.auxsetNum);
% sampling
fprintf(fout,'%.1f\n',est.sampleMin);
fprintf(fout,'%s\n',est.sampleFlag);
fprintf(fout,'%s\n',est.testFlag);
fprintf(fout,'%.0f\n',est.decimNum);
% white noise (instrument precision)
fprintf(fout,'%.2f %s\n',est.whiteAmp,est.whiteFlag);
% first power law
fprintf(fout,'%.2f %s\n',est.powerAmp,est.powerFlag);
fprintf(fout,'%.2f %s\n',est.powerIndex,est.indexFlag);
% Gauss Markov
fprintf(fout,'%.2f %s\n',est.GMTime,est.GMFlag);
% bandpass filter
fprintf(fout,'%.2f %.2f\n',est.bandMin,est.bandMax);
fprintf(fout,'%.0f\n',est.poleNum);
fprintf(fout,'%.2f %s\n',est.BPAmp,est.BPFlag);
% second power law
fprintf(fout,'%.2f %s\n',est.power2Index,est.index2Flag);
fprintf(fout,'%.2f %s\n',est.power2Amp,est.power2Flag);
% additional white noise
fprintf(fout,'%.0f\n',est.white2Amp);
fclose(fout);
