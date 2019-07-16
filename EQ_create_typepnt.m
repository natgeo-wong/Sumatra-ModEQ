function pnt = EQ_create_typepnt

%                          EQ_create_typepnt.m
%            EQ Function that defines the GPS data input type
%                    Nathanael Wong Zhixin, Feng Lujia
%
% This function defines the GPS data input type.
%
% INPUT: N/A
%
% OUTPUT:
% -- pnt : GPS data input type
%
% FORMAT OF CALL: EQ_create_typepnt
% 
% OVERVIEW:
% 1) This calls as input the GPS data format and exports it to the parent
%    function
%
% VERSIONS:
% 1) -- Created on 20160614 by Nathanael Wong
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%% SELECTION OF GPS DATA FORMAT %%%%%%%%%%%%%%%%%%%%%%%

disp ('GPS Data Format ranges from 1 to 3');
pnt = input ('Type of GPS Data Format: ');
disp (' ');

while ~any(pnt == 1:3)
    disp ('Error!  Please input a valid GPS Data Format.');
    disp ('GPS Data Format ranges from 1 to 3');
    pnt = input ('Type of GPS Data Format: ');
    disp (' ');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end