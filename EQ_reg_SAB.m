function [RLDmin, RLDmax, RLDavg, ...
    RWmin, RWmax, RWavg] = EQ_reg_SAB (M, fault_type)

%                               EQ_reg_SAB.m
%        EQ Function that uses the SAB Regression Model to calculate
%                     Length and Width of Fault-Rupture
%
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the following fault-rupture parameters based on
% an earthquake occurring at different fault types with Moment Magnitude M 
% using the Regressions calculated by Strasser, Arango and Bommer in 2010
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
% FORMAT OF CALL: EQ_reg_SAB (Moment Magnitude, Fault Type)
% 
% OVERVIEW:
% 1) The function will use the input variable "fault_type" to determine the
%    values of the constants input into the regression model.
%
% 2) The function will then use these constants to calculate the minimum,
%    maximum and average values of the fault-rupture length and width
%    according to the SAB regression model.
%
% 3) These lengths and widths will be saved into variables which will then
%    be exported to the parent function.

%%%%%%%%%%%%% USE FAULT-TYPE TO DETERMINE VALUE OF CONSTANTS %%%%%%%%%%%%%%

switch fault_type
    case 5
        a = -2.477; sa = 0.222; b = 0.585; sb = 0.029;
        c = -0.882; sc = 0.226; d = 0.351; sd = 0.029;
    case 6
        a = -2.350; sa = 0.453; b = 0.562; sb = 0.064;
        c = -1.058; sc = 0.217; d = 0.356; sd = 0.031;
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