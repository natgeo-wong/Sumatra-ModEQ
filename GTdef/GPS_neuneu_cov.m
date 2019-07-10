function [ errneu,covmat,cc ] = GPS_neuneu_cov(datCov,eulerCov)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             GPS_neuneu_cov.m                                  %
% form the covariance matrix for plat motion subtraction                        %
%										%
% INPUT:									% 
% (1) datCov   - data rate covariance matrix          				%
% (2) eulerCov - plate motion covariance matrix                                 %
%										%
% OUTPUT: 									%
% errneu  - standard deviation for N E & U commponents                          %
% covmat  - final covariance matrix with plate motion removed			%
% cc      - final correlation coefficient matrix				%
%										%
% first created by Lujia Feng Tue Mar  1 18:01:03 EST 2011			%
% added vertical lfeng Wed Jun 19 01:48:06 SGT 2013                             %
% last modified by Lujia Feng Wed Jun 19 03:08:21 SGT 2013                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     [ 1 0 0 -1  0  0 ][datVns]
%     [ 0 1 0  0 -1  0 ][datVew]
% R = [	0 0 1  0  0 -1 ][datVud]
%                       [eulerVns]
%                       [eulerVew]
%                       [eulerVud]
T = [ 1  0  0 -1  0  0;
      0  1  0  0 -1  0;
      0  0  1  0  0 -1 ]; 

% form diagonal covariance matrix
cov0   = blkdiag(datCov,eulerCov);
% covariance propagation
covmat = T*cov0*T';
% correlation matrix
%[ errneu,cc ] = cov2corr(covmat); % cov2corr not available for current version
errN   = sqrt(covmat(1,1)); 
errE   = sqrt(covmat(2,2)); 
errU   = sqrt(covmat(3,3)); 
errneu = [ errN errE errU ];
errneuMat = diag(1./errneu);   % sysmetrical matrix
cc     = errneuMat*covmat*errneuMat;
