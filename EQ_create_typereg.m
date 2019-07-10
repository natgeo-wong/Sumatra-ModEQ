function reg = EQ_create_typereg (evt)

%                           EQ_input_fltreg.m
%      EQ Function that defines input for Fault-Rupture Dimensions
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function calculates the fault parameters that are defined not only
% by external information, but also by mathematical equations defined by
% heavily research regression models.  It returns as output the regression
% model and the dimensions of the fault-rupture.
%
% INPUT:
% -- Mw    : moment magnitude of earthquake (X.XX)
% -- dip   : dip of fault (?)
% -- z1    : vertical burial depth (m)
%
% OUTPUT:
% -- RM    : regression model
% -- len   : subsurface rupture length (m),
%            calculated from regression equations and Mw
% -- width : downdip rupture width (m),
%            calculated from regression equations and Mw
% -- z2    : vertical locking depth from surface (m),
%            calculated from z1, dip and width
%
% FORMAT OF CALL: EQ_input_fltreg (Moment Magnitude)
%
% OVERVIEW:
% 1) 
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHOOSE REGRESSION %%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp ('Please choose the most appropriate regression method: ');
disp ('Wells & Coppersmith (1994) = 1');
disp ('Blaser, Kruger, Ohrnberger and Scherbaum (2010) = 2');
if any(evt == 4:5), disp ('Strasser, Arango and Bommer (2010) = 3'); end
reg = input ('Please choose the regression: ');
disp (' ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ERROR CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while ~any(reg == 1:3)
    disp ('Error!  Please input a valid regression method.');
    disp ('Wells & Coppersmith (1994) = 1');
    disp ('Blaser, Kruger, Ohrnberger and Scherbaum (2010) = 2');
    if any(evt == 5:6), disp ('Strasser, Arango and Bommer (2010) = 3'); end
    reg = input ('Please choose the regression: ');
    disp (' ');
end

while any(evt == 1:4) && reg == 3
    disp ('Error!  This regression method is not valid for this event.');
    disp ('Wells & Coppersmith (1994) = 1');
    disp ('Blaser, Kruger, Ohrnberger and Scherbaum (2010) = 2');
    reg = input ('Please choose the regression: ');
    disp (' ');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end