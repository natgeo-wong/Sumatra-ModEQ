function poszsd = EQ_pos_zsd (pos,data,size)

%                        EQ_looppara_z1backthrust.m
%         EQ Function that calculates Burial Depth z1 on Backthrust
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the vertical burial depth and vertical locking
% depth of the fault if its endpoint is at llon1 and llat1, while its
% epicenter is at EQlon1 and EQlat1 with depth EQdepth, and the fault has
% strike "str" and dip "dip" with fault width "width".
%
% Depending on if the earthquake occurred on a slab interface or otherwise
% as defined by the variable "isslab", an interpolation of the depth
% defined by the variable "z" can be used to calculate z1 of an interface
% event as opposed to assuming a flat surface and planar geometery and
% calculating z1 using the function EQ_looppara_z1 backthrust.
%
% From z1, we are able to calculate z2 using the width and the dip of the
% fault.
%
% We are assuming in this function that the surface of the Earth for such a
% small displacement can be assumed to be a flat plane.
%
% INPUT:
% -- isslab     : defines if event is a slab interface event
% -- z          : contains the Slab 1.0 interpolation data
%
% -- width      : width of fault-rupture
% -- str        : strike of fault
% -- dip        : dip of fault
% -- EQlon1     : longitude of earthquake epicenter
% -- EQlat1     : latitude of earthquake epicenter
% -- EQdepth    : depth of earthquake epicenter
%
% -- llon1      : longitude of point defining fault-rupture position
% -- llat1      : latitude of point defining fault-rupture position
%
% OUTPUT:
% -- z1         : vertical burial depth
% -- z2         : vertical locking depth
%
% FORMAT OF CALL: EQ_looppara_z1backthrust (isslab
%                     width, strike, dip,
%                     epicenter longitude, epicenter latitude,
%                     epicenter depth,
%                     endpoint longitude, endpoint latitude)
%
% OVERVIEW:
% 1) The function will use the input "isslab" to determine if the data from
%    Slab 1.0 can be used.
%
% 2) z1 is calculated, either from the data from Slab 1.0 or using the
%    function EQ_looppara_z1backthrust.
%
% 3) z2 is then calculated using the fault width and dip and the calculated
%    value of z1.
%
% 4) The variables z1 and z2 are exported to the parent function.
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%% IMPORTING INTERPOLANT DATA %%%%%%%%%%%%%%%%%%%%%%%%

z = data.z; s = data.s; d = data.d;

%%%%%%%%%%%%%%%%%% CALCULATION OF VERTICAL BURIAL DEPTH %%%%%%%%%%%%%%%%%%%

slab = data.type(3); pos  = pos(:,1:2);
lon1 = data.xyz(1);  lat1 = data.xyz(2);  z1  = data.xyz(5);
wid  = data.dgeo(2); str  = data.dgeo(4); dip = data.dgeo(5);

if any(slab == [1 1.1])
    z1  = -z(pos).*1000;
    if slab == 1
        str =  s(pos);
        dip = -d(pos);
    else
        str = ones(size,1) * str;
        dip = ones(size,1) * dip;
    end
else
    if slab == 2
        z1  = EQ_pos_z1b (str,dip,lon1,lat1,z1,pos);
    else
        z1  = ones(size,1) * z1;
    end
    str = ones(size,1) * str;
    dip = ones(size,1) * dip;
end

%%%%%%%%%%%%%%%%%% CALCULATION OF VERTICAL LOCKING DEPTH %%%%%%%%%%%%%%%%%%

z2 = z1 + wid .* sind(dip);          % Vertical locking depth

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poszsd = [ z1 z2 str dip ];

end
