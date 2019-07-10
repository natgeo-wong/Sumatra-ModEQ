function [ eqMat,funcMat,paramMat ] = GPS_add1EQ2fitsum(eqMat,funcMat,paramMat,Deq,fittype)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_add1EQ2fitsum.m                                    %
% add one earthquake to existing eqMat, funcMat, paramMat                           %
%                                                                                   %
% INPUT:                                                                            %
% eqMat    = [ Deq Teq ]                                                            %
% paramMat - each row for one earthquake eqNum*(3*7*2)                              %
% funcMat  - a eqNum*3*funcLen string matrix for function names                     %
%          = [ funcN funcE funcU ]                                                  %
% funcLen  = 20                                                                     %
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
%                                                                                   %
% OUTPUT:            							            %
% new eqMat, funcMat, paramMat                                                      %
%									            %
% first created by Lujia Feng Thu Oct 25 18:02:55 SGT 2012                          %
% modified funcLen lfeng Thu Apr  4 12:04:48 SGT 2013                               %
% last modified by Lujia Feng Wed Nov 28 14:13:28 SGT 2012                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(eqMat)
    eqMat = []; funcMat = []; paramMat = [];
end
if isempty(eqMat) || ~any(eqMat(:,1)==Deq)   
    funcLen  = 20;
    len      = length(fittype);
    [ ~,~,Teq ] = GPS_YEARMMDDtoDCMLYEAR(Deq);
    eqMat    = [ eqMat; Deq Teq ];
    funcMat  = [ funcMat; 'nan' wSpace(ones(1,17)) 'nan' wSpace(ones(1,17)) 'nan' wSpace(ones(1,17)) ];
    funcMat(end,1:len) = fittype;
    funcMat(end,funcLen+1:funcLen+len) = fittype;
    funcMat(end,funcLen*2+1:funcLen*2+len) = fittype;
    bb = 0; v1 = 1; v2 = 1; dv = v2-v1;
    OO = 1; aa = 1; tau = 0.001;
    paramMat = [ paramMat; bb v1 v2 dv OO aa tau bb v1 v2 dv OO aa tau bb v1 v2 dv OO aa tau zeros(1,21) ];
end
