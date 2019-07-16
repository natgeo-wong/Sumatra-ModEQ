function zsd = EQ_pos_zsd (pos,data,size)

%                                EQ_pos_zsd.m
%         EQ Function that calculates the depth, strike and dip
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the depth, strike and dip of the fault geometry
% for the entire gridsearch area.
%
% INPUT:
% -- pos  : gridsearch coordinate positions
% -- data : earthquake initial input data
% -- size : number of gridsearch points
%
% OUTPUT:
% -- zsd : vector containing fault geometry details
%          [ burial locking strike dip ]
%
% FORMAT OF CALL: EQ_pos_zsd (gridsearch coord,event data,size)
%
% OVERVIEW:
% 1) The function will use the event data to determine if the data from
%    Slab1.0 can be used.
%
% 2) z1 is calculated, either from the data from Slab1.0 or using the
%    function EQ_pos_z1b or remains the same
%
% 3) z2 is then calculated using the fault width and dip and the calculated
%    value of z1.
%
% 4) The variables z1 and z2 are exported to the parent function.
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
% 
% 2) -- Modified sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

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

zsd = [ z1 z2 str dip ];

end
