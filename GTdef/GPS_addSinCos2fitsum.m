function [ fqMat,ampMat ] = GPS_addSinCos2fitsum(fqMat,ampMat,fqSin,fqCos)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_addSinCos2fitsum.m                                 %
% add seasonal cycles with certain frequency to existing fqMat & ampMat             %
%                                                                                   %
% INPUT:                                                                            %
% fqMat   - frequency in 1/year                                                     %
%         = [ fqSin fqCos ]             (fqNum*2)                                   %
% ampMat  - amplitudes for seasonal signals                                         %
%         = [ Tstart Tend nnS nnC eeS eeC uuS uuC                                   %
%              nnSErr nnCErr eeSErr eeCErr uuSErr uuCErr ]  fqNum*(2+6*2)           %
% fqSin   - frequency for sin                                                       %
% fqCos   - frequency for cos                                                       %
%                                                                                   %
% OUTPUT:            							            %
% new fqMat & ampMat                                                                %
%									            %
% first created by lfeng Sat Oct 27 06:07:46 SGT 2012                               %
% last modified by lfeng Sat Oct 27 06:14:30 SGT 2012                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(fqMat)
    fqMat = []; ampMat = [];
end

fqMat  = [ fqMat; fqSin fqCos ];
Tstart = 0;
Tend   = 0;
amp    = 0.1;
ampMat = [ ampMat; Tstart Tend amp amp amp amp amp amp zeros(1,6) ];
