function EQslip = EQ_create_slip (EQID, EQdim)

%                           EQ_input_fltMME.m
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
% -- Mw   : Moment Magnitude Mw of Earthquake (X.XX)
% -- area : Fault-Rupture Area
%
% OUTPUT:
% -- rake : direction of slip with respect to fault (d)
% -- mu   : rigidity
% -- rs   : total slip displacement (m)
% -- ss   : strike-slip displacement (m),
%           calculated from Mw and rake given by GCMT Catalog
% -- ds   : dip-slip displacement (m)
%           calculated from Mw and rake given by GCMT Catalog
% -- ts   : tensile-slip displacement (m)
%           calculated from Mw and rake given by GCMT Catalog
%
% FORMAT OF CALL: EQ_input_fltMME (Moment Magnitude, Fault-Rupture Area)
%
% OVERVIEW:
% 1) The equation will first call for an input of the rake and the
%    rigidity and save them into the variables "rake" and "mu".  Note that
%    the units of mu are in GigaPascals, neccessitating a conversion to
%    Pascals later on when the equations is applied.
%
% 2) The function will then take as input the moment magnitude Mw and
%    convert it to seismic moment M0.
%
% 3) The function will then take as input the area of the fault-rupture and
%    use it to calculate the total displacement along the rake "rs" using
%    the seismic moment, rigidity and fault-rupture area.
%
% 4) Lastly, the function will then calculate the strike-slip, dip-slip and
%    tensile-slip components and save them into the variables "ss", "ds"
%    and "ts".
%
% 5) The variables "rake", "mu", "rs", "ss", "ds" and "ts" are then
%    exported to the parent function.
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong

Mw = EQID.ID(2); area = EQdim(3);
EQslip.MME = []; EQslip.disp = [];

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

EQslip.MME  = [ rake mu ];
EQslip.disp = [ rs ss ds ts ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

