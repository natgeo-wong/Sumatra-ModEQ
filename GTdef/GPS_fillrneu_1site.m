function [ modsumFill,modsumModel ] = GPS_fillrneu_1site(rneu,ymdRange,decyrRange,fitsum,xx,xxStd)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              GPS_fillrneu_1site.m                                 %
% fill rneu and generate model predictions                                          %
%                                                                                   %
% INPUT:                                                                            % 
% rneu - data marix (dayNum*8)                                                      %
%      = [ YEARMODY YEAR.DCML N E U Nerr Eerr Uerr ]                                %
% --------------------------------------------------------------------------------- %
% ymdRange   = [ min max ] {1x2 row vector}                                         %
% decyrRange = [ min max ] {1x2 row vector}                                         %
% Note: if ymdRange & decyrRange both provided,                                     %
%       rneu is filled according to the widest range                                %
%       NaN indicates no filling & using data length                                %
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
% xx       - solutions  (1*xxNum)                                                   %
% xxStd    - standard deviation for solutions  (1*xxNum)                            %
%                                                                                   %
% OUTPUT:                                                                           %
% --------------------------------------------------------------------------------- %
% modsumFill struct including                                                       % 
% modsumFill.uqMat             - unique EQ dates ordered chronologically            %
%                              = [ Deq Teq ]                 (uqNum*2)              %
%                              = [] means no earthquake removed                     %
% modsumFill.rneuFill          - data with gaps filled                              %
% modsumFill.rneuModel         - model prediction                                   %
% modsumFill.rneuRate          - rates only                                         %
% modsumFill.rneuSeason        - seasonal signals                                   %
% modsumFill.rneuNrate         - remove background rates                            %
% modsumFill.rneuNoff          - remove offsets                                     %
% modsumFill.rneuOoff          - keep only offsets                                  %
% modsumFill.rneuPostSC        - postseismic deformation & seasonal signals         %
% modsumFill.rneuPostEQs       - only keep postseismic deformation of all EQs       %
% modsumFill.rneuCopoCell      - co- & postseismic for individual EQ with diffrate  %
% modsumFill.rneuPostCell      - postseismic for individual EQ with diffrate        %
% modsumFill.rneuPostNdiffCell - postseismic for individual EQ without diffrate     %
% modsumFill.rneuAfterCell     - deformation after coseismic of one EQ              %
% --------------------------------------------------------------------------------- %
% modsumModel struct including                                                      % 
% modsumModel.uqMat            - unique EQ dates ordered chronologically            %
%                              = [ Deq Teq ]                 (uqNum*2)              %
%                              = [] means no earthquake removed                     %
% modsumModel.rneuModel        - model prediction                                   %
% modsumModel.rneuRate         - rates only                                         %
% modsumModel.rneuSeason       - seasonal signals                                   %
% modsumModel.rneuNrate        - remove background rates                            %
% modsumModel.rneuNoff         - remove offsets                                     %
% modsumModel.rneuOoff         - keep only offsets                                  %
% modsumModel.rneuPostSC       - postseismic deformation & seasonal signals         %
% modsumModel.rneuPostEQs      - only keep postseismic deformation of all EQs       %
% modsumModel.rneuCopoCell     - co- & postseismic for individual EQ with diffrate  %
% modsumModel.rneuPostCell     - postseismic for individual EQ with diffrate        %
% modsumModel.rneuPostNdiffCell- postseismic for individual EQ without diffrate     %
% modsumModel.rneuAfterCell    - deformation after coseismic of one EQ              %
% --------------------------------------------------------------------------------- %
% Note:                                                                             %
% fitsum.eqMat        - may include 2 entries for 1 EQ if lg2, ln2 or ep2 is used   %
% modsumFill.eqMat    - 1 entry for 1 EQ                                            %
% modsumModel.eqMat   - 1 entry for 1 EQ                                            %
%										    %
% first created by Lujia Feng Tue Dec 10 01:37:47 SGT 2013                          %
% added ymdRange & decyrRange lfeng Wed Jan  8 12:16:13 SGT 2014                    %
% added time reference tt0 lfeng Wed Jan  8 14:22:22 SGT 2014                       %
% added modsumModel lfeng Fri Jan 10 08:58:31 SGT 2014                              %
% added uqMat lfeng Thu Mar  6 11:34:40 SGT 2014                                    %
% added rneuOoff lfeng Thu Mar  6 17:11:19 SGT 2014                                 %
% added rneuPostNdiffCell lfeng Wed Mar 26 13:22:56 SGT 2014                        %
% added properrors lfeng Sun Apr 13 12:21:14 SGT 2014                               %
% added rneuCopoCell lfeng Sun Jun  1 19:51:54 SGT 2014                             %
% added rneuMegaPost for postseismic only on megathrust lfeng Thu Apr  9 SGT 2015   %
% calculated errors for postseismic lfeng Wed Apr  6 17:24:52 SGT 2016              %
% last modfied by Lujia Feng Wed Apr  6 17:24:58 SGT 2016                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameter to be used
eqMat   = fitsum.eqMat;
uqMat   = unique(eqMat,'rows','stable'); % each EQ has 1 entry
funcMat = fitsum.funcMat;
fqMat   = fitsum.fqMat;
tt0     = rneu(1,2);

% fill date gaps of rneu
[ rneuFill ] = GPS_fillrneu(rneu,ymdRange,decyrRange);

