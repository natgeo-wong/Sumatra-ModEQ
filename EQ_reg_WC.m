function [RLDmin, RLDmax, RLDavg, ...
    RWmin, RWmax, RWavg] = EQ_reg_WC (M, fault_type)

%                               EQ_reg_SAB.m
%        EQ Function that uses the SAB Regression Model to calculate
%                     Length and Width of Fault-Rupture
%
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the following fault-rupture parameters based on
% an earthquake occurring at different fault types with Moment Magnitude M 
% using the Regressions calculated by Wells and Coppersmith in 1994:
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
% FORMAT OF CALL: EQ_reg_WC (Moment Magnitude, Fault Type)
% 
% OVERVIEW:
% 1) The function will use the input variable "fault_type" to determine the
%    values of the constants input into the regression model.
%
% 2) The function will then use these constants to calculate the minimum,
%    maximum and average values of the fault-rupture length and width
%    according to the WC regression model.
%
% 3) These lengths and widths will be saved into variables which will then
%    be exported to the parent function.

%%%%%%%%%%%%% USE FAULT-TYPE TO DETERMINE VALUE OF CONSTANTS %%%%%%%%%%%%%%

switch fault_type
    case {1, 3}
        a = -2.57; sa = 0.12; b = 0.62; sb = 0.02;
        c = -0.76; sc = 0.12; d = 0.27; sd = 0.02;
    case 2
        a = -1.88; sa = 0.37; b = 0.50; sb = 0.06;
        c = -1.14; sc = 0.28; d = 0.35; sd = 0.05;
    case {4, 5, 6}
        a = -2.42; sa = 0.21; b = 0.58; sb = 0.03;
        c = -1.61; sc = 0.20; d = 0.41; sd = 0.03;
end

%%%%%%%%%%%%%%%%%%% CALCULATE FAULT-RUPTURE DIMENSIONS %%%%%%%%%%%%%%%%%%%%

RLDmin = 10.^(3 + (a - sa) + (b - sb).*M);
RLDmax = 10.^(3 + (a + sa) + (b + sb).*M);
RLDavg = 10.^(3 + a + b.*M);
RWmin = 10.^(3 + (c - sd) + (d - sd).*M);
RWmax = 10.^(3 + (c + sc) + (d + sd).*M);
RWavg = 10.^(3 + c + d.*M);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end