function [ fitsum ] = GPS_trimfitsum(fitsum,ymdRange,decyrRange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                GPS_trimfitsum.m                                   %
% window earthquake paramters eqMat,funcMat,paramMat,minmaxMat                      %
% according to given time period & rneu data range                                  %
%                                                                                   %
% INPUT:								            % 
% --------------------------------------------------------------------------------- %
% fitsum struct including                                                           %
% fitsum.site      - site name                                                      %
% fitsum.loc       - site location                                                  %
%          = [ lon lat elev ]                                                       %
% fitsum.rateRow   - linear rates                                                   %
%          = [ Tstart Tend nnb nnRate eeb eeRate uub uuRate                         %
%              nnbErr nnRateErr eebErr eeRateErr uubErr uuRateErr ] (2+6*2)         %
% fitsum.minmaxRow - lower & upper bounds for linear rates                          %
%          = [ Tstart Tend nnb nnRate eeb eeRate uub uuRate   <-min                 %
%                          nnb nnRate eeb eeRate uub uuRate ] <-max (2+6*2)         %
% fitsum.eqMat     - earthquake dates that has been ordered chronologically         %
%          = [ Deq Teq ]                 (eqNum*2)                                  %
%          = [] means no earthquake removed                                         %
% fitsum.funcMat   - a string matrix for function names                             %
%          = [ funcN funcE funcU ]       (eqNum*3*funcLen)                          %
% fitsum.paramMat  - each row for one earthquake (eqNum*3*7*2)                      %
%          = [ nb nv1 nv2 ndV nO na ntau                                            %
%              eb ev1 ev2 edV eO ea etau                                            %
%              ub uv1 uv2 udV uO ua utau                                            %
%              nbErr nv1Err nv2Err ndVErr nOErr naErr ntauErr                       %
%              ebErr ev1Err ev2Err edVErr eOErr eaErr etauErr                       %
%              ubErr uv1Err uv2Err udVErr uOErr uaErr utauErr ]                     %
% fitsum.minmaxMat - lower & upper bounds for paramMat (eqNum*3*7*2)                %
%          = [ nb nv1 nv2 ndV nO na ntau \                                          %
%              eb ev1 ev2 edV eO ea etau  min                                       %
%              ub uv1 uv2 udV uO ua utau /                                          %
%            / nb nv1 nv2 ndV nO na ntau                                            %
%        max   eb ev1 ev2 edV eO ea etau                                            %
%            \ ub uv1 uv2 udV uO ua utau ]                                          %
% fitsum.fqMat     - frequency in 1/year                                            %
%          = [ fqSin fqCos ]             (fqNum*2)                                  %
% fitsum.ampMat    - amplitudes for seasonal signals                                %
%          = [ Tstart Tend nnS nnC eeS eeC uuS uuC                                  %
%              nnSErr nnCErr eeSErr eeCErr uuSErr uuCErr ]  fqNum*(2+6*2)           %
% --------------------------------------------------------------------------------- %
%                                                                                   %
% Examples for function names:                                                      %
% off = off_samerate; off_diffrate                                                  %
% log_samerate, log_diffrate, exp_samerate, exp_diffrate, k05_samerate, k05_diffrate%
% use the same tau for N, E, and U                                                  %
% log_samerate_tau1 = log_tau1_samerate, log_tau2                                   %
% lg2 = lg2_samerate without offset (must be after log)                             %
% ln2 = ln2_samerate without offset (must be after lng)                             %
% ep2 = ep2_samerate without offset (must be after exp)                             %
%                                                                                   %
% for each earthquake N E & U is ordered accordingly                                %
%   1  2   3   4   5  6  7    8  9   10  11  12 13 14   15 16  17  18  19 20 21     %
% [ nb nv1 nv2 ndV nO na ntau eb ev1 ev2 edV eO ea etau ub uv1 uv2 udV uO ua utau ] %
% repeate errors from 22 to 42                                                      %
% [ nb nv1 nv2 ndV nO na ntau eb ev1 ev2 edV eO ea etau ub uv1 uv2 udV uO ua utau ] %
% if no earthquake removed                                                          %
% eqMat      = []; paramMat = []; funcMat = ''                                      %
% ymdRange   = [ min max ] {1x2 row vector}                                         %
% decyrRange = [ min max ] {1x2 row vector}                                         %
%                                                                                   %
% Note: if ymdRange & decyrRange both provided,                                     %
% rneu is trimmed according to the narrrowest range			            %
%                                                                                   %
% first created by Lujia Feng Thu Oct 25 16:20:38 SGT 2012                          %
% added minmaxMat lfeng Tue Apr  9 00:55:41 SGT 2013                                %
% added fitsum struct lfeng Thu Nov 21 16:31:32 SGT 2013                            %
% last modified by Lujia Feng Fri Nov 22 17:37:31 SGT 2013                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(fitsum.eqMat)
    if ~isempty(ymdRange)
       ind = fitsum.eqMat(:,1)>= ymdRange(1) & fitsum.eqMat(:,1)<=ymdRange(2);
       fitsum.eqMat     = fitsum.eqMat(ind,:);
       fitsum.funcMat   = fitsum.funcMat(ind,:);
       fitsum.paramMat  = fitsum.paramMat(ind,:);
       fitsum.minmaxMat = fitsum.minmaxMat(ind,:);
    end
    if ~isempty(decyrRange)
       ind = fitsum.eqMat(:,2)>= decyrRange(1) & fitsum.eqMat(:,2)<=decyrRange(2);
       fitsum.eqMat     = fitsum.eqMat(ind,:);
       fitsum.funcMat   = fitsum.funcMat(ind,:);
       fitsum.paramMat  = fitsum.paramMat(ind,:);
       fitsum.minmaxMat = fitsum.minmaxMat(ind,:);
    end
end
