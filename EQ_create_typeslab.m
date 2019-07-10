function slab = EQ_create_typeslab

%                            EQ_constr_slab.m
%        EQ Function that determines if earthquake is a slab event
%                    Nathanael Wong Zhixin, Feng Lujia
%
% This function is created for the purpose of allowing the user to select
% if the earthquake occurred as a slab event.
%
% If the earthquake occurred on the slab, we can use pre-existing data from
% Slab 1.0, a resource provided by USGS, to determine the depth z1 of the
% earthquake for a given longitude and latitude as the boundary between the
% slabs is gives a fixed depth for a unique longitude and latitude.
%
% However, if the earthquake is not a slab event, but rather an intraslab
% event or a crustal event, then z1 will have to be calculated manually
% using equations from the GCMT data that provides longitude, latitude and
% depth of the earthquake hypocenter.
%
% INPUT:
% -- N/A
%
% OUTPUT:
% -- The variable "isslab" that determines if the earthquake is to be
%    treated as an event on the slab interface or if it is an intraslab or
%    crustal event.
%
% FORMAT OF CALL: EQ_constr_slab
% 
% OVERVIEW:
% 1) This function first displays the purpose of determining if the event
%    has occurred on the slab.
%
% 2) It will then ask if the earthquake is a slab event, and call for an
%    input.
%
% 	 If the input is not in the specified format, it will generate an error
%    message and ask for the user for an input of the parameter until a
%    valid input format has been entered.
%
% 3) The input is saved as the variable "isslab" as an output
%
% VERSIONS:
% 1) -- Created on 20160613 by Nathanael Wong

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