function [ fitsum ] = GPS_comp2fitsum(fitsumName1,fitsumName2,siteName,scaleOut)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                 GPS_comp2fitsum.m                                 %
% compare two *.fitsum files                                                        %
%                                                                                   %
% INPUT:                                                                            %
% fitsumName1 - 1st fitsum file name                                                %
% fitsumName2 - 2nd fitsum file name                                                %
% siteName    - site name                                                           %
% scaleOut    - scale to meter in output                                            %
%             = [] means no change of unit                                          %
%                                                                                   %
% OUTPUT:                                                                           %
% *.fitsum    - one fitsum file that has values fitsumName1 - fitsumName2           %
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
%									            %
% first created by Lujia Feng Sat Jul 12 19:47:46 SGT 2014                          %
% last modified by Lujia Feng Sat Jul 12 20:10:15 SGT 2014                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ fitsum1,~ ] = GPS_readfitsum(fitsumName1,siteName,scaleOut);
[ fitsum2,~ ] = GPS_readfitsum(fitsumName2,siteName,scaleOut);

% fitsum1 - fitsum2
fitsum = fitsum1;
fitsum.rateRow(1,9:end)   = fitsum1.rateRow(1,3:8)   - fitsum2.rateRow(1,3:8);
fitsum.paramMat(:,22:end) = fitsum1.paramMat(:,1:21) - fitsum2.paramMat(:,1:21);
fitsum.ampMat(:,9:end)    = fitsum1.ampMat(:,3:8) - fitsum2.ampMat(:,3:8);

foutName = [ siteName '_comp2fitsum.fitsum' ];
GPS_savefitsum(foutName,fitsum,[],scaleOut);
