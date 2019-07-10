function [RLDmin, RLDmax, RLDavg, ...
    RWmin, RWmax, RWavg] = EQ_reg_BKOS (Mw, fault_type)

%                               EQ_reg_BKOS.m
%       EQ Function that uses the BKOS Regression Model to calculate
%                     Length and Width of Fault-Rupture
%
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the following fault-rupture parameters based on
% an earthquake occurring at different fault types with Moment Magnitude M 
% using the Regressions calculated by Blaser, Kruger, Ohrnberger and
% Scherbaum in 2010:
%       Subsurface Rupture Length (RBL) in m
%       Downdip Rupture Width (RW) in m
%
% We will select the fault type based on an input variable defined within
% the function.
%
% Since we are doing forward modelling, RBL, RW and RA are all assumed to
% be functions of M via the following equations:
%       log10 (RLD)  =   a + b * Mw
%       log10 (RW)   =   c + d * Mw
%       RA = RLD * RW
%
% where
%       a and b are constants that depend on the fault type
%
% INPUT:
% -- Mw         : moment magnitude of earthquake event
% -- fault_type : fault type (ie. strike-slip, dip-slip and tensile-slip)
%
% OUTPUT:
% -- RLDmin : minimum possible subsurface rupture length
% -- RLDmax : maximum possible subsurface rupture length
% -- RLDavg : average possible subsurface rupture length
% -- RWmin  : minimum possible downslip rupture width
% -- RWmax  : maximum possible downslip rupture width
% -- RWavg  : average possible downslip rupture width
%
% FORMAT OF CALL: EQ_reg_BKOS (Moment Magnitude, Fault Type)
% 
% OVERVIEW:
% 1) The function will use the input variable "fault_type" to determine the
%    values of the constants input into the regression model.
%
% 2) The function will then use these constants to calculate the minimum,
%    maximum and average values of the fault-rupture length and width
%    according to the BKOS regression model.
%
% 3) These lengths and widths will be saved into variables which will then
%    be exported to the parent function.

%%%%%%%%%%%%% USE FAULT-TYPE TO DETERMINE VALUE OF CONSTANTS %%%%%%%%%%%%%%

switch fault_type
    case {1, 3}
        a = -2.69; sa = 0.11; b = 0.64; sb = 0.02;
        c = -1.12; sc = 0.12; d = 0.33; sd = 0.02;
    case 2
        a = -1.91; sa = 0.29; b = 0.52; sb = 0.04;
        c = -1.120; sc = 0.25; d = 0.36; sd = 0.04;
    case {4, 5, 6}
        a = -2.37; sa = 0.13; b = 0.57; sb = 0.02;
        c = -1.86; sc = 0.12; d = 0.46; sd = 0.02;
end

%%%%%%%%%%%%%%%%%%% CALCULATE FAULT-RUPTURE DIMENSIONS %%%%%%%%%%%%%%%%%%%%

RLDmin = 10.^(3 + (a - sa) + (b - sb).*Mw);
RLDmax = 10.^(3 + (a + sa) + (b + sb).*Mw);
RLDavg = 10.^(3 + a + b.*Mw);
RWmin = 10.^(3 + (c - sd) + (d - sd).*Mw);
RWmax = 10.^(3 + (c + sc) + (d + sd).*Mw);
RWavg = 10.^(3 + c + d.*Mw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end