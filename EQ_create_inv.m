function EQinv = EQ_create_inv (EQtype)

%                            EQ_input_inv.m
%        EQ Function that checks if the Model is Forward or Inverse
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of determining if the earthquake
% model is to be run as a forward model or as an inversion.  If it is a
% forward model, then all output variables will be assigned to value 0.  If
% if is an inversion, then all variables will be assigned input values.
%
% INPUT:
% -- Type of Fault Model (EQtype)
%
% OUTPUT:
% -- rake0  : The minimum possible rake (?)
% -- rakeX  : The maximum possible rake (?)
% -- rs0    : The minimum possible fault displacement (m)
% -- rsX    : The maximum possible fault displacement (m)
% -- ss0    : The minimum possible strike-slip displacement (m)
% -- ds0    : The minimum possible dip-slip displacement (m)
% -- ts0    : The minimum possible tensile-slip displacement (m)
% -- ssX    : The maximum possible strike-slip displacement (m)
% -- dsX    : The maximum possible dip-slip displacement (m)
% -- tsX    : The maximum possible tensile-slip displacement (m)
% -- Nd     : Number of fault-rupture patches along dip
% -- Ns     : Number of fault-rupture patches along slip
%
% FORMAT OF CALL: EQ_input_fltfor (Fault Type)
% 
% OVERVIEW:
% 1) The function will ask if the modelling to be done is forward
%    modelling or an inversion.  If it is forward modelling, then all
%    values will be set to 0.  If it is an inversion, then the function
%    will proceed with calling inputs.
%
% 2) It then calls as input the flttype in order to determine the
%    appropriate parameters that will be defined by an input while the rest
%    are assigned to 0
%
% 3) All parameters defined will be output into the parent function.
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
% 2) -- Final version validated and commented on 20190715 by Nathanael Wong

flt = EQtype(1); EQinv.O = []; EQinv.X = []; EQinv.N = [];

%%%%%%%%%%%%%%%%%%%%% VERIFY IF FORWARD OR INVERSION %%%%%%%%%%%%%%%%%%%%%%

disp ('Yes = 1, No = 0')
qn = input ('Is this a Forward Model?: ');
while qn ~= 0 && qn ~= 1
    disp ('Error!  That is not a valid response.')
    disp ('Yes = 1, No = 0')
    qn = input ('Is this a Forward Model?: ');
end

%%%%%%%%%%%%%%%%%%%%%%%% ASSIGN INPUT TO VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%

if qn == 1
    rake0 = 0; rakeX = 0; rs0 = 0; rsX = 0;
    ss0 = 0; ds0 = 0; ssX = 0; dsX = 0; 
    ts0 = 0; tsX = 0; Nd = 1; Ns = 1;
else
    if flt == 1 || flt == 2
        ss0 = input ('Minimum possible strike-slip displacement (m): ');
        ssX = input ('Maximum possible strike-slip displacement (m): ');
        ds0 = input ('Minimum possible dip-slip displacement (m): ');
        dsX = input ('Maximum possible dip-slip displacement (m): ');
        rake0 = NaN; rakeX = NaN; rs0 = NaN; rsX = NaN;
    elseif flt == 3 || flt == 4
        rake0 = input ('Minimum possible rake (d): ');
        rakeX = input ('Maximum possible rake (d): ');
        rs0 = input ('Minimum possible fault displacement (m): ');
        rsX = input ('Maximum possible fault displacement (m): ');
        ss0 = NaN; ssX = NaN; ds0 = NaN; dsX = NaN;
    end
    ts0 = input ('Minimum possible tensile-slip displacement (m): ');
    tsX = input ('Maximum possible tensile-slip displacement (m): ');
    Nd  = input ('Number of fault-rupture patches along dip: ');
    Ns  = input ('Number of fault-rupture patches along slip: ');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EQinv.O = [ rake0, rs0, ss0, ds0, ts0 ];
EQinv.X = [ rakeX, rsX, ssX, dsX, tsX ];
EQinv.N = [ Nd Ns ];

end