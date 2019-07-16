function reg = EQ_create_typereg (evt)

%                          EQ_create_typereg.m
%           EQ Function that defines the regression method
%                   Nathanael Wong Zhixin, Feng Lujia
%
% This function asks the user to select the regression type based on the
% event type.  This is because regressions may have event types they are
% specifically geared towrds.
%
% INPUT:
% -- evt : event type information
%
% OUTPUT:
% -- reg : regression ID
%
% FORMAT OF CALL: EQ_input_fltreg (Moment Magnitude)
%
% OVERVIEW:
% 1) Based on the event type information imported from the parent function,
%    the function displays the most appropriate regression methods and asks
%    for user input
%
% 2) The selected regression type is exported to the parent function
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

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