function [ Mw,M0 ] = EQS_MwM(Mw,M0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                EQS_MwM	                          %
% convert between seismic moment and moment magnitude                     %
% M0 - seismic moment      [N*m] = [10e7 dyne*cm]                         %
% Mw - moment magnitude                                                   %
% either M0 or Mw must be empty                                           %
%									  %
% first created by Lujia Feng Tue Aug  6 08:21:15 SGT 2013                %
% last modified by Lujia Feng Tue Aug  6 08:38:04 SGT 2013                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(Mw) && ~isempty(M0)
    %Mw = log(M0)/2.303*2/3 - 6.06667;
    Mw = log10(M0)*2/3 - 6.06667;
elseif ~isempty(Mw) && isempty(M0)
    M0 = 10^(1.5*(Mw+6.06667));
else
    error('EQS_MwM ERROR: either Mw or M0 needs to be empty!');
end
