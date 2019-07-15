function z = EQ_create_posz (isslab,width,dip)

%                              EQ_create_posz.m
%          EQ Function that defines input for fault coordinates
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the burial and locking depths for earthquake
% input files based on whether the event is a slab (i.e. megathrust) event,
% and the fault width and dip if applicable
%
% INPUT:
% -- isslab : is the event a slab/megathust event
% -- width  : event rupture width (along dip)
% -- dip    : fault dip
%
% OUTPUT:
% -- z      : vector containing burial and locking depth information
%             [ burial locking ]
%
% FORMAT OF CALL: EQ_create_posz (slab,width,dip)
% 
% OVERVIEW:
% 1) This calls as input the slab, width and dip parameters
%
% 2) If the event is a slab event, then the model depths will be calculated
%    during the model runs, without needed input from the eq file and
%    therefore the depths will be set to NaN
%
% 3) Otherwise, user input for the burial depth is required.
%
% 4) The locking depth is calculated from the burial depth, and prior
%    information of the event width and dip (note only for slab events is
%    this not needed, and for all non-slab events dip will have been given
%    as prior input).
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%% IMPORT LONGITUDE AND LATITUDE %%%%%%%%%%%%%%%%%%%%%%

if    any(isslab == [1 1.1]), z(1:2) = NaN;
else, disp('Depth is larger than 0 m');
    
    if ~isslab, z1 = input('Model Depth (m): ');
    else,       z1 = input('Initial Depth (m): ');
    end
    disp (' ')
    
    while z1 < 0
        disp('Error!  Depth must be larger than 0m')
        if ~isslab, z1 = input('Model Depth (m): ');
        else,       z1 = input('Initial Depth (m): ');
        end
        disp(' ')
    end
    
    z2 = z1 + width*sind(dip);
    z = [ z1 z2 ];
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end