% calculate prediction errors
[ rneuFill ] = GPS_lsqnonlin_1site_properrors(rneuFill,eqMat,funcMat,fqMat,xx,xxStd,tt0);

% calculate model prediction
[ rneuModel,rneuRate,rneuSeason ] = GPS_lsqnonlin_1site_calc(rneuFill,eqMat,funcMat,fqMat,xx,tt0);

% fill prediction
indNan = isnan(rneuFill(:,3));
rneuFill(indNan,:) = rneuModel(indNan,:);

% --------------------------- filled data ---------------------------
% remove background rates from raw time series
[ rneuNrate ] = GPS_lsqnonlin_1site_detrend(rneuFill,xx,tt0);

% remove all offsets from raw time series
[ rneuNoff ] = GPS_lsqnonlin_1site_remoffsets(rneuFill,eqMat,funcMat,fqMat,xx);

% keep only offsets in raw time series
[ rneuOoff ] = GPS_lsqnonlin_1site_offset(rneuFill,eqMat,funcMat,fqMat,xx,tt0);

% keep postseismic & seasonal signals
[ rneuPostSC ] = GPS_lsqnonlin_1site_postSinCos(rneuFill,eqMat,funcMat,fqMat,xx,tt0);

% only keep postseismic deformation of all EQs
[ rneuPostEQs,rneuMegaPostEQs ] = GPS_lsqnonlin_1site_postEQs(rneuFill,eqMat,funcMat,fqMat,xx,tt0);

% postseismic deformation of individual EQs
[ rneuCopoCell,rneuPostCell,rneuPostNdiffCell,rneuAfterCell ] = GPS_lsqnonlin_1site_post_properrors(rneuFill,eqMat,funcMat,fqMat,xx,xxStd,tt0);

% modsum
modsumFill.uqMat             = uqMat;             % unique EQ time
modsumFill.rneuFill          = rneuFill;          % data with gaps filled
modsumFill.rneuModel         = rneuModel;         % model prediction
modsumFill.rneuRate          = rneuRate;          % keep only rates
modsumFill.rneuSeason        = rneuSeason;        % seasonal signals
modsumFill.rneuNrate         = rneuNrate;         % remove rates
modsumFill.rneuNoff          = rneuNoff;          % remove offsets
modsumFill.rneuOoff          = rneuOoff;          % keep only offsets
modsumFill.rneuPostSC        = rneuPostSC;        % postseismic & seasonal signals
modsumFill.rneuPostEQs       = rneuPostEQs;       % all postseismic only
modsumFill.rneuMegaPostEQs   = rneuMegaPostEQs;   % all megathrust postseismic only
modsumFill.rneuCopoCell      = rneuCopoCell;      % coseismic & postseismic for individual EQ with diffrate
modsumFill.rneuPostCell      = rneuPostCell;      % postseismic for individual EQ with diffrate
modsumFill.rneuPostNdiffCell = rneuPostNdiffCell; % postseismic for individual EQ without diffrate
modsumFill.rneuAfterCell     = rneuAfterCell;     % deformation after coseismic of one EQ

% --------------------------- model prediction ---------------------------
% remove background rates from raw time series
[ rneuNrate ] = GPS_lsqnonlin_1site_detrend(rneuModel,xx,tt0);

% remove all offsets from raw time series
[ rneuNoff ] = GPS_lsqnonlin_1site_remoffsets(rneuModel,eqMat,funcMat,fqMat,xx);

% keep only offsets in raw time series
[ rneuOoff ] = GPS_lsqnonlin_1site_offset(rneuModel,eqMat,funcMat,fqMat,xx,tt0);

% keep postseismic & seasonal signals
[ rneuPostSC ] = GPS_lsqnonlin_1site_postSinCos(rneuModel,eqMat,funcMat,fqMat,xx,tt0);

% only keep postseismic deformation of all EQs
[ rneuPostEQs,rneuMegaPostEQs ] = GPS_lsqnonlin_1site_postEQs(rneuModel,eqMat,funcMat,fqMat,xx,tt0);

% postseismic deformation of individual EQs
[ rneuCopoCell,rneuPostCell,rneuPostNdiffCell,rneuAfterCell ] = GPS_lsqnonlin_1site_post_properrors(rneuModel,eqMat,funcMat,fqMat,xx,xxStd,tt0);

% modsum
modsumModel.uqMat             = uqMat;             % unique EQ time
modsumModel.rneuModel         = rneuModel;         % model prediction
modsumModel.rneuRate          = rneuRate;          % keep only rates
modsumModel.rneuSeason        = rneuSeason;        % seasonal signals
modsumModel.rneuNrate         = rneuNrate;         % remove rates
modsumModel.rneuNoff          = rneuNoff;          % remove offsets
modsumModel.rneuOoff          = rneuOoff;          % keep only offsets
modsumModel.rneuPostSC        = rneuPostSC;        % postseismic & seasonal signals
modsumModel.rneuPostEQs       = rneuPostEQs;       % all postseismic only
modsumModel.rneuMegaPostEQs   = rneuMegaPostEQs;   % all megathrust postseismic only
modsumModel.rneuCopoCell      = rneuCopoCell;      % coseismic & postseismic for individual EQ with diffrate
modsumModel.rneuPostCell      = rneuPostCell;      % postseismic for individual EQ with diffrate
modsumModel.rneuPostNdiffCell = rneuPostNdiffCell; % postseismic for individual EQ without diffrate
modsumModel.rneuAfterCell     = rneuAfterCell;     % deformation after coseismic of one EQ
