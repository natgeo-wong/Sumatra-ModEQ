function slab = EQ_create_typeslab

%                           EQ_create_typeslab.m
%        EQ Function that defines if the event occurred on a slab
%                    Nathanael Wong Zhixin, Feng Lujia
%
% This function helps to define if the event occurred on a slab.  If not,
% the event will determine if a slab geometry needs to be created (for a
% non-slab thrust event) or if there is no slab geometry and all model runs
% occur at the same depth.
%
% INPUT:
% -- N/A
%
% OUTPUT:
% -- slab : information on the fault slab structure
%
% FORMAT OF CALL: EQ_create_typeslab
% 
% OVERVIEW:
% 1) This function asks for user input on the slab geometry.
%
% 2) The input is saved as the variable slab and exported as output into
%    the parent function
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong
%
% 2) -- Rewritten sometime in 2017
%
% 3) -- Final version validated and commented on 20190715 by Nathanael Wong

%%%%%%%%%%%%%%%%%%%%%%% CHOOSE IF EVENT IS ON SLAB %%%%%%%%%%%%%%%%%%%%%%%%

disp ('We wish to constrain the model depth according to the event type.');
disp (' ');

disp ('If the earthquake is a megathrust event, we constrain it to');
disp ('Slab1.0 data that is provided by USGS.');
disp (' ');

disp ('If the earthquake is a strike-slip event, we constrain it to a');
disp ('specific chosen depth for each iteration.');
disp (' ');

disp ('If the earthquake is a backthrust event, we constrain it to a');
disp ('fault-plane that is defined by the position and depth of the top-');
disp ('left hand corner of the slip patch created by GTdef functions.');
disp (' ');

disp ('0.0 = N / StrikeSlip');
disp ('1.0 = Y / Megathrust (Slab1.0 All)');
disp ('1.1 = Y / Megathrust (Slab1.0 Depth)');
disp ('2.0 = N / Backthrust');
disp (' ');

slab = input ('Is the event a slab event?: ');
disp (' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ERROR CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while ~any(slab == [0:2 1.1])
    disp ('Error!  Please choose properly.');
    disp ('0.0 = N / StrikeSlip');
    disp ('1.0 = Y / Megathrust (Slab1.0 All)');
    disp ('1.1 = Y / Megathrust (Slab1.0 Depth)');
    disp ('2.0 = N / Backthrust');
    slab = input ('Is the event a slab event?: ');
    disp (' ')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end