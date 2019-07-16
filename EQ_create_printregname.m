function name = EQ_create_printregname (rID)

%                         EQ_create_printregname.m
%    EQ function that prints the regression name to string for filename
%                     Nathanael Wong Zhixin, Feng Lujia
%
% This function prints the regression name into a string for the .eq file
% name.
%
% INPUT:
% -- rID : regression ID
%
% OUTPUT:
% -- name : regression name in string format
%
% FORMAT OF CALL: EQ_create_printregname (regression ID)
% 
% OVERVIEW:
% 1) This function prints the regression name to string
%
% VERSIONS:
% 1) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHOOSE REGRESSION %%%%%%%%%%%%%%%%%%%%%%%%%%%%

if     rID == 1, name = 'WC';
elseif rID == 2, name = 'BKOS';
elseif rID == 3, name = 'SAB';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end