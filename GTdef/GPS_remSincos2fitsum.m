function [ fqMat,ampMat ] = GPS_remSinCos2fitsum(fqMat,ampMat,fqSin,fqCos)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            GPS_remSinCos2fitsum.m                                 %
% remove seasonal cycles with certain frequency from existing fqMat & ampMat        %
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
% first created by lfeng Sat Oct 27 14:15:21 SGT 2012                               %
% last modified by lfeng Sat Oct 27 14:15:30 SGT 2012                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(fqMat)
    % sin
    ind    = fqMat(:,1)~=fqSin;
    fqMat  = fqMat(ind,:);
    ampMat = ampMat(ind,:);
    % cos
    ind    = fqMat(:,2)~=fqCos;
    fqMat  = fqMat(ind,:);
    ampMat = ampMat(ind,:);
end
