function [ M0,area,slip ] = EQS_M0AreaSlip(mu,M0,area,slip)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             EQS_M0AreaSlip	                          %
% convert between seismic moment and area & slip                          %
% mu   - rigidity          [N]                                            %
% M0   - seismic moment    [N*m] = [10e7 dyne*cm]                         %
% area - rupture area      [m^2]                                          %
% slip - slip              [m]                                            %
% provide two of the three to calculate the third one                     %
%									  %
% first created by Lujia Feng Tue Aug  6 08:46:43 SGT 2013                %
% last modified by Lujia Feng Tue Aug  6 09:00:43 SGT 2013                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(mu)
    mu = 30e9;     % [N]
end

if isempty(M0) && ~isempty(area) && ~isempty(slip)
    M0   = mu*area*slip;
elseif ~isempty(M0) && isempty(area) && ~isempty(slip)
    area = M0/mu/slip;
elseif ~isempty(M0) && ~isempty(area) && isempty(slip)
    slip = M0/mu/area;
else
    error('EQS_M0AreaSlip ERROR: need to know two among M0, area, and slip!');
end
