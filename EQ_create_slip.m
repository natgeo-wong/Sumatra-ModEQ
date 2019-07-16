function slip = EQ_create_slip (ID,dim)

%                           EQ_create_slip.m
%       EQ Function that defines input for Rake, Rigidity and Slips
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the fault parameters of Rake, Rigidity and Slip
% that are defined by mathematical relations and thus can be calculated
% from an understanding of the equation M0 = uAx, where
%    -- M0 : Seismic Moment
%    -- u  : Rigidity
%    -- A  : Rupture Area
%    -- rs : Slip
%
% From there, once we have the total slip rs, we can use the rake, or the
% slip direction with respect to the fault geometery, to determine the
% magnitudes of the strike-slip, dip-slip and tensile-slip components.
%
% INPUT:
% -- ID  : earthquake ID information
% -- dim : fault rupture dimensions
%          [ length width area ]
%
% OUTPUT:
% -- slip : structure containing slip information
%           .MME  [ rake rigidity(mu) ]
%           .disp [ rake-slip strike-slip dip-slip tensile-slip ]
%
% FORMAT OF CALL: EQ_create_slip (ID,dimensions)
%
% OVERVIEW:
% 1) The equation will first call for an input of the rake and the
%    rigidity and save them into the variables "rake" and "mu".  Note that
%    the units of mu are in GigaPascals, neccessitating a conversion to
%    Pascals later on when the equations is applied.
%
% 2) The function will then extract the moment magnitude Mw from prior
%    input and convert it to seismic moment M0.
%
% 3) The function will then extract the area of the fault-rupture and use
%    it to calculate the total displacement along the rake "rs" using the
%    seismic moment, rigidity and fault-rupture area.
%
% 4) Lastly, the function will then calculate the strike-slip, dip-slip and
%    tensile-slip components and save them into the variables "ss", "ds"
%    and "ts".
%
% 5) The variables "rake", "mu", "rs", "ss", "ds" and "ts" are then
%    saved into a variable structure and exported to the parent function.
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

Mw = ID.ID(2); area = dim(3);
slip.MME = []; slip.disp = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT RAKE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rake = input ('Rake (d): ');
disp (' ')
while rake < 0 || rake > 360
    disp ('Error!  Rake must be between 0 and 360')
    rake = input ('Rake (d): ');
    disp (' ')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT RIGIDITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp ('Rigidity / Shear Modulus has values ranging from 30-60 GigaPascals')
disp ('Please input a value from 30 to 60')
mu = input ('Rigidity / Shear Modulus: ');
disp (' ')

%%%%%%%%%%%%%%%%% CALCULATE SEISMIC MOMENT AND TOTAL SLIP %%%%%%%%%%%%%%%%%

M0 = 10^(1.5*(Mw+6.06667)); rs = M0 / (10^9*mu*area);

%%%%%%%%%%%%%%%%%%%%%%%% CALCULATE SLIP COMPONENTS %%%%%%%%%%%%%%%%%%%%%%%%

ss = rs * cosd(rake);

if rake >= 0 && rake <= 180
    ds = rs * sind(rake); ts = 0;
else
    ts = rs * sind(rake); ds = 0;
end

slip.MME  = [ rake mu ];
slip.disp = [ rs ss ds ts ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

