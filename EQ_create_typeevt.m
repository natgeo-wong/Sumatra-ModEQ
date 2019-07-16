function evt = EQ_create_typeevt (slab)

%                           EQ_create_typeevt.m
%        EQ Function that defines the type of event that occurred
%                    Nathanael Wong Zhixin, Feng Lujia
%
% This function helps to define the type of event that occurred, based on
% the slab geometry input
%
% INPUT:
% -- slab : slab information
%
% OUTPUT:
% -- evt : event type information
%
% FORMAT OF CALL: EQ_create_typeevt (slab information)
% 
% OVERVIEW:
% 1) This function imports the slab information from the parent function
%
% 2) Based on the slab information, the function then determines the type
%    of possible events that could have occurred and then asks for the user
%    input
%
% 3) The choice is then saved and exported to the parent function
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

disp ('There are many different types of earthquake events.');
disp ('Please define the earthquake event type.');
disp (' ');
disp ('We define the events numerically as follows:')
disp ('    1 : Left Lateral Strike-Slip');
disp ('    2 : Normal');
disp ('    3 : Right Lateral Strike-Slip');
disp ('    4 : Reverse Crustal');
disp ('    5 : Megathrust');
disp ('    6 : Reverse Intraslab');
disp (' ');

if any (slab == [1 1.1])
    evt = 5;
    fprintf ('Since slab = %.1f, the event is a megathrust earthquake.\n',slab)
    disp ('Event Type:  5')
    disp (' ')
elseif slab == 0
    fprintf ('Since slab = %.1f, the event is a strikeslip earthquake.\n',slab)
    disp (' ');
    disp ('Left-Lat Strike-slip = 1, Right-Lat Strike-Slip = 3');
    evt = input ('Event Type: ');
    disp (' ')
    
    while ~any (evt == [1 3])
        disp ('Error!  Please input a valid strikeslip event type.');
        disp ('Left-Lat Strike-slip = 1, Right-Lat Strike-Slip = 3');
        disp (' ')
        evt = input ('Fault Type: ');
        disp (' ');
    end
else
    fprintf ('Since slab = %.1f, the event is a reverse (non-megathrust) earthquake.\n',slab)
    disp (' ');
    disp ('Reverse Crustal = 4, Reverse Intraslab = 6');
    evt = input ('Event Type: ');
    disp (' ')
    
    while ~any (evt == [4 6])
        disp ('Error!  Please input a valid reverse (non-megathrust) event type.');
        disp ('Reverse Crustal = 4, Reverse Intraslab = 6');
        disp (' ')
        evt = input ('Fault Type: ');
        disp (' ');
    end
end