function [ eqMat,funcMat,paramMat ] = GPS_rem1EQ2fitsum(eqMat,funcMat,paramMat,Deq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_rem1EQ2fitsum.m                                    %
% remove one earthquake from existing eqMat, funcMat, paramMat                      %
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
% first created by Lujia Feng Sat Oct 27 14:16:02 SGT 2012                          %
% last modified by Lujia Feng Sat Oct 27 14:21:50 SGT 2012                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(eqMat)
    ind      = eqMat(:,1)~=Deq;
    eqMat    = eqMat(ind,:);
    funcMat  = funcMat(ind,:);
    paramMat = paramMat(ind,:);
end
