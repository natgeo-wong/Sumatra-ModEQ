function evt = EQ_create_typeevt (slab)



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